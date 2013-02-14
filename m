From: Sasikanth babu <sasikanth.v19@gmail.com>
Subject: Query/Help: Enabling net-sched config cause IXGE tx hang and
 continuous NMIs
Date: Thu, 14 Feb 2013 15:29:45 +0530
Message-ID: <CAOJFanW5mbgR_2-UN1j37ZR9sFXH2uA4f0RdNMJowp6eobAKJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:37110 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576Ab3BNJ7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 04:59:46 -0500
Received: by mail-ob0-f169.google.com with SMTP id ta14so2267098obb.14
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 01:59:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

   After enabling Queueing/Scheduling and Classification, I'm getting
NMI's continuously and also observed RCU stall. I had truned off
gro,lro,tso and gso settings too.

IGB version:        3.2.9
IXGBE version :  3.4.24

TX HANG
=======

[   68.353583] ixgbe 0000:82:00.0: eth8: Detected Tx Unit Hang
[   68.353585]   Tx Queue             <0>
[   68.353586]   TDH, TDT             <0>, <e>
[   68.353587]   next_to_use          <e>
[   68.353587]   next_to_clean        <2>
[   68.353591] ixgbe 0000:82:00.0: eth8: tx_buffer_info[next_to_clean]
[   68.353592]   time_stamp           <ffffa375>
[   68.353592]   jiffies              <ffffa582>
[   68.353595] ixgbe 0000:82:00.0: eth8: tx hang 1 detected on queue
0, resetting adapter
[   68.353611] ixgbe 0000:82:00.0: eth8: Reset adapter
[   69.232095] ixgbe 0000:82:00.0: eth8: NIC Link is Up 10 Gbps, Flow
Control: RX/TX
[   71.670656] eth0: no IPv6 routers present
[   72.099976] ------------[ cut here ]------------
[   72.099984] WARNING: at linux/net/sched/sch_generic.c:
256 dev_watchdog+0x1fa/0x210()
[   72.099988] Hardware name: To be filled by O.E.M.
[   72.099990] NETDEV WATCHDOG: eth0 (igb): transmit queue 0 timed out
[   72.099991] Modules linked in: ixgbe pmbus_core igb ltc2978 i2c_mux
pca954x ip_tables iptable_filter ip6_tables ip6table_filter mloopback
[last unloaded: scsi_wait_scan]
[   72.100001] Pid: 102, comm: softirq-net-tx/ Not tainted 2.6.34.12 #1
[   72.100004] Call Trace:
[   72.100006]  <IRQ>  [<ffffffff810455a3>] ? warn_slowpath_common+0x73/0xb0
[   72.100020]  [<ffffffff81038737>] ? __enqueue_rt_entity+0x107/0x2b0
[   72.100024]  [<ffffffff81045640>] ? warn_slowpath_fmt+0x40/0x50
[   72.100031]  [<ffffffff81668dc0>] ? dcbnl_app_nest+0x1100c0/0x11a300
[   72.100038]  [<ffffffff81240451>] ? strlcpy+0x41/0x50
[   72.100040]  [<ffffffff813e2e7a>] ? dev_watchdog+0x1fa/0x210
[   72.100043]  [<ffffffff813e2c80>] ? dev_watchdog+0x0/0x210
[   72.100043]  [<ffffffff813e2c80>] ? dev_watchdog+0x0/0x210
[   72.100049]  [<ffffffff81051cec>] ? run_timer_softirq+0x13c/0x210
[   72.100056]  [<ffffffff8101c618>] ? lapic_next_event+0x18/0x20
[   72.100060]  [<ffffffff8104bb59>] ? __do_softirq+0x99/0x140
[   72.100065]  [<ffffffff81063277>] ? hrtimer_interrupt+0x147/0x260
[   72.100071]  [<ffffffff81003d0c>] ? call_softirq+0x1c/0x30
[   72.100074]  [<ffffffff81005f5d>] ? do_softirq+0x4d/0x80
[   72.100078]  [<ffffffff8101d05a>] ? smp_apic_timer_interrupt+0x6a/0xa0
[   72.100081]  [<ffffffff810037d8>] ? apic_timer_interrupt+0x18/0x20
[   72.100083]  <EOI>  [<ffffffff814d0cd0>] ? _cond_resched+0x0/0x40
[   72.100090]  [<ffffffff8104b9a9>] ? run_ksoftirqd+0x129/0x240
[   72.100093]  [<ffffffff8104b880>] ? run_ksoftirqd+0x0/0x240
[   72.100096]  [<ffffffff8105e8ae>] ? kthread+0x8e/0xa0
[   72.100099]  [<ffffffff81003c14>] ? kernel_thread_helper+0x4/0x10
[   72.100104]  [<ffffffff814d2b11>] ? restore_args+0x0/0x30
[   72.100106]  [<ffffffff8105e820>] ? kthread+0x0/0xa0
[   72.100109]  [<ffffffff81003c10>] ? kernel_thread_helper+0x0/0x10
[   72.100112] ---[ end trace 5434e21c964b684e ]---
[  143.940213] ---[ end trace c9fd33f6d69e8670 ]---
[  143.940216] ixgbe 0000:82:00.0: eth8: Fake Tx hang detected with
timeout of 5 seconds
[  149.934687] ixgbe 0000:82:00.1: eth9: NIC Link is Up 10 Gbps, Flow
Control: RX/TX
[  149.936083] ADDRCONF(NETDEV_CHANGE): eth9: link becomes ready
[  152.824920] ixgbe 0000:82:00.1: eth9: NIC Link is Down
[  153.924681] ixgbe 0000:82:00.0: eth8: Fake Tx hang detected with
timeout of 10 seconds

RCU STALL
=========
[   93.832690] INFO: RCU detected CPU 0 stall (t=1000 jiffies)
[   93.832693] sending NMI to all CPUs:
[   93.832698] NMI backtrace for cpu 0
[   93.832699] CPU 0
[   93.832759] Process softirq-net-tx/ (pid: 6, threadinfo
ffff88027691a000, task ffff880276902cb0)
[   93.832761] Stack:
[   93.834759]  ffffffff8101d0aa 00000015db168963 0000000000000002
0000000000006280
[   93.834762] <0> ffffffff8101d72c ffff880009403df8 ffff880000000002
ffff880009403e08
[   93.834765] <0> 0000000000000000 ffffffff84ade880 ffffffff84ade980
0000000000000000
[   93.834769] Call Trace:
[   93.837207]  <IRQ>
[   93.839308]  [<ffffffff8101d0aa>] ? native_safe_apic_wait_icr_idle+0x1a/0x50
[   93.839313]  [<ffffffff8101d72c>] ?
default_send_IPI_mask_sequence_phys+0xcc/0xe0
[   93.839317]  [<ffffffff8101d839>] ? arch_trigger_all_cpu_backtrace+0x49/0x80
[   93.839322]  [<ffffffff81091fbb>] ? __rcu_pending+0x7b/0x330
[   93.839325]  [<ffffffff810922af>] ? rcu_check_callbacks+0x3f/0x150
[   93.839329]  [<ffffffff8105277f>] ? update_process_times+0x3f/0x70
[   93.839334]  [<ffffffff8106dd78>] ? tick_sched_timer+0x58/0x150
[   93.839338]  [<ffffffff81062f19>] ? __run_hrtimer+0x49/0xe0
[   93.839341]  [<ffffffff81063217>] ? hrtimer_interrupt+0xe7/0x260
[   93.839345]  [<ffffffff8101d055>] ? smp_apic_timer_interrupt+0x65/0xa0
[   93.839349]  [<ffffffff810037d8>] ? apic_timer_interrupt+0x18/0x20
[   93.839351]  <EOI>
[   93.841457]  [<ffffffff813c80aa>] ? __netif_schedule+0xa/0x50
[   93.841461]  [<ffffffff813e3642>] ? sch_direct_xmit+0x122/0x1b0
[   93.841463]  [<ffffffff813e3733>] ? __qdisc_run+0x63/0xe0
[   93.841467]  [<ffffffff813c8a08>] ? net_tx_action+0xe8/0x130
[   93.841471]  [<ffffffff8104b994>] ? run_ksoftirqd+0x114/0x240
[   93.841474]  [<ffffffff8104b880>] ? run_ksoftirqd+0x0/0x240
[   93.841477]  [<ffffffff8105e8ae>] ? kthread+0x8e/0xa0
[   93.841481]  [<ffffffff81003c14>] ? kernel_thread_helper+0x4/0x10
[   93.841486]  [<ffffffff814d2b11>] ? restore_args+0x0/0x30
[   93.841488]  [<ffffffff8105e820>] ? kthread+0x0/0xa0
[   93.841491]  [<ffffffff81003c10>] ? kernel_thread_helper+0x0/0x10
[   93.841493] Code: 66 66 2e 0f 1f


    Newly add config
    -----------------------------

    CONFIG_NET_SCHED=y
    #
    # Queueing/Scheduling
    #
    CONFIG_NET_SCH_CBQ=m
    CONFIG_NET_SCH_HTB=m
    CONFIG_NET_SCH_HFSC=m
    CONFIG_NET_SCH_PRIO=m
    CONFIG_NET_SCH_MULTIQ=m
    CONFIG_NET_SCH_RED=m
    CONFIG_NET_SCH_SFQ=m
    CONFIG_NET_SCH_TEQL=m
    CONFIG_NET_SCH_TBF=m
    CONFIG_NET_SCH_GRED=m
    CONFIG_NET_SCH_DSMARK=m
    CONFIG_NET_SCH_NETEM=m
    CONFIG_NET_SCH_DRR=m
    CONFIG_NET_SCH_INGRESS=m
    #
    # Classification
    #
    CONFIG_NET_CLS=y
    CONFIG_NET_CLS_BASIC=m
    CONFIG_NET_CLS_TCINDEX=m
    CONFIG_NET_CLS_ROUTE4=m
    CONFIG_NET_CLS_FW=m
    CONFIG_NET_CLS_U32=m
    CONFIG_CLS_U32_PERF=y
    CONFIG_CLS_U32_MARK=y
    CONFIG_NET_CLS_RSVP=m
    CONFIG_NET_CLS_RSVP6=m
    CONFIG_NET_CLS_FLOW=m
    CONFIG_NET_CLS_CGROUP=m
    CONFIG_NET_EMATCH=y
    CONFIG_NET_EMATCH_STACK=32
    CONFIG_NET_EMATCH_CMP=m
    CONFIG_NET_EMATCH_NBYTE=m
    CONFIG_NET_EMATCH_U32=m
    CONFIG_NET_EMATCH_META=m
    CONFIG_NET_EMATCH_TEXT=m
    CONFIG_NET_CLS_ACT=y
    CONFIG_NET_ACT_POLICE=m
    CONFIG_NET_ACT_GACT=m
    CONFIG_GACT_PROB=y
    CONFIG_NET_ACT_MIRRED=m
    CONFIG_NET_ACT_IPT=m
    CONFIG_NET_ACT_NAT=m
    CONFIG_NET_ACT_PEDIT=m
    CONFIG_NET_ACT_SIMP=m
    CONFIG_NET_ACT_SKBEDIT=m
    CONFIG_NET_CLS_IND=y
    CONFIG_NET_SCH_FIFO=y


Thanks In Advance
