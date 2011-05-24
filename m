From: Justin Mattock <justinmattock@gmail.com>
Subject: Re: INFO: suspicious rcu_dereference_check() usage.
Date: Mon, 23 May 2011 23:50:46 -0700
Message-ID: <BANLkTinC=2wxtYD4YmePgOfoLSh9STD6Sw@mail.gmail.com>
References: <4DDB491A.2070901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DDB491A.2070901@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 23, 2011 at 10:58 PM, Justin P. Mattock
<justinmattock@gmail.com> wrote:
> seems this is just info, but probably should post this so you guys ar=
e
> aware..:
>
>
>
> [ 1308.117068]
> [ 1308.117072] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [ 1308.117080] [ INFO: suspicious rcu_dereference_check() usage. ]
> [ 1308.117085] ---------------------------------------------------
> [ 1308.117091] kernel/sched_rt.c:1266 invoked rcu_dereference_check()
> without protection!
> [ 1308.117096]
> [ 1308.117097] other info that might help us debug this:
> [ 1308.117099]
> [ 1308.117104]
> [ 1308.117106] rcu_scheduler_active =3D 1, debug_locks =3D 1
> [ 1308.117112] 1 lock held by watchdog/1/16:
> [ 1308.117116] =A0#0: =A0(&rq->lock){-.-.-.}, at: [<ffffffff8103dac0>=
]
> post_schedule.part.25+0x14/0x4a
> [ 1308.117137]
> [ 1308.117139] stack backtrace:
> [ 1308.117146] Pid: 16, comm: watchdog/1 Not tainted
> 2.6.39-04906-g5e152b4-dirty #2
> [ 1308.117151] Call Trace:
> [ 1308.117163] =A0[<ffffffff81079f6f>] lockdep_rcu_dereference+0x9a/0=
xa2
> [ 1308.117172] =A0[<ffffffff8103d256>] find_lowest_rq+0xfe/0x179
> [ 1308.117182] =A0[<ffffffff81043f64>] push_rt_task.part.60+0x7b/0x1c=
8
> [ 1308.117190] =A0[<ffffffff810441bc>] post_schedule_rt+0x20/0x28
> [ 1308.117198] =A0[<ffffffff8103dadc>] post_schedule.part.25+0x30/0x4=
a
> [ 1308.117209] =A0[<ffffffff8148cce5>] schedule+0x725/0x773
> [ 1308.117217] =A0[<ffffffff810a3864>] ? watchdog_enable+0x198/0x198
> [ 1308.117226] =A0[<ffffffff8106e4b8>] ? cpu_clock+0x47/0x51
> [ 1308.117234] =A0[<ffffffff810a3864>] ? watchdog_enable+0x198/0x198
> [ 1308.117241] =A0[<ffffffff810a38d1>] watchdog+0x6d/0xb0
> [ 1308.117249] =A0[<ffffffff8106877d>] kthread+0xa8/0xb0
> [ 1308.117259] =A0[<ffffffff81496e64>] kernel_thread_helper+0x4/0x10
> [ 1308.117268] =A0[<ffffffff8148f594>] ? retint_restore_args+0x13/0x1=
3
> [ 1308.117276] =A0[<ffffffff810686d5>] ? __init_kthread_worker+0x5a/0=
x5a
> [ 1308.117283] =A0[<ffffffff81496e60>] ? gs_change+0x13/0x13
> [ 1308.117675]
> [ 1308.117678] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [ 1308.117685] [ INFO: suspicious rcu_dereference_check() usage. ]
> [ 1308.117690] ---------------------------------------------------
> [ 1308.117695] kernel/sched.c:619 invoked rcu_dereference_check() wit=
hout
> protection!
> [ 1308.117700]
> [ 1308.117701] other info that might help us debug this:
> [ 1308.117704]
> [ 1308.117708]
> [ 1308.117710] rcu_scheduler_active =3D 1, debug_locks =3D 1
> [ 1308.117715] 2 locks held by rcuc0/7:
> [ 1308.117719] =A0#0: =A0(&rq->lock){-.-.-.}, at: [<ffffffff8148c6a1>=
]
> schedule+0xe1/0x773
> [ 1308.117736] =A0#1: =A0(&rq->lock/1){..-.-.}, at: [<ffffffff8103f13=
e>]
> double_lock_balance+0x6c/0x78
> [ 1308.117753]
> [ 1308.117755] stack backtrace:
> [ 1308.117761] Pid: 7, comm: rcuc0 Not tainted 2.6.39-04906-g5e152b4-=
dirty
> #2
> [ 1308.117766] Call Trace:
> [ 1308.117776] =A0[<ffffffff81079f6f>] lockdep_rcu_dereference+0x9a/0=
xa2
> [ 1308.117784] =A0[<ffffffff8103ca8e>] task_group+0x7f/0xbe
> [ 1308.117792] =A0[<ffffffff8103cae4>] set_task_rq+0x17/0x70
> [ 1308.117800] =A0[<ffffffff81043c8d>] set_task_cpu+0xf7/0x14c
> [ 1308.117810] =A0[<ffffffff81217099>] ? plist_check_head+0x9a/0x9e
> [ 1308.117818] =A0[<ffffffff812171cf>] ? plist_del+0x70/0x79
> [ 1308.117825] =A0[<ffffffff8103e8b4>] ? dequeue_task_rt+0x38/0x3d
> [ 1308.117833] =A0[<ffffffff8103eb5c>] ? dequeue_task+0x87/0x8e
> [ 1308.117841] =A0[<ffffffff81043df7>] pull_rt_task+0x115/0x169
> [ 1308.117849] =A0[<ffffffff81043ee7>] pre_schedule_rt+0x1e/0x20
> [ 1308.117857] =A0[<ffffffff8148c889>] schedule+0x2c9/0x773
> [ 1308.117865] =A0[<ffffffff81068e22>] ? prepare_to_wait+0x6c/0x78
> [ 1308.117875] =A0[<ffffffff810a998a>] rcu_cpu_kthread+0xeb/0x34d
> [ 1308.117883] =A0[<ffffffff81068ef8>] ? __init_waitqueue_head+0x4b/0=
x4b
> [ 1308.117892] =A0[<ffffffff810a989f>] ? rcu_needs_cpu+0x1bd/0x1bd
> [ 1308.117899] =A0[<ffffffff8106877d>] kthread+0xa8/0xb0
> [ 1308.117908] =A0[<ffffffff81496e64>] kernel_thread_helper+0x4/0x10
> [ 1308.117916] =A0[<ffffffff8148f594>] ? retint_restore_args+0x13/0x1=
3
> [ 1308.117924] =A0[<ffffffff810686d5>] ? __init_kthread_worker+0x5a/0=
x5a
> [ 1308.117933] =A0[<ffffffff81496e60>] ? gs_change+0x13/0x13
>
>
> full dmesg is here:
> http://fpaste.org/IqRy/
>
> Justin P. Mattock
>


well, after posting the above, I noticed some others as well.
(system got sluggish, but is responsive).

[ 2862.310349] WARNING: at net/ipv4/route.c:1668 ip_rt_bug+0x5c/0x62()
[ 2862.310353] Hardware name: MacBookPro2,2
[ 2862.310355] Modules linked in: fuse 8021q garp stp cpufreq_ondemand
llc acpi_cpufreq freq_table mperf ipt_REJECT nf_conntrack_ipv4
nf_defrag_ipv4 xt_state nf_conntrack iptable_filter ip_tables arc4
ath9k mac80211 radeon ath9k_common ath9k_hw ath cfg80211 btusb
bluetooth ttm drm_kms_helper drm uvcvideo joydev microcode appletouch
applesmc input_polldev iTCO_wdt videodev iTCO_vendor_support
v4l2_compat_ioctl32 i2c_i801 rfkill sky2 i2c_algo_bit i2c_core
apple_bl video [last unloaded: scsi_wait_scan]
[ 2862.310414] Pid: 6153, comm: gcm-session Not tainted
2.6.39-04906-g5e152b4-dirty #2
[ 2862.310417] Call Trace:
[ 2862.310424]  [<ffffffff8104c634>] warn_slowpath_common+0x83/0x9b
[ 2862.310430]  [<ffffffff8104c666>] warn_slowpath_null+0x1a/0x1c
[ 2862.310434]  [<ffffffff814095c9>] ip_rt_bug+0x5c/0x62
[ 2862.310439]  [<ffffffff814112a1>] dst_output+0x19/0x1d
[ 2862.310443]  [<ffffffff81412aa0>] ip_local_out+0x20/0x25
[ 2862.310448]  [<ffffffff814139c9>] ip_send_skb+0x19/0x58
[ 2862.310453]  [<ffffffff8142fa4e>] udp_send_skb+0x239/0x29b
[ 2862.310458]  [<ffffffff814310f0>] udp_sendmsg+0x5a1/0x7d4
[ 2862.310464]  [<ffffffff81079408>] ? trace_hardirqs_off+0xd/0xf
[ 2862.310469]  [<ffffffff8141139c>] ? ip_select_ident+0x3d/0x3d
[ 2862.310475]  [<ffffffff810525b8>] ? local_bh_enable_ip+0xe/0x10
[ 2862.310481]  [<ffffffff8148f131>] ? _raw_spin_unlock_bh+0x31/0x35
[ 2862.310486]  [<ffffffff813d41a6>] ? release_sock+0x14c/0x155
[ 2862.310490]  [<ffffffff814386ac>] inet_sendmsg+0x66/0x6f
[ 2862.310495]  [<ffffffff813d02b0>] sock_sendmsg+0xe6/0x109
[ 2862.310501]  [<ffffffff8107d63f>] ? lock_acquire+0xe1/0x109
[ 2862.310505]  [<ffffffff8107d535>] ? lock_release+0x1aa/0x1d3
[ 2862.310512]  [<ffffffff810ed549>] ? might_fault+0xa5/0xac
[ 2862.310516]  [<ffffffff813ceb34>] ? copy_from_user+0x2f/0x31
[ 2862.310521]  [<ffffffff813d1f34>] sys_sendto+0x132/0x174
[ 2862.310526]  [<ffffffff81495cfa>] ? sysret_check+0x2e/0x69
[ 2862.310531]  [<ffffffff8107b016>] ? trace_hardirqs_on_caller+0x13f/0=
x172
[ 2862.310537]  [<ffffffff8109fd4d>] ? audit_syscall_entry+0x11c/0x148
[ 2862.310542]  [<ffffffff8121debe>] ? trace_hardirqs_on_thunk+0x3a/0x3=
f
[ 2862.310546]  [<ffffffff81495cc2>] system_call_fastpath+0x16/0x1b
[ 2862.310549] ---[ end trace 2d2332adaa8bf2b5 ]---
[ 2863.373889] ip_rt_bug: 10.0.0.10 -> 255.255.255.255, ?
[ 2863.373903] ------------[ cut here ]------------
[ 2863.373910] WARNING: at net/ipv4/route.c:1668 ip_rt_bug+0x5c/0x62()
[ 2863.373919] Hardware name: MacBookPro2,2
[ 2863.373921] Modules linked in: fuse 8021q garp stp cpufreq_ondemand
llc acpi_cpufreq freq_table mperf ipt_REJECT nf_conntrack_ipv4
nf_defrag_ipv4 xt_state nf_conntrack iptable_filter ip_tables arc4
ath9k mac80211 radeon ath9k_common ath9k_hw ath cfg80211 btusb
bluetooth ttm drm_kms_helper drm uvcvideo joydev microcode appletouch
applesmc input_polldev iTCO_wdt videodev iTCO_vendor_support
v4l2_compat_ioctl32 i2c_i801 rfkill sky2 i2c_algo_bit i2c_core
apple_bl video [last unloaded: scsi_wait_scan]
[ 2863.373986] Pid: 6153, comm: gcm-session Tainted: G        W
2.6.39-04906-g5e152b4-dirty #2
[ 2863.373989] Call Trace:
[ 2863.373996]  [<ffffffff8104c634>] warn_slowpath_common+0x83/0x9b
[ 2863.374058]  [<ffffffff8104c666>] warn_slowpath_null+0x1a/0x1c
[ 2863.374063]  [<ffffffff814095c9>] ip_rt_bug+0x5c/0x62
[ 2863.374068]  [<ffffffff814112a1>] dst_output+0x19/0x1d
[ 2863.374073]  [<ffffffff81412aa0>] ip_local_out+0x20/0x25
[ 2863.374079]  [<ffffffff814139c9>] ip_send_skb+0x19/0x58
[ 2863.374084]  [<ffffffff8142fa4e>] udp_send_skb+0x239/0x29b
[ 2863.374089]  [<ffffffff814310f0>] udp_sendmsg+0x5a1/0x7d4
[ 2863.374095]  [<ffffffff81079408>] ? trace_hardirqs_off+0xd/0xf
[ 2863.374100]  [<ffffffff8141139c>] ? ip_select_ident+0x3d/0x3d
[ 2863.374106]  [<ffffffff810525b8>] ? local_bh_enable_ip+0xe/0x10
[ 2863.374111]  [<ffffffff8148f131>] ? _raw_spin_unlock_bh+0x31/0x35
[ 2863.374117]  [<ffffffff813d41a6>] ? release_sock+0x14c/0x155
[ 2863.374122]  [<ffffffff814386ac>] inet_sendmsg+0x66/0x6f
[ 2863.374127]  [<ffffffff813d02b0>] sock_sendmsg+0xe6/0x109
[ 2863.374132]  [<ffffffff8107d63f>] ? lock_acquire+0xe1/0x109
[ 2863.374137]  [<ffffffff8107d535>] ? lock_release+0x1aa/0x1d3
[ 2863.374143]  [<ffffffff810ed549>] ? might_fault+0xa5/0xac
[ 2863.374148]  [<ffffffff813ceb34>] ? copy_from_user+0x2f/0x31
[ 2863.374153]  [<ffffffff813d1f34>] sys_sendto+0x132/0x174
[ 2863.374158]  [<ffffffff81495cfa>] ? sysret_check+0x2e/0x69
[ 2863.374163]  [<ffffffff8107b016>] ? trace_hardirqs_on_caller+0x13f/0=
x172
[ 2863.374169]  [<ffffffff8109fd4d>] ? audit_syscall_entry+0x11c/0x148
[ 2863.374175]  [<ffffffff8121debe>] ? trace_hardirqs_on_thunk+0x3a/0x3=
f
[ 2863.374180]  [<ffffffff81495cc2>] system_call_fastpath+0x16/0x1b
[ 2863.374184] ---[ end trace 2d2332adaa8bf2b6 ]---

full dmesg here:
http://fpaste.org/W4UK/

--=20
Justin P. Mattock
