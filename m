From: Miles Lane <miles.lane@gmail.com>
Subject: Re: 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invoked
	rcu_dereference_check() without protection!
Date: Tue, 8 Jun 2010 00:16:16 -0400
Message-ID: <AANLkTikl13cJNuU32JzRarrUnoh5DYHr-Tbnv9B-UjsG@mail.gmail.com>
References: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@mail.gmail.com>
	<20100608001929.GF2387@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vivek Goyal <vgoyal@redhat.com>, Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41074 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033Ab0FHEQS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 00:16:18 -0400
In-Reply-To: <20100608001929.GF2387@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 7, 2010 at 8:19 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Mon, Jun 07, 2010 at 02:14:25PM -0400, Miles Lane wrote:
>> Hi All,
>>
>> I just reproduced a warning I reported quite a while ago.=A0 Is a pa=
tch
>> for this in the pipeline?
>
> I proposed a patch, thinking that it was a false positive. =A0Peter Z=
ijlstra
> pointed out that there was a real race, and proposed an alternative p=
atch,
> which may be found at http://lkml.org/lkml/2010/4/22/603.
>
> Could you please test Peter's patch and let us know if it cures the p=
roblem?
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Thanx, Paul
>
>> [=A0=A0=A0 0.167267] [ INFO: suspicious rcu_dereference_check() usag=
e. ]
>> [=A0=A0=A0 0.167396] -----------------------------------------------=
----
>> [=A0=A0=A0 0.167526] include/linux/cgroup.h:534 invoked
>> rcu_dereference_check() without protection!
>> [=A0=A0=A0 0.167728]
>> [=A0=A0=A0 0.167729] other info that might help us debug this:
>> [=A0=A0=A0 0.167731]
>> [=A0=A0=A0 0.168092]
>> [=A0=A0=A0 0.168093] rcu_scheduler_active =3D 1, debug_locks =3D 1
>> [=A0=A0=A0 0.168337] no locks held by watchdog/0/5.
>> [=A0=A0=A0 0.168462]
>> [=A0=A0=A0 0.168463] stack backtrace:
>> [=A0=A0=A0 0.168704] Pid: 5, comm: watchdog/0 Not tainted 2.6.35-rc2=
-git1 #8
>> [=A0=A0=A0 0.168834] Call Trace:
>> [=A0=A0=A0 0.168965]=A0 [<ffffffff81064e9c>] lockdep_rcu_dereference=
+0x9d/0xa5
>> [=A0=A0=A0 0.169100]=A0 [<ffffffff8102c1ce>] task_subsys_state+0x59/=
0x70
>> [=A0=A0=A0 0.169232]=A0 [<ffffffff8103189b>] __sched_setscheduler+0x=
19d/0x2f8
>> [=A0=A0=A0 0.169365]=A0 [<ffffffff8102a5ef>] ? need_resched+0x1e/0x2=
8
>> [=A0=A0=A0 0.169497]=A0 [<ffffffff813c7d01>] ? schedule+0x586/0x619
>> [=A0=A0=A0 0.169628]=A0 [<ffffffff81081c33>] ? watchdog+0x0/0x8c
>> [=A0=A0=A0 0.169758]=A0 [<ffffffff81031a11>] sched_setscheduler+0xe/=
0x10
>> [=A0=A0=A0 0.169889]=A0 [<ffffffff81081c5d>] watchdog+0x2a/0x8c
>> [=A0=A0=A0 0.170010]=A0 [<ffffffff81081c33>] ? watchdog+0x0/0x8c
>> [=A0=A0=A0 0.170141]=A0 [<ffffffff81054a82>] kthread+0x89/0x91
>> [=A0=A0=A0 0.170274]=A0 [<ffffffff81003054>] kernel_thread_helper+0x=
4/0x10
>> [=A0=A0=A0 0.170405]=A0 [<ffffffff813ca480>] ? restore_args+0x0/0x30
>> [=A0=A0=A0 0.170536]=A0 [<ffffffff810549f9>] ? kthread+0x0/0x91
>> [=A0=A0=A0 0.170667]=A0 [<ffffffff81003050>] ? kernel_thread_helper+=
0x0/0x10
>> [ =A0 =A00.176751] lockdep: fixing up alternatives.
>

With the patch, I get:

[    0.151274] [ INFO: suspicious rcu_dereference_check() usage. ]
[    0.151390] ---------------------------------------------------
[    0.151520] include/linux/cgroup.h:534 invoked
rcu_dereference_check() without protection!
[    0.151723]
[    0.151724] other info that might help us debug this:
[    0.151726]
[    0.151999]
[    0.151999] rcu_scheduler_active =3D 1, debug_locks =3D 1
[    0.151999] 2 locks held by kthreadd/10:
[    0.151999]  #0:  (key){......}, at: [<ffffffff81036578>] complete+0=
x1c/0x4e
[    0.151999]  #1:  (&rq->lock){-.-...}, at: [<ffffffff81037875>]
select_task_rq_fair+0x21f/0x791
[    0.151999]
[    0.151999] stack backtrace:
[    0.151999] Pid: 10, comm: kthreadd Not tainted 2.6.35-rc2-git1 #11
[    0.151999] Call Trace:
[    0.151999]  [<ffffffff81070a45>] lockdep_rcu_dereference+0x9d/0xa5
[    0.151999]  [<ffffffff8103675e>] task_subsys_state+0x59/0x70
[    0.151999]  [<ffffffff8103799a>] select_task_rq_fair+0x344/0x791
[    0.151999]  [<ffffffff81037335>] ? task_rq_lock+0x68/0x9d
[    0.151999]  [<ffffffff811d62f3>] ? do_raw_spin_lock+0x79/0x13e
[    0.151999]  [<ffffffff81037335>] ? task_rq_lock+0x68/0x9d
[    0.151999]  [<ffffffff8103ac1e>] select_task_rq+0x13/0x44
[    0.151999]  [<ffffffff810417c3>] try_to_wake_up+0xf2/0x37d
[    0.151999]  [<ffffffff81041a5b>] default_wake_function+0xd/0xf
[    0.151999]  [<ffffffff81034272>] __wake_up_common+0x49/0x7f
[    0.151999]  [<ffffffff81036596>] complete+0x3a/0x4e
[    0.151999]  [<ffffffff8105b598>] ? worker_thread+0x0/0x3a7
[    0.151999]  [<ffffffff8105f7d0>] kthread+0x73/0x91
[    0.151999]  [<ffffffff8100aba4>] kernel_thread_helper+0x4/0x10
[    0.151999]  [<ffffffff813e3694>] ? restore_args+0x0/0x30
[    0.151999]  [<ffffffff8105f75d>] ? kthread+0x0/0x91
[    0.151999]  [<ffffffff8100aba0>] ? kernel_thread_helper+0x0/0x10
