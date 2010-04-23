From: Miles Lane <miles.lane@gmail.com>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
	rcu_dereference_check() usage
Date: Fri, 23 Apr 2010 18:59:12 -0400
Message-ID: <m2xa44ae5cd1004231559hcf90671asf146a43b4748c2c3@mail.gmail.com>
References: <20100420030452.GB2905@linux.vnet.ibm.com>
	 <1271766716.2972.16.camel@dhcp231-113.rdu.redhat.com>
	 <j2ya44ae5cd1004200545q6be4ec82o18ae99d93e8c29c7@mail.gmail.com>
	 <20100420135227.GC2628@linux.vnet.ibm.com>
	 <t2la44ae5cd1004200838w87256e80v9dcde91342b321db@mail.gmail.com>
	 <20100421213543.GO2563@linux.vnet.ibm.com>
	 <20100422145640.GB3228@redhat.com>
	 <20100422160144.GC2524@linux.vnet.ibm.com>
	 <h2xa44ae5cd1004230550uf734c89eo2b1d1945d446068c@mail.gmail.com>
	 <20100423194255.GE2589@linux.vnet.ibm.com>
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
	Li Zefan <lizf@cn.fujitsu.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.211.194]:62215 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825Ab0DWW7N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 18:59:13 -0400
In-Reply-To: <20100423194255.GE2589@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 23, 2010 at 3:42 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Fri, Apr 23, 2010 at 08:50:59AM -0400, Miles Lane wrote:
>> Hi Paul,
>> There has been a bit of back and forth, and I am not sure what patch=
es
>> I should test now.
>> Could you send me a bundle of whatever needs testing now?
>
> Hello, Miles,
>
> I am posting my set as replies to this message. =A0There are a couple
> of KVM fixes that are going up via Avi's tree, and a number of networ=
king
> fixes that are going up via Dave Miller's tree -- a number of these
> are against quickly changing code, so it didn't make sense for me to
> keep them separately.
>
> I believe that the two splats below are addressed by this patch set
> carried in the networking tree:
>
> =A0 =A0 =A0 =A0https://patchwork.kernel.org/patch/90754/

With your twelve patches and the one linked to above applied to
2.6.34-rc5-git3, here are the warnings I see:

[    0.173969] [ INFO: suspicious rcu_dereference_check() usage. ]
[    0.174097] ---------------------------------------------------
[    0.174226] include/linux/cgroup.h:534 invoked
rcu_dereference_check() without protection!
[    0.174429]
[    0.174430] other info that might help us debug this:
[    0.174431]
[    0.174792]
[    0.174793] rcu_scheduler_active =3D 1, debug_locks =3D 1
[    0.175037] no locks held by watchdog/0/5.
[    0.175162]
[    0.175163] stack backtrace:
[    0.175405] Pid: 5, comm: watchdog/0 Not tainted 2.6.34-rc5-git3 #22
[    0.175534] Call Trace:
[    0.175666]  [<ffffffff81067fbe>] lockdep_rcu_dereference+0x9d/0xa5
[    0.175799]  [<ffffffff8102d678>] task_subsys_state+0x59/0x70
[    0.175931]  [<ffffffff810328fa>] __sched_setscheduler+0x19d/0x300
[    0.176064]  [<ffffffff8102b477>] ? need_resched+0x1e/0x28
[    0.176196]  [<ffffffff813cd401>] ? schedule+0x5c3/0x66e
[    0.176327]  [<ffffffff81091943>] ? watchdog+0x0/0x8c
[    0.176457]  [<ffffffff81032a78>] sched_setscheduler+0xe/0x10
[    0.176587]  [<ffffffff8109196d>] watchdog+0x2a/0x8c
[    0.176677]  [<ffffffff81091943>] ? watchdog+0x0/0x8c
[    0.176808]  [<ffffffff81057152>] kthread+0x89/0x91
[    0.176939]  [<ffffffff8106891e>] ? trace_hardirqs_on_caller+0x114/0=
x13f
[    0.177073]  [<ffffffff81003994>] kernel_thread_helper+0x4/0x10
[    0.177204]  [<ffffffff813cfc40>] ? restore_args+0x0/0x30
[    0.177334]  [<ffffffff810570c9>] ? kthread+0x0/0x91
[    0.177463]  [<ffffffff81003990>] ? kernel_thread_helper+0x0/0x10

[    3.173419] [ INFO: suspicious rcu_dereference_check() usage. ]
[    3.173419] ---------------------------------------------------
[    3.173419] kernel/cgroup.c:4438 invoked rcu_dereference_check()
without protection!
[    3.173419]
[    3.173419] other info that might help us debug this:
[    3.173419]
[    3.173419]
[    3.173419] rcu_scheduler_active =3D 1, debug_locks =3D 1
[    3.173419] 2 locks held by async/0/668:
[    3.173419]  #0:  (&shost->scan_mutex){+.+.+.}, at:
[<ffffffff812df020>] __scsi_add_device+0x83/0xe4
[    3.173419]  #1:  (&(&blkcg->lock)->rlock){......}, at:
[<ffffffff811f2df9>] blkiocg_add_blkio_group+0x29/0x7f
[    3.173419]
[    3.173419] stack backtrace:
[    3.173419] Pid: 668, comm: async/0 Not tainted 2.6.34-rc5-git3 #22
[    3.173419] Call Trace:
[    3.173419]  [<ffffffff81067fbe>] lockdep_rcu_dereference+0x9d/0xa5
[    3.173419]  [<ffffffff8107f9ad>] css_id+0x3f/0x51
[    3.173419]  [<ffffffff811f2e08>] blkiocg_add_blkio_group+0x38/0x7f
[    3.173419]  [<ffffffff811f4dd0>] cfq_init_queue+0xdf/0x2dc
[    3.173419]  [<ffffffff811e33b1>] elevator_init+0xba/0xf5
[    3.173419]  [<ffffffff812dbfaa>] ? scsi_request_fn+0x0/0x451
[    3.173419]  [<ffffffff811e68d7>] blk_init_queue_node+0x12f/0x135
[    3.173419]  [<ffffffff811e68e9>] blk_init_queue+0xc/0xe
[    3.173419]  [<ffffffff812dc41c>] __scsi_alloc_queue+0x21/0x111
[    3.173419]  [<ffffffff812dc524>] scsi_alloc_queue+0x18/0x64
[    3.173419]  [<ffffffff812de520>] scsi_alloc_sdev+0x19e/0x256
[    3.173419]  [<ffffffff812de6be>] scsi_probe_and_add_lun+0xe6/0x9c5
[    3.173419]  [<ffffffff8106891e>] ? trace_hardirqs_on_caller+0x114/0=
x13f
[    3.173419]  [<ffffffff813ce056>] ? __mutex_lock_common+0x3e4/0x43a
[    3.173419]  [<ffffffff812df020>] ? __scsi_add_device+0x83/0xe4
[    3.173419]  [<ffffffff812d09dc>] ? transport_setup_classdev+0x0/0x1=
7
[    3.173419]  [<ffffffff812df020>] ? __scsi_add_device+0x83/0xe4
[    3.173419]  [<ffffffff812df055>] __scsi_add_device+0xb8/0xe4
[    3.173419]  [<ffffffff812ea945>] ata_scsi_scan_host+0x74/0x16e
[    3.173419]  [<ffffffff81057699>] ? autoremove_wake_function+0x0/0x3=
4
[    3.173419]  [<ffffffff812e8de4>] async_port_probe+0xab/0xb7
[    3.173419]  [<ffffffff8105e1b1>] ? async_thread+0x0/0x1f4
[    3.173419]  [<ffffffff8105e2b6>] async_thread+0x105/0x1f4
[    3.173419]  [<ffffffff81033d8e>] ? default_wake_function+0x0/0xf
[    3.173419]  [<ffffffff8105e1b1>] ? async_thread+0x0/0x1f4
[    3.173419]  [<ffffffff81057152>] kthread+0x89/0x91
[    3.173419]  [<ffffffff8106891e>] ? trace_hardirqs_on_caller+0x114/0=
x13f
[    3.173419]  [<ffffffff81003994>] kernel_thread_helper+0x4/0x10
[    3.173419]  [<ffffffff813cfc40>] ? restore_args+0x0/0x30
[    3.173419]  [<ffffffff810570c9>] ? kthread+0x0/0x91
[    3.173419]  [<ffffffff81003990>] ? kernel_thread_helper+0x0/0x10

[   32.905446] [ INFO: suspicious rcu_dereference_check() usage. ]
[   32.905449] ---------------------------------------------------
[   32.905453] net/core/dev.c:1993 invoked rcu_dereference_check()
without protection!
[   32.905456]
[   32.905457] other info that might help us debug this:
[   32.905458]
[   32.905461]
[   32.905462] rcu_scheduler_active =3D 1, debug_locks =3D 1
[   32.905466] 2 locks held by canberra-gtk-pl/4182:
[   32.905469]  #0:  (sk_lock-AF_INET){+.+.+.}, at:
[<ffffffff81394f7d>] inet_stream_connect+0x3a/0x24d
[   32.905483]  #1:  (rcu_read_lock_bh){.+....}, at:
[<ffffffff8134a789>] dev_queue_xmit+0x14e/0x4b8
[   32.905495]
[   32.905496] stack backtrace:
[   32.905500] Pid: 4182, comm: canberra-gtk-pl Not tainted 2.6.34-rc5-=
git3 #22
[   32.905504] Call Trace:
[   32.905512]  [<ffffffff81067fbe>] lockdep_rcu_dereference+0x9d/0xa5
[   32.905518]  [<ffffffff8134a894>] dev_queue_xmit+0x259/0x4b8
[   32.905524]  [<ffffffff8134a789>] ? dev_queue_xmit+0x14e/0x4b8
[   32.905531]  [<ffffffff81041c66>] ? _local_bh_enable_ip+0xcd/0xda
[   32.905538]  [<ffffffff813536da>] neigh_resolve_output+0x234/0x285
[   32.905544]  [<ffffffff8136f69f>] ip_finish_output2+0x257/0x28c
[   32.905549]  [<ffffffff8136f73c>] ip_finish_output+0x68/0x6a
[   32.905554]  [<ffffffff81370433>] T.866+0x52/0x59
[   32.905559]  [<ffffffff8137067e>] ip_output+0xaa/0xb4
[   32.905565]  [<ffffffff8136eb38>] ip_local_out+0x20/0x24
[   32.905571]  [<ffffffff8136f184>] ip_queue_xmit+0x309/0x368
[   32.905578]  [<ffffffff810e4226>] ? __kmalloc_track_caller+0x111/0x1=
55
[   32.905585]  [<ffffffff8138316f>] ? tcp_connect+0x223/0x3d3
[   32.905591]  [<ffffffff813818f1>] tcp_transmit_skb+0x707/0x745
[   32.905597]  [<ffffffff813832c2>] tcp_connect+0x376/0x3d3
[   32.905604]  [<ffffffff81268a43>] ? secure_tcp_sequence_number+0x55/=
0x6f
[   32.905610]  [<ffffffff81387270>] tcp_v4_connect+0x3df/0x455
[   32.905617]  [<ffffffff8133cb59>] ? lock_sock_nested+0xf3/0x102
[   32.905623]  [<ffffffff81394fe7>] inet_stream_connect+0xa4/0x24d
[   32.905629]  [<ffffffff8133b398>] sys_connect+0x90/0xd0
[   32.905636]  [<ffffffff81002b9c>] ? sysret_check+0x27/0x62
[   32.905642]  [<ffffffff8106891e>] ? trace_hardirqs_on_caller+0x114/0=
x13f
[   32.905649]  [<ffffffff813cec80>] ? trace_hardirqs_on_thunk+0x3a/0x3=
f
[   32.905655]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x1b

[   51.912282] [ INFO: suspicious rcu_dereference_check() usage. ]
[   51.912285] ---------------------------------------------------
[   51.912289] net/mac80211/sta_info.c:886 invoked
rcu_dereference_check() without protection!
[   51.912293]
[   51.912293] other info that might help us debug this:
[   51.912295]
[   51.912298]
[   51.912298] rcu_scheduler_active =3D 1, debug_locks =3D 1
[   51.912302] no locks held by wpa_supplicant/3951.
[   51.912305]
[   51.912306] stack backtrace:
[   51.912310] Pid: 3951, comm: wpa_supplicant Not tainted 2.6.34-rc5-g=
it3 #22
[   51.912314] Call Trace:
[   51.912317]  <IRQ>  [<ffffffff81067fbe>] lockdep_rcu_dereference+0x9=
d/0xa5
[   51.912345]  [<ffffffffa014f9ae>]
ieee80211_find_sta_by_hw+0x46/0x10f [mac80211]
[   51.912358]  [<ffffffffa014fa8e>] ieee80211_find_sta+0x17/0x19 [mac8=
0211]
[   51.912373]  [<ffffffffa01e50f2>] iwl_tx_queue_reclaim+0xdb/0x1b1 [i=
wlcore]
[   51.912380]  [<ffffffff8106842b>] ? mark_lock+0x2d/0x235
[   51.912391]  [<ffffffffa0252f1c>] iwl5000_rx_reply_tx+0x4a9/0x556 [i=
wlagn]
[   51.912399]  [<ffffffff8120a353>] ? is_swiotlb_buffer+0x2e/0x3b
[   51.912407]  [<ffffffffa024bbf4>] iwl_rx_handle+0x163/0x2b5 [iwlagn]
[   51.912414]  [<ffffffff81068904>] ? trace_hardirqs_on_caller+0xfa/0x=
13f
[   51.912422]  [<ffffffffa024c3ac>] iwl_irq_tasklet+0x2bb/0x3c0 [iwlag=
n]
[   51.912429]  [<ffffffff810411f3>] tasklet_action+0xa7/0x10f
[   51.912435]  [<ffffffff81042205>] __do_softirq+0x144/0x252
[   51.912442]  [<ffffffff81003a8c>] call_softirq+0x1c/0x34
[   51.912447]  [<ffffffff810050e4>] do_softirq+0x38/0x80
[   51.912452]  [<ffffffff81041cd2>] irq_exit+0x45/0x94
[   51.912457]  [<ffffffff81004829>] do_IRQ+0xad/0xc4
[   51.912463]  [<ffffffff810cbbd3>] ? might_fault+0x63/0xb3
[   51.912470]  [<ffffffff813cfb93>] ret_from_intr+0x0/0xf
[   51.912474]  <EOI>  [<ffffffff810cbbd3>] ? might_fault+0x63/0xb3
[   51.912484]  [<ffffffff8106a75d>] ? lock_release+0x208/0x215
[   51.912490]  [<ffffffff810cbc1c>] might_fault+0xac/0xb3
[   51.912495]  [<ffffffff810cbbd3>] ? might_fault+0x63/0xb3
[   51.912501]  [<ffffffff812025e3>] __clear_user+0x15/0x59
[   51.912508]  [<ffffffff8100b2bc>] save_i387_xstate+0x9c/0x1bc
[   51.912515]  [<ffffffff81002276>] do_signal+0x240/0x686
[   51.912521]  [<ffffffff81002b9c>] ? sysret_check+0x27/0x62
[   51.912527]  [<ffffffff8106891e>] ? trace_hardirqs_on_caller+0x114/0=
x13f
[   51.912533]  [<ffffffff813cec80>] ? trace_hardirqs_on_thunk+0x3a/0x3=
f
[   51.912539]  [<ffffffff810026e3>] do_notify_resume+0x27/0x5f
[   51.912545]  [<ffffffff813cec80>] ? trace_hardirqs_on_thunk+0x3a/0x3=
f
[   51.912551]  [<ffffffff81002e86>] int_signal+0x12/0x17

[   51.929529] [ INFO: suspicious rcu_dereference_check() usage. ]
[   51.929532] ---------------------------------------------------
[   51.929536] net/mac80211/sta_info.c:886 invoked
rcu_dereference_check() without protection!
[   51.929540]
[   51.929541] other info that might help us debug this:
[   51.929542]
[   51.929545]
[   51.929546] rcu_scheduler_active =3D 1, debug_locks =3D 1
[   51.929550] 1 lock held by Xorg/4013:
[   51.929553]  #0:  (clock-AF_UNIX){++.+..}, at: [<ffffffff8133cebd>]
sock_def_readable+0x19/0x62
[   51.929567]
[   51.929568] stack backtrace:
[   51.929573] Pid: 4013, comm: Xorg Not tainted 2.6.34-rc5-git3 #22
[   51.929576] Call Trace:
[   51.929579]  <IRQ>  [<ffffffff81067fbe>] lockdep_rcu_dereference+0x9=
d/0xa5
[   51.929603]  [<ffffffffa014f9fe>]
ieee80211_find_sta_by_hw+0x96/0x10f [mac80211]
[   51.929615]  [<ffffffffa014fa8e>] ieee80211_find_sta+0x17/0x19 [mac8=
0211]
[   51.929631]  [<ffffffffa01e50f2>] iwl_tx_queue_reclaim+0xdb/0x1b1 [i=
wlcore]
[   51.929642]  [<ffffffffa0252f1c>] iwl5000_rx_reply_tx+0x4a9/0x556 [i=
wlagn]
[   51.929649]  [<ffffffff81068685>] ? mark_held_locks+0x52/0x70
[   51.929656]  [<ffffffff813cf46c>] ? _raw_spin_unlock_irqrestore+0x3a=
/0x69
[   51.929662]  [<ffffffff8120a353>] ? is_swiotlb_buffer+0x2e/0x3b
[   51.929671]  [<ffffffffa024bbf4>] iwl_rx_handle+0x163/0x2b5 [iwlagn]
[   51.929680]  [<ffffffffa024c3ac>] iwl_irq_tasklet+0x2bb/0x3c0 [iwlag=
n]
[   51.929687]  [<ffffffff810411f3>] tasklet_action+0xa7/0x10f
[   51.929693]  [<ffffffff81042205>] __do_softirq+0x144/0x252
[   51.929700]  [<ffffffff81003a8c>] call_softirq+0x1c/0x34
[   51.929705]  [<ffffffff810050e4>] do_softirq+0x38/0x80
[   51.929711]  [<ffffffff81041cd2>] irq_exit+0x45/0x94
[   51.929717]  [<ffffffff81019b10>] smp_apic_timer_interrupt+0x87/0x95
[   51.929724]  [<ffffffff81003553>] apic_timer_interrupt+0x13/0x20
[   51.929727]  <EOI>  [<ffffffff813cf46e>] ?
_raw_spin_unlock_irqrestore+0x3c/0x69
[   51.929739]  [<ffffffff8102d3fb>] __wake_up_sync_key+0x49/0x52
[   51.929745]  [<ffffffff8133cee7>] sock_def_readable+0x43/0x62
[   51.929751]  [<ffffffff813b1c61>] unix_stream_sendmsg+0x243/0x2e2
[   51.929758]  [<ffffffff8133b912>] ? sock_aio_write+0x0/0xcf
[   51.929764]  [<ffffffff81339342>] __sock_sendmsg+0x59/0x64
[   51.929770]  [<ffffffff8133b9cd>] sock_aio_write+0xbb/0xcf
[   51.929777]  [<ffffffff810e9909>] do_sync_readv_writev+0xbc/0xfb
[   51.929785]  [<ffffffff811c1792>] ? selinux_file_permission+0xa2/0xa=
f
[   51.929790]  [<ffffffff810e9690>] ? copy_from_user+0x2a/0x2c
[   51.929797]  [<ffffffff811baff1>] ? security_file_permission+0x11/0x=
13
[   51.929804]  [<ffffffff810ea6a6>] do_readv_writev+0xa2/0x122
[   51.929810]  [<ffffffff810ead93>] ? fcheck_files+0x8f/0xc9
[   51.929816]  [<ffffffff810ea764>] vfs_writev+0x3e/0x49
[   51.929821]  [<ffffffff810ea84a>] sys_writev+0x45/0x8e
[   51.929828]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x1b
