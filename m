From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Wed, 22 Oct 2014 12:53:24 -0500
Message-ID: <8738aghtyj.fsf@x220.int.ebiederm.org>
References: <20141020141515.0688bf33@voldemort.scrye.com>
	<20141020204326.GA25668@redhat.com>
	<20141020145359.565fe5e6@voldemort.scrye.com>
	<20141021151225.5df96645@voldemort.scrye.com>
	<CA+5PVA7Ro_ejBUqsZ9StWVeu59==fGnj6e4Gx8zM4_3+Lq5s4A@mail.gmail.com>
	<CAHA+R7OUHy8XFPoip5gPvr1uqwkxgKxoSMf_pSgB1aFx=XCs8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Josh Boyer <jwboyer@fedoraproject.org>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel\@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7OUHy8XFPoip5gPvr1uqwkxgKxoSMf_pSgB1aFx=XCs8g@mail.gmail.com>
	(Cong Wang's message of "Wed, 22 Oct 2014 10:37:53 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cong Wang <cwang@twopensource.com> writes:

> (Adding Paul and Eric in Cc)
>
>
> On Wed, Oct 22, 2014 at 10:12 AM, Josh Boyer <jwboyer@fedoraproject.org> wrote:
>>
>> Someone else is seeing this when they try and modprobe ppp_generic:
>>
>> [  240.599195] INFO: task kworker/u16:5:100 blocked for more than 120 seconds.
>> [  240.599338]       Not tainted 3.18.0-0.rc1.git2.1.fc22.x86_64 #1
>> [  240.599446] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
>> disables this message.
>> [  240.599583] kworker/u16:5   D ffff8802202db480 12400   100      2 0x00000000
>> [  240.599744] Workqueue: netns cleanup_net
>> [  240.599823]  ffff8802202eb9e8 0000000000000096 ffff8802202db480
>> 00000000001d5f00
>> [  240.600066]  ffff8802202ebfd8 00000000001d5f00 ffff8800368c3480
>> ffff8802202db480
>> [  240.600228]  ffffffff81ee2690 7fffffffffffffff ffffffff81ee2698
>> ffffffff81ee2690
>> [  240.600386] Call Trace:
>> [  240.600445]  [<ffffffff8185e239>] schedule+0x29/0x70
>> [  240.600541]  [<ffffffff8186345c>] schedule_timeout+0x26c/0x410
>> [  240.600651]  [<ffffffff81865ef7>] ? retint_restore_args+0x13/0x13
>> [  240.600765]  [<ffffffff818644e4>] ? _raw_spin_unlock_irq+0x34/0x50
>> [  240.600879]  [<ffffffff8185fc6c>] wait_for_completion+0x10c/0x150
>> [  240.601025]  [<ffffffff810e53e0>] ? wake_up_state+0x20/0x20
>> [  240.601133]  [<ffffffff8112a749>] _rcu_barrier+0x159/0x200
>> [  240.601237]  [<ffffffff8112a845>] rcu_barrier+0x15/0x20
>> [  240.601335]  [<ffffffff81718ebf>] netdev_run_todo+0x6f/0x310
>> [  240.601442]  [<ffffffff8170da85>] ? rollback_registered_many+0x265/0x2e0
>> [  240.601564]  [<ffffffff81725f2e>] rtnl_unlock+0xe/0x10
>> [  240.601660]  [<ffffffff8170f8e6>] default_device_exit_batch+0x156/0x180
>> [  240.601781]  [<ffffffff810fd8a0>] ? abort_exclusive_wait+0xb0/0xb0
>> [  240.601895]  [<ffffffff81707993>] ops_exit_list.isra.1+0x53/0x60
>> [  240.602028]  [<ffffffff81708540>] cleanup_net+0x100/0x1f0
>> [  240.602131]  [<ffffffff810ccfa8>] process_one_work+0x218/0x850
>> [  240.602241]  [<ffffffff810ccf0f>] ? process_one_work+0x17f/0x850
>> [  240.602350]  [<ffffffff810cd6c7>] ? worker_thread+0xe7/0x4a0
>> [  240.602454]  [<ffffffff810cd64b>] worker_thread+0x6b/0x4a0
>> [  240.602555]  [<ffffffff810cd5e0>] ? process_one_work+0x850/0x850
>> [  240.602665]  [<ffffffff810d399b>] kthread+0x10b/0x130
>> [  240.602762]  [<ffffffff81028cc9>] ? sched_clock+0x9/0x10
>> [  240.602862]  [<ffffffff810d3890>] ? kthread_create_on_node+0x250/0x250
>> [  240.603004]  [<ffffffff818651fc>] ret_from_fork+0x7c/0xb0
>> [  240.603106]  [<ffffffff810d3890>] ? kthread_create_on_node+0x250/0x250
>> [  240.603224] 4 locks held by kworker/u16:5/100:
>> [  240.603304]  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff810ccf0f>]
>> process_one_work+0x17f/0x850
>> [  240.603495]  #1:  (net_cleanup_work){+.+.+.}, at:
>> [<ffffffff810ccf0f>] process_one_work+0x17f/0x850
>> [  240.603691]  #2:  (net_mutex){+.+.+.}, at: [<ffffffff817084cc>]
>> cleanup_net+0x8c/0x1f0
>> [  240.603869]  #3:  (rcu_sched_state.barrier_mutex){+.+...}, at:
>> [<ffffffff8112a625>] _rcu_barrier+0x35/0x200
>> [  240.604211] INFO: task modprobe:1387 blocked for more than 120 seconds.
>> [  240.604329]       Not tainted 3.18.0-0.rc1.git2.1.fc22.x86_64 #1
>> [  240.604434] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
>> disables this message.
>> [  240.604570] modprobe        D ffff8800cb4f1a40 13112  1387   1386 0x00000080
>> [  240.604719]  ffff8800cafbbbe8 0000000000000096 ffff8800cb4f1a40
>> 00000000001d5f00
>> [  240.604878]  ffff8800cafbbfd8 00000000001d5f00 ffff880223280000
>> ffff8800cb4f1a40
>> [  240.605068]  ffff8800cb4f1a40 ffffffff81f8fb48 0000000000000246
>> ffff8800cb4f1a40
>> [  240.605228] Call Trace:
>> [  240.605283]  [<ffffffff8185e7e1>] schedule_preempt_disabled+0x31/0x80
>> [  240.605400]  [<ffffffff81860033>] mutex_lock_nested+0x183/0x440
>> [  240.605510]  [<ffffffff8170835f>] ? register_pernet_subsys+0x1f/0x50
>> [  240.605626]  [<ffffffff8170835f>] ? register_pernet_subsys+0x1f/0x50
>> [  240.605757]  [<ffffffffa0701000>] ? 0xffffffffa0701000
>> [  240.605854]  [<ffffffff8170835f>] register_pernet_subsys+0x1f/0x50
>> [  240.606005]  [<ffffffffa0701048>] br_init+0x48/0xd3 [bridge]
>> [  240.606112]  [<ffffffff81002148>] do_one_initcall+0xd8/0x210
>> [  240.606224]  [<ffffffff81153c02>] load_module+0x20c2/0x2870
>> [  240.606327]  [<ffffffff8114ebe0>] ? store_uevent+0x70/0x70
>> [  240.606433]  [<ffffffff8110ac26>] ? lock_release_non_nested+0x3c6/0x3d0
>> [  240.606557]  [<ffffffff81154497>] SyS_init_module+0xe7/0x140
>> [  240.606664]  [<ffffffff818652a9>] system_call_fastpath+0x12/0x17
>> [  240.606773] 1 lock held by modprobe/1387:
>> [  240.606845]  #0:  (net_mutex){+.+.+.}, at: [<ffffffff8170835f>]
>> register_pernet_subsys+0x1f/0x50
>> [  240.607114] INFO: task modprobe:1466 blocked for more than 120 seconds.
>> [  240.607231]       Not tainted 3.18.0-0.rc1.git2.1.fc22.x86_64 #1
>> [  240.607337] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
>> disables this message.
>> [  240.607473] modprobe        D ffff88020fbab480 13096  1466   1399 0x00000084
>> [  240.607622]  ffff88020d1bbbe8 0000000000000096 ffff88020fbab480
>> 00000000001d5f00
>> [  240.607791]  ffff88020d1bbfd8 00000000001d5f00 ffffffff81e1b580
>> ffff88020fbab480
>> [  240.607949]  ffff88020fbab480 ffffffff81f8fb48 0000000000000246
>> ffff88020fbab480
>> [  240.608138] Call Trace:
>> [  240.608193]  [<ffffffff8185e7e1>] schedule_preempt_disabled+0x31/0x80
>> [  240.608316]  [<ffffffff81860033>] mutex_lock_nested+0x183/0x440
>> [  240.608425]  [<ffffffff817083ad>] ? register_pernet_device+0x1d/0x70
>> [  240.608542]  [<ffffffff817083ad>] ? register_pernet_device+0x1d/0x70
>> [  240.608662]  [<ffffffffa071d000>] ? 0xffffffffa071d000
>> [  240.608759]  [<ffffffff817083ad>] register_pernet_device+0x1d/0x70
>> [  240.608881]  [<ffffffffa071d020>] ppp_init+0x20/0x1000 [ppp_generic]
>> [  240.609021]  [<ffffffff81002148>] do_one_initcall+0xd8/0x210
>> [  240.609131]  [<ffffffff81153c02>] load_module+0x20c2/0x2870
>> [  240.609235]  [<ffffffff8114ebe0>] ? store_uevent+0x70/0x70
>> [  240.609339]  [<ffffffff8110ac26>] ? lock_release_non_nested+0x3c6/0x3d0
>> [  240.609462]  [<ffffffff81154497>] SyS_init_module+0xe7/0x140
>> [  240.609568]  [<ffffffff818652a9>] system_call_fastpath+0x12/0x17
>> [  240.609677] 1 lock held by modprobe/1466:
>> [  240.609749]  #0:  (net_mutex){+.+.+.}, at: [<ffffffff817083ad>]
>> register_pernet_device+0x1d/0x70
>>
>> Looks like contention on net_mutex or something, but I honestly have
>> no idea yet.  I can't recreate it myself at the moment or I would
>> bisect.
>>
>> Has nobody else run into this with the pre-3.18 kernels?  Fedora isn't
>> carrying any patches in this area.

> I am not aware of any change in net/core/dev.c related here,
> so I guess it's a bug in rcu_barrier().

>From the limited trace data I see in this email I have to agree.

It looks like for some reason rcu_barrier is taking forever
while the rtnl_lock is held in cleanup_net.  Because the
rtnl_lock is held modprobe of the ppp driver is getting stuck.

Is it possible we have an AB BA deadlock between the rtnl_lock
and rcu.  With something the module loading code assumes?

Eric
