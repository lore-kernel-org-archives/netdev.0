From: Miles Lane <miles.lane@gmail.com>
Subject: Re: 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invoked
	rcu_dereference_check() without protection!
Date: Wed, 9 Jun 2010 13:00:20 -0400
Message-ID: <AANLkTilpM9O373rA0cw_wTYVfTiDPbjaKHScAGlt7IAr@mail.gmail.com>
References: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@mail.gmail.com>
	<20100608001929.GF2387@linux.vnet.ibm.com>
	<AANLkTikl13cJNuU32JzRarrUnoh5DYHr-Tbnv9B-UjsG@mail.gmail.com>
	<1275986441.5408.111.camel@twins>
	<AANLkTimXVlgzHivCQberLdrFP8BH_nJzt8_ozUNHG_aI@mail.gmail.com>
	<1276004075.2987.208.camel@twins>
	<AANLkTil6ucLZ0A6tWx-OQt_2EeKnx8nSx6rIg2t1L2t5@mail.gmail.com>
	<1276097068.1745.13.camel@laptop>
	<AANLkTinl2JKUX6859Ioa1y0DqHWXH5TrkissQ8BAF4cP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Vivek Goyal <vgoyal@redhat.com>,
	Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:55411 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347Ab0FIRAW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 13:00:22 -0400
Received: by wwb31 with SMTP id 31so435394wwb.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 10:00:20 -0700 (PDT)
In-Reply-To: <AANLkTinl2JKUX6859Ioa1y0DqHWXH5TrkissQ8BAF4cP@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 9, 2010 at 11:29 AM, Miles Lane <miles.lane@gmail.com> wrot=
e:
> On Wed, Jun 9, 2010 at 11:24 AM, Peter Zijlstra <peterz@infradead.org=
> wrote:
>> On Wed, 2010-06-09 at 11:11 -0400, Miles Lane wrote:
>>>
>>> Sorry. =A0I misunderstood this message when I first read it. =A0I d=
idn't
>>> realize this message include a new version of the patch.
>>> Anyhow, I just tried to apply the patch to 2.6.35-rc2-git3 and got =
this:
>>>
>>> # patch -p1 -l -F 20 --dry-run < ../5.patch
>>> patching file include/linux/cgroup.h
>>> patching file kernel/sched.c
>>> Hunk #1 succeeded at 306 with fuzz 1.
>>> Hunk #3 FAILED at 4462.
>>> Hunk #4 succeeded at 4487 with fuzz 3.
>>> 1 out of 4 hunks FAILED -- saving rejects to file kernel/sched.c.re=
j
>>
>> Weird.. it seems to apply without trouble to Linus' git tree.
>>
>> root@twins:/usr/src/linux-2.6# git checkout -f origin/master
>> HEAD is now at 84f7586... Merge branch 'for-linus' of git://git.kern=
el.org/pub/scm/linux/kernel/git/ieee1394/linux1394-2.6
>> root@twins:/usr/src/linux-2.6# quilt push
>> Applying patch patches/sched-rcu-validation.patch
>> patching file include/linux/cgroup.h
>> patching file kernel/sched.c
>>
>> Now at patch patches/sched-rcu-validation.patch
>> root@twins:/usr/src/linux-2.6# git describe
>> v2.6.35-rc2-54-g84f7586
>
> Oh. =A0Duh. I know what is going on. =A0I had received another patch =
to
> sched.c. =A0They must conflict. =A0I will test with just your patch n=
ow.
>

ACPI: Core revision 20100428
[    0.061088]
[    0.061090] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
[    0.062009] [ INFO: suspicious rcu_dereference_check() usage. ]
[    0.062138] ---------------------------------------------------
[    0.062268] kernel/sched.c:616 invoked rcu_dereference_check()
without protection!
[    0.062470]
[    0.062471] other info that might help us debug this:
[    0.062472]
[    0.062835]
[    0.062836] rcu_scheduler_active =3D 1, debug_locks =3D 1
[    0.063009] no locks held by swapper/0.
[    0.063134]
[    0.063135] stack backtrace:
[    0.063378] Pid: 0, comm: swapper Not tainted 2.6.35-rc2-git3 #3
[    0.063507] Call Trace:
[    0.063638]  [<ffffffff81072205>] lockdep_rcu_dereference+0x9d/0xa5
[    0.063773]  [<ffffffff810379f9>] task_group+0x7b/0x8a
[    0.064012]  [<ffffffff81037a1d>] set_task_rq+0x15/0x6e
[    0.064143]  [<ffffffff8103e50f>] set_task_cpu+0xa9/0xba
[    0.064274]  [<ffffffff81042dbb>] sched_fork+0x10a/0x1b3
[    0.064405]  [<ffffffff810446f9>] copy_process+0x617/0x10e6
[    0.064537]  [<ffffffff8104533d>] do_fork+0x175/0x39b
[    0.064670]  [<ffffffff8106589b>] ? up+0xf/0x39
[    0.064800]  [<ffffffff8106589b>] ? up+0xf/0x39
[    0.065013]  [<ffffffff811dbf73>] ? do_raw_spin_lock+0x79/0x13e
[    0.065148]  [<ffffffff81011526>] kernel_thread+0x70/0x72
[    0.065279]  [<ffffffff816cc5e4>] ? kernel_init+0x0/0x1ce
[    0.065411]  [<ffffffff8100aba0>] ? kernel_thread_helper+0x0/0x10
[    0.065545]  [<ffffffff81096bea>] ? rcu_scheduler_starting+0x2a/0x4c
[    0.065679]  [<ffffffff813a8a4d>] rest_init+0x21/0xde
[    0.065810]  [<ffffffff816cce28>] start_kernel+0x448/0x453
[    0.066013]  [<ffffffff816cc2c8>] x86_64_start_reservations+0xb3/0xb=
7
[    0.066148]  [<ffffffff816cc418>] x86_64_start_kernel+0x14c/0x15b
[    0.066499] Setting APIC routing to flat
