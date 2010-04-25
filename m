From: Miles Lane <miles.lane@gmail.com>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
	rcu_dereference_check() usage
Date: Sun, 25 Apr 2010 11:49:28 -0400
Message-ID: <w2sa44ae5cd1004250849q73704370vc6af935c70db9b73@mail.gmail.com>
References: <1271766716.2972.16.camel@dhcp231-113.rdu.redhat.com>
	 <20100420135227.GC2628@linux.vnet.ibm.com>
	 <t2la44ae5cd1004200838w87256e80v9dcde91342b321db@mail.gmail.com>
	 <20100421213543.GO2563@linux.vnet.ibm.com>
	 <20100422145640.GB3228@redhat.com>
	 <20100422160144.GC2524@linux.vnet.ibm.com>
	 <h2xa44ae5cd1004230550uf734c89eo2b1d1945d446068c@mail.gmail.com>
	 <20100423194255.GE2589@linux.vnet.ibm.com>
	 <m2xa44ae5cd1004231559hcf90671asf146a43b4748c2c3@mail.gmail.com>
	 <20100425023455.GM2440@linux.vnet.ibm.com>
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
Received: from mail-gy0-f174.google.com ([209.85.160.174]:40640 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068Ab0DYPta convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 11:49:30 -0400
In-Reply-To: <20100425023455.GM2440@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 24, 2010 at 10:34 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Fri, Apr 23, 2010 at 06:59:12PM -0400, Miles Lane wrote:
>> On Fri, Apr 23, 2010 at 3:42 PM, Paul E. McKenney
>> <paulmck@linux.vnet.ibm.com> wrote:
>> > On Fri, Apr 23, 2010 at 08:50:59AM -0400, Miles Lane wrote:
>> >> Hi Paul,
>> >> There has been a bit of back and forth, and I am not sure what pa=
tches
>> >> I should test now.
>> >> Could you send me a bundle of whatever needs testing now?
>> >
>> > Hello, Miles,
>> >
>> > I am posting my set as replies to this message. =A0There are a cou=
ple
>> > of KVM fixes that are going up via Avi's tree, and a number of net=
working
>> > fixes that are going up via Dave Miller's tree -- a number of thes=
e
>> > are against quickly changing code, so it didn't make sense for me =
to
>> > keep them separately.
>> >
>> > I believe that the two splats below are addressed by this patch se=
t
>> > carried in the networking tree:
>> >
>> > =A0 =A0 =A0 =A0https://patchwork.kernel.org/patch/90754/
>>
>> With your twelve patches and the one linked to above applied to
>> 2.6.34-rc5-git3, here are the warnings I see:
>>
>> [ =A0 =A00.173969] [ INFO: suspicious rcu_dereference_check() usage.=
 ]
>> [ =A0 =A00.174097] -------------------------------------------------=
--
>> [ =A0 =A00.174226] include/linux/cgroup.h:534 invoked
>> rcu_dereference_check() without protection!
>> [ =A0 =A00.174429]
>> [ =A0 =A00.174430] other info that might help us debug this:
>> [ =A0 =A00.174431]
>> [ =A0 =A00.174792]
>> [ =A0 =A00.174793] rcu_scheduler_active =3D 1, debug_locks =3D 1
>> [ =A0 =A00.175037] no locks held by watchdog/0/5.
>> [ =A0 =A00.175162]
>> [ =A0 =A00.175163] stack backtrace:
>> [ =A0 =A00.175405] Pid: 5, comm: watchdog/0 Not tainted 2.6.34-rc5-g=
it3 #22
>> [ =A0 =A00.175534] Call Trace:
>> [ =A0 =A00.175666] =A0[<ffffffff81067fbe>] lockdep_rcu_dereference+0=
x9d/0xa5
>> [ =A0 =A00.175799] =A0[<ffffffff8102d678>] task_subsys_state+0x59/0x=
70
>> [ =A0 =A00.175931] =A0[<ffffffff810328fa>] __sched_setscheduler+0x19=
d/0x300
>> [ =A0 =A00.176064] =A0[<ffffffff8102b477>] ? need_resched+0x1e/0x28
>> [ =A0 =A00.176196] =A0[<ffffffff813cd401>] ? schedule+0x5c3/0x66e
>> [ =A0 =A00.176327] =A0[<ffffffff81091943>] ? watchdog+0x0/0x8c
>> [ =A0 =A00.176457] =A0[<ffffffff81032a78>] sched_setscheduler+0xe/0x=
10
>> [ =A0 =A00.176587] =A0[<ffffffff8109196d>] watchdog+0x2a/0x8c
>> [ =A0 =A00.176677] =A0[<ffffffff81091943>] ? watchdog+0x0/0x8c
>> [ =A0 =A00.176808] =A0[<ffffffff81057152>] kthread+0x89/0x91
>> [ =A0 =A00.176939] =A0[<ffffffff8106891e>] ? trace_hardirqs_on_calle=
r+0x114/0x13f
>> [ =A0 =A00.177073] =A0[<ffffffff81003994>] kernel_thread_helper+0x4/=
0x10
>> [ =A0 =A00.177204] =A0[<ffffffff813cfc40>] ? restore_args+0x0/0x30
>> [ =A0 =A00.177334] =A0[<ffffffff810570c9>] ? kthread+0x0/0x91
>> [ =A0 =A00.177463] =A0[<ffffffff81003990>] ? kernel_thread_helper+0x=
0/0x10
>
> According to Documentation/cgroups/cgroups.txt, we must hold cgroup_m=
utex,
> the task's task_alloc lock, or be in an RCU read-side critical sectio=
n.
> We are in neither of these.
>
> I would argue that sched_setscheduler() should take care of
> synchronization, but am not sure which of these three are appropriate
> for sched_setscheduler() to acquire. =A0Peter, thoughts?
>
>> [ =A0 =A03.173419] [ INFO: suspicious rcu_dereference_check() usage.=
 ]
>> [ =A0 =A03.173419] -------------------------------------------------=
--
>> [ =A0 =A03.173419] kernel/cgroup.c:4438 invoked rcu_dereference_chec=
k()
>> without protection!
>> [ =A0 =A03.173419]
>> [ =A0 =A03.173419] other info that might help us debug this:
>> [ =A0 =A03.173419]
>> [ =A0 =A03.173419]
>> [ =A0 =A03.173419] rcu_scheduler_active =3D 1, debug_locks =3D 1
>> [ =A0 =A03.173419] 2 locks held by async/0/668:
>> [ =A0 =A03.173419] =A0#0: =A0(&shost->scan_mutex){+.+.+.}, at:
>> [<ffffffff812df020>] __scsi_add_device+0x83/0xe4
>> [ =A0 =A03.173419] =A0#1: =A0(&(&blkcg->lock)->rlock){......}, at:
>> [<ffffffff811f2df9>] blkiocg_add_blkio_group+0x29/0x7f
>> [ =A0 =A03.173419]
>> [ =A0 =A03.173419] stack backtrace:
>> [ =A0 =A03.173419] Pid: 668, comm: async/0 Not tainted 2.6.34-rc5-gi=
t3 #22
>> [ =A0 =A03.173419] Call Trace:
>> [ =A0 =A03.173419] =A0[<ffffffff81067fbe>] lockdep_rcu_dereference+0=
x9d/0xa5
>> [ =A0 =A03.173419] =A0[<ffffffff8107f9ad>] css_id+0x3f/0x51
>> [ =A0 =A03.173419] =A0[<ffffffff811f2e08>] blkiocg_add_blkio_group+0=
x38/0x7f
>> [ =A0 =A03.173419] =A0[<ffffffff811f4dd0>] cfq_init_queue+0xdf/0x2dc
>> [ =A0 =A03.173419] =A0[<ffffffff811e33b1>] elevator_init+0xba/0xf5
>> [ =A0 =A03.173419] =A0[<ffffffff812dbfaa>] ? scsi_request_fn+0x0/0x4=
51
>> [ =A0 =A03.173419] =A0[<ffffffff811e68d7>] blk_init_queue_node+0x12f=
/0x135
>> [ =A0 =A03.173419] =A0[<ffffffff811e68e9>] blk_init_queue+0xc/0xe
>> [ =A0 =A03.173419] =A0[<ffffffff812dc41c>] __scsi_alloc_queue+0x21/0=
x111
>> [ =A0 =A03.173419] =A0[<ffffffff812dc524>] scsi_alloc_queue+0x18/0x6=
4
>> [ =A0 =A03.173419] =A0[<ffffffff812de520>] scsi_alloc_sdev+0x19e/0x2=
56
>> [ =A0 =A03.173419] =A0[<ffffffff812de6be>] scsi_probe_and_add_lun+0x=
e6/0x9c5
>> [ =A0 =A03.173419] =A0[<ffffffff8106891e>] ? trace_hardirqs_on_calle=
r+0x114/0x13f
>> [ =A0 =A03.173419] =A0[<ffffffff813ce056>] ? __mutex_lock_common+0x3=
e4/0x43a
>> [ =A0 =A03.173419] =A0[<ffffffff812df020>] ? __scsi_add_device+0x83/=
0xe4
>> [ =A0 =A03.173419] =A0[<ffffffff812d09dc>] ? transport_setup_classde=
v+0x0/0x17
>> [ =A0 =A03.173419] =A0[<ffffffff812df020>] ? __scsi_add_device+0x83/=
0xe4
>> [ =A0 =A03.173419] =A0[<ffffffff812df055>] __scsi_add_device+0xb8/0x=
e4
>> [ =A0 =A03.173419] =A0[<ffffffff812ea945>] ata_scsi_scan_host+0x74/0=
x16e
>> [ =A0 =A03.173419] =A0[<ffffffff81057699>] ? autoremove_wake_functio=
n+0x0/0x34
>> [ =A0 =A03.173419] =A0[<ffffffff812e8de4>] async_port_probe+0xab/0xb=
7
>> [ =A0 =A03.173419] =A0[<ffffffff8105e1b1>] ? async_thread+0x0/0x1f4
>> [ =A0 =A03.173419] =A0[<ffffffff8105e2b6>] async_thread+0x105/0x1f4
>> [ =A0 =A03.173419] =A0[<ffffffff81033d8e>] ? default_wake_function+0=
x0/0xf
>> [ =A0 =A03.173419] =A0[<ffffffff8105e1b1>] ? async_thread+0x0/0x1f4
>> [ =A0 =A03.173419] =A0[<ffffffff81057152>] kthread+0x89/0x91
>> [ =A0 =A03.173419] =A0[<ffffffff8106891e>] ? trace_hardirqs_on_calle=
r+0x114/0x13f
>> [ =A0 =A03.173419] =A0[<ffffffff81003994>] kernel_thread_helper+0x4/=
0x10
>> [ =A0 =A03.173419] =A0[<ffffffff813cfc40>] ? restore_args+0x0/0x30
>> [ =A0 =A03.173419] =A0[<ffffffff810570c9>] ? kthread+0x0/0x91
>> [ =A0 =A03.173419] =A0[<ffffffff81003990>] ? kernel_thread_helper+0x=
0/0x10
>
> Please see below for a patch for this based on my earlier conversatio=
n
> with Vivek Goyal. =A0(Vivek, if you are already pushing a fix elsewhe=
re,
> please let me know, and I will drop my patch in favor of yours.)
>
>> [ =A0 32.905446] [ INFO: suspicious rcu_dereference_check() usage. ]
>> [ =A0 32.905449] ---------------------------------------------------
>> [ =A0 32.905453] net/core/dev.c:1993 invoked rcu_dereference_check()
>> without protection!
>> [ =A0 32.905456]
>> [ =A0 32.905457] other info that might help us debug this:
>> [ =A0 32.905458]
>> [ =A0 32.905461]
>> [ =A0 32.905462] rcu_scheduler_active =3D 1, debug_locks =3D 1
>> [ =A0 32.905466] 2 locks held by canberra-gtk-pl/4182:
>> [ =A0 32.905469] =A0#0: =A0(sk_lock-AF_INET){+.+.+.}, at:
>> [<ffffffff81394f7d>] inet_stream_connect+0x3a/0x24d
>> [ =A0 32.905483] =A0#1: =A0(rcu_read_lock_bh){.+....}, at:
>> [<ffffffff8134a789>] dev_queue_xmit+0x14e/0x4b8
>> [ =A0 32.905495]
>> [ =A0 32.905496] stack backtrace:
>> [ =A0 32.905500] Pid: 4182, comm: canberra-gtk-pl Not tainted 2.6.34=
-rc5-git3 #22
>> [ =A0 32.905504] Call Trace:
>> [ =A0 32.905512] =A0[<ffffffff81067fbe>] lockdep_rcu_dereference+0x9=
d/0xa5
>> [ =A0 32.905518] =A0[<ffffffff8134a894>] dev_queue_xmit+0x259/0x4b8
>> [ =A0 32.905524] =A0[<ffffffff8134a789>] ? dev_queue_xmit+0x14e/0x4b=
8
>> [ =A0 32.905531] =A0[<ffffffff81041c66>] ? _local_bh_enable_ip+0xcd/=
0xda
>> [ =A0 32.905538] =A0[<ffffffff813536da>] neigh_resolve_output+0x234/=
0x285
>> [ =A0 32.905544] =A0[<ffffffff8136f69f>] ip_finish_output2+0x257/0x2=
8c
>> [ =A0 32.905549] =A0[<ffffffff8136f73c>] ip_finish_output+0x68/0x6a
>> [ =A0 32.905554] =A0[<ffffffff81370433>] T.866+0x52/0x59
>> [ =A0 32.905559] =A0[<ffffffff8137067e>] ip_output+0xaa/0xb4
>> [ =A0 32.905565] =A0[<ffffffff8136eb38>] ip_local_out+0x20/0x24
>> [ =A0 32.905571] =A0[<ffffffff8136f184>] ip_queue_xmit+0x309/0x368
>> [ =A0 32.905578] =A0[<ffffffff810e4226>] ? __kmalloc_track_caller+0x=
111/0x155
>> [ =A0 32.905585] =A0[<ffffffff8138316f>] ? tcp_connect+0x223/0x3d3
>> [ =A0 32.905591] =A0[<ffffffff813818f1>] tcp_transmit_skb+0x707/0x74=
5
>> [ =A0 32.905597] =A0[<ffffffff813832c2>] tcp_connect+0x376/0x3d3
>> [ =A0 32.905604] =A0[<ffffffff81268a43>] ? secure_tcp_sequence_numbe=
r+0x55/0x6f
>> [ =A0 32.905610] =A0[<ffffffff81387270>] tcp_v4_connect+0x3df/0x455
>> [ =A0 32.905617] =A0[<ffffffff8133cb59>] ? lock_sock_nested+0xf3/0x1=
02
>> [ =A0 32.905623] =A0[<ffffffff81394fe7>] inet_stream_connect+0xa4/0x=
24d
>> [ =A0 32.905629] =A0[<ffffffff8133b398>] sys_connect+0x90/0xd0
>> [ =A0 32.905636] =A0[<ffffffff81002b9c>] ? sysret_check+0x27/0x62
>> [ =A0 32.905642] =A0[<ffffffff8106891e>] ? trace_hardirqs_on_caller+=
0x114/0x13f
>> [ =A0 32.905649] =A0[<ffffffff813cec80>] ? trace_hardirqs_on_thunk+0=
x3a/0x3f
>> [ =A0 32.905655] =A0[<ffffffff81002b6b>] system_call_fastpath+0x16/0=
x1b
>
> A fix for the above is already in Dave Miller's tree.
>
>> [ =A0 51.912282] [ INFO: suspicious rcu_dereference_check() usage. ]
>> [ =A0 51.912285] ---------------------------------------------------
>> [ =A0 51.912289] net/mac80211/sta_info.c:886 invoked
>> rcu_dereference_check() without protection!
>> [ =A0 51.912293]
>> [ =A0 51.912293] other info that might help us debug this:
>> [ =A0 51.912295]
>> [ =A0 51.912298]
>> [ =A0 51.912298] rcu_scheduler_active =3D 1, debug_locks =3D 1
>> [ =A0 51.912302] no locks held by wpa_supplicant/3951.
>> [ =A0 51.912305]
>> [ =A0 51.912306] stack backtrace:
>> [ =A0 51.912310] Pid: 3951, comm: wpa_supplicant Not tainted 2.6.34-=
rc5-git3 #22
>> [ =A0 51.912314] Call Trace:
>> [ =A0 51.912317] =A0<IRQ> =A0[<ffffffff81067fbe>] lockdep_rcu_derefe=
rence+0x9d/0xa5
>> [ =A0 51.912345] =A0[<ffffffffa014f9ae>]
>> ieee80211_find_sta_by_hw+0x46/0x10f [mac80211]
>> [ =A0 51.912358] =A0[<ffffffffa014fa8e>] ieee80211_find_sta+0x17/0x1=
9 [mac80211]
>> [ =A0 51.912373] =A0[<ffffffffa01e50f2>] iwl_tx_queue_reclaim+0xdb/0=
x1b1 [iwlcore]
>> [ =A0 51.912380] =A0[<ffffffff8106842b>] ? mark_lock+0x2d/0x235
>> [ =A0 51.912391] =A0[<ffffffffa0252f1c>] iwl5000_rx_reply_tx+0x4a9/0=
x556 [iwlagn]
>> [ =A0 51.912399] =A0[<ffffffff8120a353>] ? is_swiotlb_buffer+0x2e/0x=
3b
>> [ =A0 51.912407] =A0[<ffffffffa024bbf4>] iwl_rx_handle+0x163/0x2b5 [=
iwlagn]
>> [ =A0 51.912414] =A0[<ffffffff81068904>] ? trace_hardirqs_on_caller+=
0xfa/0x13f
>> [ =A0 51.912422] =A0[<ffffffffa024c3ac>] iwl_irq_tasklet+0x2bb/0x3c0=
 [iwlagn]
>> [ =A0 51.912429] =A0[<ffffffff810411f3>] tasklet_action+0xa7/0x10f
>> [ =A0 51.912435] =A0[<ffffffff81042205>] __do_softirq+0x144/0x252
>> [ =A0 51.912442] =A0[<ffffffff81003a8c>] call_softirq+0x1c/0x34
>> [ =A0 51.912447] =A0[<ffffffff810050e4>] do_softirq+0x38/0x80
>> [ =A0 51.912452] =A0[<ffffffff81041cd2>] irq_exit+0x45/0x94
>> [ =A0 51.912457] =A0[<ffffffff81004829>] do_IRQ+0xad/0xc4
>> [ =A0 51.912463] =A0[<ffffffff810cbbd3>] ? might_fault+0x63/0xb3
>> [ =A0 51.912470] =A0[<ffffffff813cfb93>] ret_from_intr+0x0/0xf
>> [ =A0 51.912474] =A0<EOI> =A0[<ffffffff810cbbd3>] ? might_fault+0x63=
/0xb3
>> [ =A0 51.912484] =A0[<ffffffff8106a75d>] ? lock_release+0x208/0x215
>> [ =A0 51.912490] =A0[<ffffffff810cbc1c>] might_fault+0xac/0xb3
>> [ =A0 51.912495] =A0[<ffffffff810cbbd3>] ? might_fault+0x63/0xb3
>> [ =A0 51.912501] =A0[<ffffffff812025e3>] __clear_user+0x15/0x59
>> [ =A0 51.912508] =A0[<ffffffff8100b2bc>] save_i387_xstate+0x9c/0x1bc
>> [ =A0 51.912515] =A0[<ffffffff81002276>] do_signal+0x240/0x686
>> [ =A0 51.912521] =A0[<ffffffff81002b9c>] ? sysret_check+0x27/0x62
>> [ =A0 51.912527] =A0[<ffffffff8106891e>] ? trace_hardirqs_on_caller+=
0x114/0x13f
>> [ =A0 51.912533] =A0[<ffffffff813cec80>] ? trace_hardirqs_on_thunk+0=
x3a/0x3f
>> [ =A0 51.912539] =A0[<ffffffff810026e3>] do_notify_resume+0x27/0x5f
>> [ =A0 51.912545] =A0[<ffffffff813cec80>] ? trace_hardirqs_on_thunk+0=
x3a/0x3f
>> [ =A0 51.912551] =A0[<ffffffff81002e86>] int_signal+0x12/0x17
>
> This is a repeat from last time that confused me at the time. =A0I co=
uld
> do a hacky "fix" by putting an RCU read-side critical section around
> the for_each_sta_info() in ieee80211_find_sta_by_hw(), but I do not
> understand this code well enough to feel comfortable doing so.
>
> Johannes, any enlightenment?
>
>> [ =A0 51.929529] [ INFO: suspicious rcu_dereference_check() usage. ]
>> [ =A0 51.929532] ---------------------------------------------------
>> [ =A0 51.929536] net/mac80211/sta_info.c:886 invoked
>> rcu_dereference_check() without protection!
>> [ =A0 51.929540]
>> [ =A0 51.929541] other info that might help us debug this:
>> [ =A0 51.929542]
>> [ =A0 51.929545]
>> [ =A0 51.929546] rcu_scheduler_active =3D 1, debug_locks =3D 1
>> [ =A0 51.929550] 1 lock held by Xorg/4013:
>> [ =A0 51.929553] =A0#0: =A0(clock-AF_UNIX){++.+..}, at: [<ffffffff81=
33cebd>]
>> sock_def_readable+0x19/0x62
>> [ =A0 51.929567]
>> [ =A0 51.929568] stack backtrace:
>> [ =A0 51.929573] Pid: 4013, comm: Xorg Not tainted 2.6.34-rc5-git3 #=
22
>> [ =A0 51.929576] Call Trace:
>> [ =A0 51.929579] =A0<IRQ> =A0[<ffffffff81067fbe>] lockdep_rcu_derefe=
rence+0x9d/0xa5
>> [ =A0 51.929603] =A0[<ffffffffa014f9fe>]
>> ieee80211_find_sta_by_hw+0x96/0x10f [mac80211]
>> [ =A0 51.929615] =A0[<ffffffffa014fa8e>] ieee80211_find_sta+0x17/0x1=
9 [mac80211]
>> [ =A0 51.929631] =A0[<ffffffffa01e50f2>] iwl_tx_queue_reclaim+0xdb/0=
x1b1 [iwlcore]
>> [ =A0 51.929642] =A0[<ffffffffa0252f1c>] iwl5000_rx_reply_tx+0x4a9/0=
x556 [iwlagn]
>> [ =A0 51.929649] =A0[<ffffffff81068685>] ? mark_held_locks+0x52/0x70
>> [ =A0 51.929656] =A0[<ffffffff813cf46c>] ? _raw_spin_unlock_irqresto=
re+0x3a/0x69
>> [ =A0 51.929662] =A0[<ffffffff8120a353>] ? is_swiotlb_buffer+0x2e/0x=
3b
>> [ =A0 51.929671] =A0[<ffffffffa024bbf4>] iwl_rx_handle+0x163/0x2b5 [=
iwlagn]
>> [ =A0 51.929680] =A0[<ffffffffa024c3ac>] iwl_irq_tasklet+0x2bb/0x3c0=
 [iwlagn]
>> [ =A0 51.929687] =A0[<ffffffff810411f3>] tasklet_action+0xa7/0x10f
>> [ =A0 51.929693] =A0[<ffffffff81042205>] __do_softirq+0x144/0x252
>> [ =A0 51.929700] =A0[<ffffffff81003a8c>] call_softirq+0x1c/0x34
>> [ =A0 51.929705] =A0[<ffffffff810050e4>] do_softirq+0x38/0x80
>> [ =A0 51.929711] =A0[<ffffffff81041cd2>] irq_exit+0x45/0x94
>> [ =A0 51.929717] =A0[<ffffffff81019b10>] smp_apic_timer_interrupt+0x=
87/0x95
>> [ =A0 51.929724] =A0[<ffffffff81003553>] apic_timer_interrupt+0x13/0=
x20
>> [ =A0 51.929727] =A0<EOI> =A0[<ffffffff813cf46e>] ?
>> _raw_spin_unlock_irqrestore+0x3c/0x69
>> [ =A0 51.929739] =A0[<ffffffff8102d3fb>] __wake_up_sync_key+0x49/0x5=
2
>> [ =A0 51.929745] =A0[<ffffffff8133cee7>] sock_def_readable+0x43/0x62
>> [ =A0 51.929751] =A0[<ffffffff813b1c61>] unix_stream_sendmsg+0x243/0=
x2e2
>> [ =A0 51.929758] =A0[<ffffffff8133b912>] ? sock_aio_write+0x0/0xcf
>> [ =A0 51.929764] =A0[<ffffffff81339342>] __sock_sendmsg+0x59/0x64
>> [ =A0 51.929770] =A0[<ffffffff8133b9cd>] sock_aio_write+0xbb/0xcf
>> [ =A0 51.929777] =A0[<ffffffff810e9909>] do_sync_readv_writev+0xbc/0=
xfb
>> [ =A0 51.929785] =A0[<ffffffff811c1792>] ? selinux_file_permission+0=
xa2/0xaf
>> [ =A0 51.929790] =A0[<ffffffff810e9690>] ? copy_from_user+0x2a/0x2c
>> [ =A0 51.929797] =A0[<ffffffff811baff1>] ? security_file_permission+=
0x11/0x13
>> [ =A0 51.929804] =A0[<ffffffff810ea6a6>] do_readv_writev+0xa2/0x122
>> [ =A0 51.929810] =A0[<ffffffff810ead93>] ? fcheck_files+0x8f/0xc9
>> [ =A0 51.929816] =A0[<ffffffff810ea764>] vfs_writev+0x3e/0x49
>> [ =A0 51.929821] =A0[<ffffffff810ea84a>] sys_writev+0x45/0x8e
>> [ =A0 51.929828] =A0[<ffffffff81002b6b>] system_call_fastpath+0x16/0=
x1b
>
> Ditto.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0Thanx, Paul
>
> ---------------------------------------------------------------------=
---
>
> commit 0868dd631def762ba00c2f0f397a53c5cdf24ae2
> Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Date: =A0 Sat Apr 24 19:23:30 2010 -0700
>
> =A0 =A0block-cgroup: fix RCU-lockdep splat in blkiocg_add_blkio_group=
()
>
> =A0 =A0It is necessary to be in an RCU read-side critical section whe=
n invoking
> =A0 =A0css_id(), so this patch adds one to blkiocg_add_blkio_group().=
 =A0This is
> =A0 =A0actually a false positive, because this is called at initializ=
ation time,
> =A0 =A0and hence always refers to the root cgroup, which cannot go aw=
ay.
>
> =A0 =A0Located-by: Miles Lane <miles.lane@gmail.com>
> =A0 =A0Suggested-by: Vivek Goyal <vgoyal@redhat.com>
> =A0 =A0Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index 5fe03de..55c8c73 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -71,7 +71,9 @@ void blkiocg_add_blkio_group(struct blkio_cgroup *b=
lkcg,
>
> =A0 =A0 =A0 =A0spin_lock_irqsave(&blkcg->lock, flags);
> =A0 =A0 =A0 =A0rcu_assign_pointer(blkg->key, key);
> + =A0 =A0 =A0 rcu_read_lock();
> =A0 =A0 =A0 =A0blkg->blkcg_id =3D css_id(&blkcg->css);
> + =A0 =A0 =A0 rcu_read_unlock();
> =A0 =A0 =A0 =A0hlist_add_head_rcu(&blkg->blkcg_node, &blkcg->blkg_lis=
t);
> =A0 =A0 =A0 =A0spin_unlock_irqrestore(&blkcg->lock, flags);
> =A0#ifdef CONFIG_DEBUG_BLK_CGROUP
>

I am down to seeing three suspicious rcu_dereference_check traces when
I apply this patch and all the previous patches to 2.6.34-rc5-git6.

1. The "__sched_setscheduler+0x19d/0x300" trace.
2. The two "is_swiotlb_buffer+0x2e/0x3b" traces (waiting to see
Johannes' patch show up in a Linux snapshot)

Did I miss a patch for the setscheduler issue?

Thanks!
        Miles
