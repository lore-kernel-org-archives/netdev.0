From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH net-next v2] net: remove delay at device dismantle
Date: Thu, 23 Aug 2012 10:25:00 +0800
Message-ID: <5035947C.8090609@cn.fujitsu.com>
References: <1344590824.31104.1953.camel@edumazet-glaptop>  <20120810.034211.994338127277150687.davem@davemloft.net>  <1344596809.31104.2358.camel@edumazet-glaptop>  <1344609966.31104.2705.camel@edumazet-glaptop>  <1344613369.31104.2734.camel@edumazet-glaptop> <1344664487.5158.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Mahesh Bandewar <maheshb@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:4551 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756224Ab2HWCYq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 22:24:46 -0400
In-Reply-To: <1344664487.5158.1.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B408=E6=9C=8811=E6=97=A5 13:54, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Fri, 2012-08-10 at 17:42 +0200, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> I noticed extra one second delay in device dismantle, tracked down t=
o
>> a call to dst_dev_event() while some call_rcu() are still in RCU que=
ues.
>>
> ...
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Tom Herbert <therbert@google.com>
>> Cc: Mahesh Bandewar <maheshb@google.com>
>> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>> v2: NETDEV_UNREGISTER_FINAL called outside of rtnl lock
>>     as its more risky, base this patch on net-next
>=20
> Also I am leaving for a one week vacation with no access to the
> Internet, so better hold this patch until my return ;)
>=20

Hi Eric

I got this warning message with your patch applied.

Aug 22 18:32:56 Donkey kernel: [  124.733048] =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Aug 22 18:32:56 Donkey kernel: [  124.733051] [ INFO: suspicious RCU us=
age. ]
Aug 22 18:32:56 Donkey kernel: [  124.733054] 3.6.0-rc1+ #14 Not tainte=
d
Aug 22 18:32:56 Donkey kernel: [  124.733057] -------------------------=
------
Aug 22 18:32:56 Donkey kernel: [  124.733060] include/linux/inetdevice.=
h:229 suspicious rcu_dereference_protected() usage!
Aug 22 18:32:56 Donkey kernel: [  124.733062]
Aug 22 18:32:56 Donkey kernel: [  124.733062] other info that might hel=
p us debug this:
Aug 22 18:32:56 Donkey kernel: [  124.733062]
Aug 22 18:32:56 Donkey kernel: [  124.733066]
Aug 22 18:32:56 Donkey kernel: [  124.733066] rcu_scheduler_active =3D =
1, debug_locks =3D 1
Aug 22 18:32:56 Donkey kernel: [  124.733069] 3 locks held by kworker/u=
:1/39:
Aug 22 18:32:56 Donkey kernel: [  124.733072]  #0:  (netns){.+.+.+}, at=
: [<ffffffff8107e117>] process_one_work+0x137/0x5d0
Aug 22 18:32:56 Donkey kernel: [  124.733086]  #1:  (net_cleanup_work){=
+.+.+.}, at: [<ffffffff8107e117>] process_one_work+0x137/0x5d0
Aug 22 18:32:56 Donkey kernel: [  124.733095]  #2:  (net_mutex){+.+.+.}=
, at: [<ffffffff81542fd5>] cleanup_net+0x85/0x1a0
Aug 22 18:32:56 Donkey kernel: [  124.733106]
Aug 22 18:32:56 Donkey kernel: [  124.733106] stack backtrace:
Aug 22 18:32:56 Donkey kernel: [  124.733110] Pid: 39, comm: kworker/u:=
1 Not tainted 3.6.0-rc1+ #14
Aug 22 18:32:56 Donkey kernel: [  124.733112] Call Trace:
Aug 22 18:32:56 Donkey kernel: [  124.733120]  [<ffffffff810c2312>] loc=
kdep_rcu_suspicious+0xe2/0x130
Aug 22 18:32:56 Donkey kernel: [  124.733127]  [<ffffffff815d35d4>] fib=
_netdev_event+0x114/0x180
Aug 22 18:32:56 Donkey kernel: [  124.733133]  [<ffffffff816914cc>] not=
ifier_call_chain+0x5c/0x120
Aug 22 18:32:56 Donkey kernel: [  124.733139]  [<ffffffff8108d6b6>] raw=
_notifier_call_chain+0x16/0x20
Aug 22 18:32:56 Donkey kernel: [  124.733144]  [<ffffffff8154585c>] cal=
l_netdevice_notifiers+0x3c/0x70
Aug 22 18:32:56 Donkey kernel: [  124.733149]  [<ffffffff8154f88c>] net=
dev_run_todo+0x8c/0x280
Aug 22 18:32:56 Donkey kernel: [  124.733154]  [<ffffffff81544c9d>] ? s=
ynchronize_net+0x2d/0x40
Aug 22 18:32:56 Donkey kernel: [  124.733159]  [<ffffffff8155b90e>] rtn=
l_unlock+0xe/0x10
Aug 22 18:32:56 Donkey kernel: [  124.733164]  [<ffffffff81546c1a>] def=
ault_device_exit_batch+0xba/0xd0
Aug 22 18:32:56 Donkey kernel: [  124.733170]  [<ffffffff81542275>] ops=
_exit_list+0x55/0x60
Aug 22 18:32:56 Donkey kernel: [  124.733175]  [<ffffffff8154304b>] cle=
anup_net+0xfb/0x1a0
Aug 22 18:32:56 Donkey kernel: [  124.733180]  [<ffffffff8107e178>] pro=
cess_one_work+0x198/0x5d0
Aug 22 18:32:56 Donkey kernel: [  124.733185]  [<ffffffff8107e117>] ? p=
rocess_one_work+0x137/0x5d0
Aug 22 18:32:56 Donkey kernel: [  124.733191]  [<ffffffff8168b2b8>] ? _=
_schedule+0x428/0x910
Aug 22 18:32:56 Donkey kernel: [  124.733196]  [<ffffffff81080951>] ? w=
orker_thread+0x2a1/0x4b0
Aug 22 18:32:56 Donkey kernel: [  124.733201]  [<ffffffff81542f50>] ? n=
et_drop_ns+0x50/0x50
Aug 22 18:32:56 Donkey kernel: [  124.733207]  [<ffffffff8108083a>] wor=
ker_thread+0x18a/0x4b0
Aug 22 18:32:56 Donkey kernel: [  124.733212]  [<ffffffff810806b0>] ? m=
anage_workers+0x2a0/0x2a0
Aug 22 18:32:56 Donkey kernel: [  124.733217]  [<ffffffff810867de>] kth=
read+0xae/0xc0
Aug 22 18:32:56 Donkey kernel: [  124.733222]  [<ffffffff810c39cd>] ? t=
race_hardirqs_on+0xd/0x10
Aug 22 18:32:56 Donkey kernel: [  124.733227]  [<ffffffff81697044>] ker=
nel_thread_helper+0x4/0x10
Aug 22 18:32:56 Donkey kernel: [  124.733233]  [<ffffffff8168d570>] ? r=
etint_restore_args+0x13/0x13
Aug 22 18:32:56 Donkey kernel: [  124.733237]  [<ffffffff81086730>] ? f=
lush_kthread_work+0x1a0/0x1a0
Aug 22 18:32:56 Donkey kernel: [  124.733242]  [<ffffffff81697040>] ? g=
s_change+0x13/0x13
Aug 22 18:32:56 Donkey kernel: [  124.733248]
Aug 22 18:32:56 Donkey kernel: [  124.733250] =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
