From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Thu, 27 Mar 2008 16:45:06 -0700
Message-ID: <47EC3182.7080005@sun.com>
References: <47EA7DE8.9070203@sun.com> <47EAAE9A.9050305@gmail.com>
 <47EAB158.3080806@sun.com> <20080327103340.GB2845@ami.dom.local>
 <36D9DB17C6DE9E40B059440DB8D95F5204C275C2@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:37618 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbYC0XqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 19:46:18 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m2RNkIlS003936
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 16:46:18 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JYE00F01XY1J600@fe-sfbay-09.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Thu,
 27 Mar 2008 16:46:18 -0700 (PDT)
In-reply-to: <36D9DB17C6DE9E40B059440DB8D95F5204C275C2@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
> Jarek Poplawski wrote:
>   
>> On Wed, Mar 26, 2008 at 01:26:00PM -0700, Matheos Worku wrote:
>> ...
>>     
>>> nsn57-110 login: BUG: soft lockup - CPU#2 stuck for 11s! ... Call
>>> Trace: [<ffffffff803ef5f6>] __skb_clone+0x24/0xdc
>>> [<ffffffff803f152e>] skb_realloc_headroom+0x30/0x63
>>> [<ffffffff882edd40>] :niu:niu_start_xmit+0x114/0x5af
>>> [<ffffffff80221995>] gart_map_single+0x0/0x70
>>> [<ffffffff803f5e2b>] dev_hard_start_xmit+0x1d2/0x246 ...
>>>       
>> Maybe I'm wrong with this again, but I wonder about this
>> gart_map_single on almost all traces, and probably not supposed to be
>> seen here. Did you try with some memory re-config/debugging?
>>     
>
> I have some more examples of this but with the ixgbe driver.  We are
> running heavy bidirectional stress with multiple rx (non-napi, yeah I
> know) interrupts by default (and userspace irqbalance is probably on,
> I'll have the lab try it without)
>   

I have seen the lockup on kernels 2.6.18 and newer mostly on TX traffic. 
I have seen it on another 10G driver (off the tree niu driver sibling, 
nxge).  The nxge driver doesn't use any TX interrupts and I have seen it 
with UDP TX, irqbalance disabled, with no irq activity at all.  some 
example traces included.
Regards
Matheos


nsn57-110 login: BUG: soft lockup - CPU#4 stuck for 11s! [uperf.x86_64:6697]
CPU 4:
Modules linked in: nxge nfs lockd nfs_acl autofs4 hidp rfcomm l2cap 
bluetooth sunrpc ipv6 cpufreq_ondemand rdma_ucm ib_ucm rdma_cm iw_cm 
ib_addr ib_srp scsi_transport_srp ib_cm ib_ipoib ib_sa ib_uverbs ib_umad 
ib_mad ib_core dm_multipath battery ac parport_pc lp parport joydev 
sr_mod sg e1000 i2c_nforce2 button i2c_core shpchp pcspkr dm_snapshot 
dm_zerodm_mirror dm_mod usb_storage mptsas mptscsih mptbase 
scsi_transport_sas sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd
Pid: 6697, comm: uperf.x86_64 Not tainted 2.6.24-mati #3
RIP: 0010:[<ffffffff80316c64>]  [<ffffffff80316c64>] 
_raw_spin_unlock+0x37/0x7f
RSP: 0018:ffff8101e00c3af8  EFLAGS: 00000246
RAX: ffff8101e084e000 RBX: ffff8101f0908000 RCX: ffff8101f0908780
RDX: 0000000000000000 RSI: 0000000000000116 RDI: ffff8101f0908300
RBP: 00000000000003d5 R08: 0000000000000004 R09: 0000000000000115
R10: ffff8101e00c3968 R11: 0000000000000000 R12: ffff8101e00c3968
R13: 0000000000000000 R14: ffff8101f0908000 R15: ffffffff882e77ef
FS:  0000000041001940(0063) GS:ffff8102fba13580(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000004f81cf48 CR3: 00000001e05b4000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 [<ffffffff80406dca>] __qdisc_run+0x96/0x174
 [<ffffffff803f8139>] dev_queue_xmit+0x141/0x270
 [<ffffffff80417faf>] ip_push_pending_frames+0x32c/0x3a0
 [<ffffffff80419676>] ip_generic_getfrag+0x0/0x8b
 [<ffffffff8043359f>] udp_push_pending_frames+0x2ba/0x337
 [<ffffffff80434794>] udp_sendmsg+0x4c8/0x606
 [<ffffffff803eafbb>] sock_sendmsg+0xe2/0xff
 [<ffffffff8029e1a1>] iput+0x42/0x7b
 [<ffffffff802480e0>] autoremove_wake_function+0x0/0x2e
 [<ffffffff80275d0c>] find_extend_vma+0x16/0x59
 [<ffffffff8045e4d3>] _spin_lock_irqsave+0x9/0xe
 [<ffffffff80311d88>] __up_read+0x13/0x8a
 [<ffffffff803eba5c>] sys_sendto+0x128/0x151
 [<ffffffff8045e3ed>] _spin_unlock_bh+0x9/0x15
 [<ffffffff8020b7fc>] tracesys+0xdc/0xe1

BUG: soft lockup - CPU#4 stuck for 11s! [uperf.x86_64:6697]
CPU 4:
Modules linked in: nxge nfs lockd nfs_acl autofs4 hidp rfcomm l2cap 
bluetooth sunrpc ipv6 cpufreq_ondemand rdma_ucm ib_ucm rdma_cm iw_cm 
ib_addr ib_srp scsi_transport_srp ib_cm ib_ipoib ib_sa ib_uverbs ib_umad 
ib_mad ib_core dm_multipath battery ac parport_pc lp parport joydev 
sr_mod sg e1000 i2c_nforce2 button i2c_core shpchp pcspkr dm_snapshot 
dm_zero dm_mirror dm_mod usb_storage mptsas mptscsih mptbase 
scsi_transport_sas sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd
Pid: 6697, comm: uperf.x86_64 Not tainted 2.6.24-mati #3
RIP: 0010:[<ffffffff80316d29>]  [<ffffffff80316d29>] 
_raw_spin_lock+0x7d/0xf6
RSP: 0018:ffff8101e00c3ad8  EFLAGS: 00000246
RAX: 0000000000000000 RBX: 0000000000000036 RCX: 00000000dabeab42
RDX: 0000000000000e24 RSI: 0000000000000392 RDI: 0000000000000001
RBP: ffffffff882e77ef R08: 0000000000000004 R09: 0000000000000391
R10: ffff8101e00c3968 R11: 0000000000000000 R12: ffffffffffffff10
R13: 0000000000000011 R14: ffff8102f9db8010 R15: 00000000000005de
FS:  0000000041001940(0063) GS:ffff8102fba13580(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000004f81cf48 CR3: 00000001e05b4000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 [<ffffffff80316d3a>] _raw_spin_lock+0x8e/0xf6
 [<ffffffff80406fa1>] pfifo_fast_dequeue+0x24/0x59
 [<ffffffff80406dd2>] __qdisc_run+0x9e/0x174
 [<ffffffff803f8139>] dev_queue_xmit+0x141/0x270
 [<ffffffff80417faf>] ip_push_pending_frames+0x32c/0x3a0
 [<ffffffff80419676>] ip_generic_getfrag+0x0/0x8b
 [<ffffffff8043359f>] udp_push_pending_frames+0x2ba/0x337
 [<ffffffff80434794>] udp_sendmsg+0x4c8/0x606
 [<ffffffff803eafbb>] sock_sendmsg+0xe2/0xff
 [<ffffffff8029e1a1>] iput+0x42/0x7b
 [<ffffffff802480e0>] autoremove_wake_function+0x0/0x2e
 [<ffffffff80275d0c>] find_extend_vma+0x16/0x59
 [<ffffffff8045e4d3>] _spin_lock_irqsave+0x9/0xe
 [<ffffffff80311d88>] __up_read+0x13/0x8a
 [<ffffffff803eba5c>] sys_sendto+0x128/0x151
 [<ffffffff8045e3ed>] _spin_unlock_bh+0x9/0x15
 [<ffffffff8020b7fc>] tracesys+0xdc/0xe1

BUG: soft lockup - CPU#4 stuck for 11s! [uperf.x86_64:6697]
CPU 4:
Modules linked in: nxge nfs lockd nfs_acl autofs4 hidp rfcomm l2cap 
bluetooth sunrpc ipv6 cpufreq_ondemand rdma_ucm ib_ucm rdma_cm iw_cm 
ib_addr ib_srp scsi_transport_srp ib_cm ib_ipoib ib_sa ib_uverbs ib_umad 
ib_mad ib_core dm_multipath battery ac parport_pc lp parport joydev 
sr_mod sg e1000 i2c_nforce2 button i2c_core shpchp pcspkr dm_snapshot 
dm_zero dm_mirror dm_mod usb_storage mptsas mptscsih mptbase 
scsi_transport_sas sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd
Pid: 6697, comm: uperf.x86_64 Not tainted 2.6.24-mati #3
RIP: 0010:[<ffffffff80316d29>]  [<ffffffff80316d29>] 
_raw_spin_lock+0x7d/0xf6
RSP: 0018:ffff8101e00c3ad8  EFLAGS: 00000246
RAX: 0000000000000000 RBX: 0000000000000026 RCX: 000000002a2092e7
RDX: 0000000000000e28 RSI: 00000000000001d8 RDI: 0000000000000001
RBP: ffffffff882e77ef R08: 0000000000000004 R09: 00000000000001d7
R10: ffff8101e00c3968 R11: 0000000000000000 R12: ffffffffffffff10
R13: 0000000000000011 R14: ffff8102f686e010 R15: 00000000000005de
FS:  0000000041001940(0063) GS:ffff8102fba13580(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000004f81cf48 CR3: 00000001e05b4000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 [<ffffffff80316d3a>] _raw_spin_lock+0x8e/0xf6
 [<ffffffff80406e8a>] __qdisc_run+0x156/0x174
 [<ffffffff80406dd2>] __qdisc_run+0x9e/0x174
 [<ffffffff803f8139>] dev_queue_xmit+0x141/0x270
 [<ffffffff80417faf>] ip_push_pending_frames+0x32c/0x3a0
 [<ffffffff80419676>] ip_generic_getfrag+0x0/0x8b
 [<ffffffff8043359f>] udp_push_pending_frames+0x2ba/0x337
 [<ffffffff80434794>] udp_sendmsg+0x4c8/0x606
 [<ffffffff803eafbb>] sock_sendmsg+0xe2/0xff
 [<ffffffff8029e1a1>] iput+0x42/0x7b
 [<ffffffff802480e0>] autoremove_wake_function+0x0/0x2e
 [<ffffffff80275d0c>] find_extend_vma+0x16/0x59
 [<ffffffff8045e4d3>] _spin_lock_irqsave+0x9/0xe
 [<ffffffff80311d88>] __up_read+0x13/0x8a
 [<ffffffff803eba5c>] sys_sendto+0x128/0x151
 [<ffffffff8045e3ed>] _spin_unlock_bh+0x9/0x15
 [<ffffffff8020b7fc>] tracesys+0xdc/0xe1




> Most of our traces are from redhat 2.6.18 kernel, or 2.6.21.5, I'll try
> to get a more recent kernel tested.
>
> here is some related data if that helps at all.
>
> 2.6.21.5
> =====================================
>
> [  180.487937] BUG: soft lockup detected on CPU#0!
> [  180.492461] 
> [  180.492461] Call Trace:
> [  180.496426]  <IRQ>  [<ffffffff8025d788>] softlockup_tick+0xd4/0xe9
> [  180.502650]  [<ffffffff8023bc57>] run_local_timers+0x13/0x15
> [  180.508317]  [<ffffffff8023bf37>] update_process_times+0x4c/0x78
> [  180.514323]  [<ffffffff802181d0>] smp_local_timer_interrupt+0x34/0x51
> [  180.520761]  [<ffffffff80218966>] smp_apic_timer_interrupt+0x43/0x5d
> [  180.527104]  [<ffffffff8020a31b>] apic_timer_interrupt+0x6b/0x70
> [  180.533113]  [<ffffffff80533e2e>] _spin_unlock_irqrestore+0x3f/0x69
> [  180.539372]  [<ffffffff80533e31>] _spin_unlock_irqrestore+0x42/0x69
> [  180.545648]  [<ffffffff804ba219>] skb_queue_tail+0x41/0x49
> [  180.551133]  [<ffffffff804b990e>] sock_queue_rcv_skb+0xe2/0x11c
> [  180.557055]  [<ffffffff804f440e>] udp_queue_rcv_skb+0xb6/0x180
> [  180.562877]  [<ffffffff804f492e>] __udp4_lib_rcv+0x456/0x594
> [  180.568538]  [<ffffffff804f4a7e>] udp_rcv+0x12/0x14
> [  180.573439]  [<ffffffff804d5572>] ip_local_deliver+0xca/0x171
> [  180.579191]  [<ffffffff804d5b28>] ip_rcv+0x424/0x464
> [  180.584171]  [<ffffffff804bf912>] netif_receive_skb+0x25a/0x30f
> [  180.590091]  [<ffffffff804c182c>] process_backlog+0xab/0x10f
> [  180.595741]  [<ffffffff804c1acc>] net_rx_action+0xbb/0x254
> [  180.601220]  [<ffffffff80237cb5>] __do_softirq+0x5e/0xe2
> [  180.606544]  [<ffffffff8020a86c>] call_softirq+0x1c/0x28
> [  180.611850]  [<ffffffff8020bcd2>] do_softirq+0x39/0x9f
> [  180.616983]  [<ffffffff80237c4b>] irq_exit+0x45/0x51
> [  180.621941]  [<ffffffff8020be7b>] do_IRQ+0x143/0x168
> [  180.626913]  [<ffffffff80209b86>] ret_from_intr+0x0/0xf
> [  180.632131]  <EOI>  [<ffffffff804bb256>] skb_release_data+0x95/0x9a
> [  180.638424]  [<ffffffff8028391c>] kfree+0x204/0x216
> [  180.643296]  [<ffffffff8028391f>] kfree+0x207/0x216
> [  180.648188]  [<ffffffff804bb256>] skb_release_data+0x95/0x9a
> [  180.653829]  [<ffffffff804bb02c>] kfree_skbmem+0x11/0x7e
> [  180.659145]  [<ffffffff804bb13d>] __kfree_skb+0xa4/0xa9
> [  180.664365]  [<ffffffff804bb16c>] kfree_skb+0x2a/0x2c
> [  180.669412]  [<ffffffff804bd07d>] skb_free_datagram+0xc/0xe
> [  180.674985]  [<ffffffff804f5649>] udp_recvmsg+0x1e1/0x25f
> [  180.680388]  [<ffffffff804b725e>] sock_common_recvmsg+0x32/0x47
> [  180.686322]  [<ffffffff804b5d7d>] sock_recvmsg+0xe5/0xfe
> [  180.691629]  [<ffffffff8024e84b>] __lock_acquire+0xb4a/0xbde
> [  180.697299]  [<ffffffff802464bd>] autoremove_wake_function+0x0/0x38
> [  180.703562]  [<ffffffff805333ad>] trace_hardirqs_on_thunk+0x35/0x37
> [  180.709825]  [<ffffffff804bb095>] kfree_skbmem+0x7a/0x7e
> [  180.715148]  [<ffffffff80209be0>] restore_args+0x0/0x30
> [  180.720381]  [<ffffffff80338e30>] copy_user_generic_string+0x0/0x40
> [  180.726652]  [<ffffffff804b6b64>] sys_recvfrom+0xce/0x122
> [  180.732045]  [<ffffffff8024d864>] trace_hardirqs_on+0x125/0x150
> [  180.737964]  [<ffffffff805333ad>] trace_hardirqs_on_thunk+0x35/0x37
> [  180.744222]  [<ffffffff8020963e>] system_call+0x7e/0x83
> [  180.749457] 
> [  190.731184] BUG: soft lockup detected on CPU#0!
> [  190.735704] 
> [  190.735705] Call Trace:
> [  190.739661]  <IRQ>  [<ffffffff8025d788>] softlockup_tick+0xd4/0xe9
> [  190.745886]  [<ffffffff8023bc57>] run_local_timers+0x13/0x15
> [  190.751555]  [<ffffffff8023bf37>] update_process_times+0x4c/0x78
> [  190.751561]  [<ffffffff802181d0>] smp_local_timer_interrupt+0x34/0x51
> [  190.751566]  [<ffffffff80218966>] smp_apic_timer_interrupt+0x43/0x5d
> [  190.751571]  [<ffffffff8020a31b>] apic_timer_interrupt+0x6b/0x70
> [  190.751577]  [<ffffffff80533e2e>] _spin_unlock_irqrestore+0x3f/0x69
> [  190.751582]  [<ffffffff80533e31>] _spin_unlock_irqrestore+0x42/0x69
> [  190.751587]  [<ffffffff804ba219>] skb_queue_tail+0x41/0x49
> [  190.751590]  [<ffffffff804b990e>] sock_queue_rcv_skb+0xe2/0x11c
> [  190.751595]  [<ffffffff804f440e>] udp_queue_rcv_skb+0xb6/0x180
> [  190.751599]  [<ffffffff804f492e>] __udp4_lib_rcv+0x456/0x594
> [  190.751603]  [<ffffffff804f4a7e>] udp_rcv+0x12/0x14
> [  190.751609]  [<ffffffff804d5572>] ip_local_deliver+0xca/0x171
> [  190.751613]  [<ffffffff804d5b28>] ip_rcv+0x424/0x464
> [  190.751617]  [<ffffffff804bf912>] netif_receive_skb+0x25a/0x30f
> [  190.751621]  [<ffffffff804c182c>] process_backlog+0xab/0x10f
> [  190.751625]  [<ffffffff804c1acc>] net_rx_action+0xbb/0x254
> [  190.751630]  [<ffffffff80237cb5>] __do_softirq+0x5e/0xe2
> [  190.751634]  [<ffffffff8020a86c>] call_softirq+0x1c/0x28
> [  190.751638]  [<ffffffff8020bcd2>] do_softirq+0x39/0x9f
> [  190.751642]  [<ffffffff80237c4b>] irq_exit+0x45/0x51
> [  190.751645]  [<ffffffff8020be7b>] do_IRQ+0x143/0x168
> [  190.751649]  [<ffffffff80209b86>] ret_from_intr+0x0/0xf
> [  190.751652]  <EOI>  [<ffffffff804bb256>] skb_release_data+0x95/0x9a
> [  190.751660]  [<ffffffff8028391c>] kfree+0x204/0x216
> [  190.751664]  [<ffffffff8028391f>] kfree+0x207/0x216
> [  190.751669]  [<ffffffff804bb256>] skb_release_data+0x95/0x9a
> [  190.751672]  [<ffffffff804bb02c>] kfree_skbmem+0x11/0x7e
> [  190.751676]  [<ffffffff804bb13d>] __kfree_skb+0xa4/0xa9
> [  190.751680]  [<ffffffff804bb16c>] kfree_skb+0x2a/0x2c
> [  190.751684]  [<ffffffff804bd07d>] skb_free_datagram+0xc/0xe
> [  190.751688]  [<ffffffff804f5649>] udp_recvmsg+0x1e1/0x25f
> [  190.751695]  [<ffffffff804b725e>] sock_common_recvmsg+0x32/0x47
> [  190.751699]  [<ffffffff804b5d7d>] sock_recvmsg+0xe5/0xfe
> [  190.751703]  [<ffffffff8024e84b>] __lock_acquire+0xb4a/0xbde
> [  190.751709]  [<ffffffff802464bd>] autoremove_wake_function+0x0/0x38
> [  190.751713]  [<ffffffff805333ad>] trace_hardirqs_on_thunk+0x35/0x37
> [  190.751717]  [<ffffffff804bb095>] kfree_skbmem+0x7a/0x7e
> [  190.751721]  [<ffffffff80209be0>] restore_args+0x0/0x30
> [  190.751727]  [<ffffffff80338e30>] copy_user_generic_string+0x0/0x40
> [  190.751731]  [<ffffffff804b6b64>] sys_recvfrom+0xce/0x122
> [  190.751736]  [<ffffffff8024d864>] trace_hardirqs_on+0x125/0x150
> [  190.751740]  [<ffffffff805333ad>] trace_hardirqs_on_thunk+0x35/0x37
> [  190.751745]  [<ffffffff8020963e>] system_call+0x7e/0x83
> [  190.751749] 
> [  200.738822] BUG: soft lockup detected on CPU#0!
> [  200.743364] 
> [  200.743364] Call Trace:
> [  200.747304]  <IRQ>  [<ffffffff8025d788>] softlockup_tick+0xd4/0xe9
> [  200.753531]  [<ffffffff8023bc57>] run_local_timers+0x13/0x15
> [  200.759188]  [<ffffffff8023bf37>] update_process_times+0x4c/0x78
> [  200.765189]  [<ffffffff802181d0>] smp_local_timer_interrupt+0x34/0x51
> [  200.771634]  [<ffffffff80218966>] smp_apic_timer_interrupt+0x43/0x5d
> [  200.777987]  [<ffffffff8020a31b>] apic_timer_interrupt+0x6b/0x70
> [  200.783997]  [<ffffffff80533e2e>] _spin_unlock_irqrestore+0x3f/0x69
> [  200.790261]  [<ffffffff80533e31>] _spin_unlock_irqrestore+0x42/0x69
> [  200.796519]  [<ffffffff804ba219>] skb_queue_tail+0x41/0x49
> [  200.802004]  [<ffffffff804b990e>] sock_queue_rcv_skb+0xe2/0x11c
> [  200.807925]  [<ffffffff804f440e>] udp_queue_rcv_skb+0xb6/0x180
> [  200.813757]  [<ffffffff804f492e>] __udp4_lib_rcv+0x456/0x594
> [  200.819401]  [<ffffffff804f4a7e>] udp_rcv+0x12/0x14
> [  200.824294]  [<ffffffff804d5572>] ip_local_deliver+0xca/0x171
> [  200.830030]  [<ffffffff804d5b28>] ip_rcv+0x424/0x464
> [  200.835003]  [<ffffffff804bf912>] netif_receive_skb+0x25a/0x30f
> [  200.840919]  [<ffffffff804c182c>] process_backlog+0xab/0x10f
> [  200.846582]  [<ffffffff804c1acc>] net_rx_action+0xbb/0x254
> [  200.852070]  [<ffffffff80237cb5>] __do_softirq+0x5e/0xe2
> [  200.857375]  [<ffffffff8020a86c>] call_softirq+0x1c/0x28
> [  200.862680]  [<ffffffff8020bcd2>] do_softirq+0x39/0x9f
> [  200.867830]  [<ffffffff80237c4b>] irq_exit+0x45/0x51
> [  200.872788]  [<ffffffff8020be7b>] do_IRQ+0x143/0x168
> [  200.877748]  [<ffffffff80209b86>] ret_from_intr+0x0/0xf
> [  200.882977]  <EOI>  [<ffffffff804bb256>] skb_release_data+0x95/0x9a
> [  200.889287]  [<ffffffff8028391c>] kfree+0x204/0x216
> [  200.894168]  [<ffffffff8028391f>] kfree+0x207/0x216
> [  200.899042]  [<ffffffff804bb256>] skb_release_data+0x95/0x9a
> [  200.904685]  [<ffffffff804bb02c>] kfree_skbmem+0x11/0x7e
> [  200.909999]  [<ffffffff804bb13d>] __kfree_skb+0xa4/0xa9
> [  200.915220]  [<ffffffff804bb16c>] kfree_skb+0x2a/0x2c
> [  200.920279]  [<ffffffff804bd07d>] skb_free_datagram+0xc/0xe
> [  200.925844]  [<ffffffff804f5649>] udp_recvmsg+0x1e1/0x25f
> [  200.931249]  [<ffffffff804b725e>] sock_common_recvmsg+0x32/0x47
> [  200.937183]  [<ffffffff804b5d7d>] sock_recvmsg+0xe5/0xfe
> [  200.942490]  [<ffffffff8024e84b>] __lock_acquire+0xb4a/0xbde
> [  200.948150]  [<ffffffff802464bd>] autoremove_wake_function+0x0/0x38
> [  200.954417]  [<ffffffff805333ad>] trace_hardirqs_on_thunk+0x35/0x37
> [  200.960670]  [<ffffffff804bb095>] kfree_skbmem+0x7a/0x7e
> [  200.965984]  [<ffffffff80209be0>] restore_args+0x0/0x30
> [  200.971215]  [<ffffffff80338e30>] copy_user_generic_string+0x0/0x40
> [  200.977480]  [<ffffffff804b6b64>] sys_recvfrom+0xce/0x122
> [  200.982881]  [<ffffffff8024d864>] trace_hardirqs_on+0x125/0x150
> [  200.988791]  [<ffffffff805333ad>] trace_hardirqs_on_thunk+0x35/0x37
> [  200.995059]  [<ffffffff8020963e>] system_call+0x7e/0x83
>
> 2.6.18-5-xen
> ==================================================
>
> BUG: soft lockup detected on CPU#0!
>
> Call Trace:
>  <IRQ>  [<ffffffff802a76d8>] softlockup_tick+0xdb/0xed
>  [<ffffffff8026ba8c>] timer_interrupt+0x396/0x3f2
>  [<ffffffff80210a87>] handle_IRQ_event+0x2d/0x60
>  [<ffffffff802a7a17>] __do_IRQ+0xa4/0x105
>  [<ffffffff802699cf>] do_IRQ+0xe7/0xf5
>  [<ffffffff8038dede>] evtchn_do_upcall+0x86/0xe0
>  [<ffffffff8025cbfe>] do_hypervisor_callback+0x1e/0x2c
>  [<ffffffff8847b58b>] :ixgbe:ixgbe_clean_rx_irq+0x16b/0xa40
>  [<ffffffff8847abb7>] :ixgbe:ixgbe_clean_tx_irq+0xe7/0x330
>  [<ffffffff8847bf4d>] :ixgbe:ixgbe_intr+0xed/0x220
>  [<ffffffff80210a87>] handle_IRQ_event+0x2d/0x60
>  [<ffffffff802a7a17>] __do_IRQ+0xa4/0x105
>  [<ffffffff802699cf>] do_IRQ+0xe7/0xf5
>  [<ffffffff8038dede>] evtchn_do_upcall+0x86/0xe0
>  [<ffffffff8025cbfe>] do_hypervisor_callback+0x1e/0x2c
>  [<ffffffff80226aac>] tcp_v4_rcv+0x6bc/0xa59
>  [<ffffffff802268e9>] tcp_v4_rcv+0x4f9/0xa59
>  [<ffffffff8025cbfe>] do_hypervisor_callback+0x1e/0x2c
>  [<ffffffff8023463b>] ip_local_deliver+0x19d/0x263
>  [<ffffffff8023591a>] ip_rcv+0x49c/0x4df
>  [<ffffffff8021fe67>] netif_receive_skb+0x361/0x3df
>  [<ffffffff802307e3>] process_backlog+0x96/0xff
>  [<ffffffff8020c5ca>] net_rx_action+0xa8/0x1b4
>  [<ffffffff80211ed3>] __do_softirq+0x62/0xdd
>  [<ffffffff8025d0cc>] call_softirq+0x1c/0x28
>  <EOI>  [<ffffffff80269b59>] do_softirq+0x31/0x98
>  [<ffffffff8028714b>] local_bh_enable_ip+0x48/0x59
>  [<ffffffff8021cde4>] tcp_recvmsg+0x9db/0xaf0
>  [<ffffffff80231b2b>] sock_common_recvmsg+0x2d/0x42
>  [<ffffffff8023066b>] sock_recvmsg+0x101/0x120
>  [<ffffffff8029448d>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff80246001>] sprintf+0x51/0x59
>  [<ffffffff8022fcfe>] dev_queue_xmit+0x2f2/0x313
>  [<ffffffff8022b25c>] local_bh_enable+0x9/0xa4
>  [<ffffffff8023356b>] lock_sock+0xa7/0xb2
>  [<ffffffff80260711>] _spin_lock_bh+0x9/0x14
>  [<ffffffff80230e57>] release_sock+0x13/0xaa
>  [<ffffffff8022b25c>] local_bh_enable+0x9/0xa4
>  [<ffffffff8023356b>] lock_sock+0xa7/0xb2
>  [<ffffffff8023af7b>] d_instantiate+0x4a/0x82
>  [<ffffffff802408aa>] d_rehash+0x21/0x34
>  [<ffffffff8022b16f>] sys_recvfrom+0xd4/0x137
>  [<ffffffff802a67f9>] audit_syscall_exit+0x2b/0x2ec
>  [<ffffffff8025c621>] tracesys+0xa7/0xb2
>
> BUG: soft lockup detected on CPU#0!
>
> Call Trace:
>  <IRQ>  [<ffffffff802a76d8>] softlockup_tick+0xdb/0xed
>  [<ffffffff8026ba8c>] timer_interrupt+0x396/0x3f2
>  [<ffffffff80210a87>] handle_IRQ_event+0x2d/0x60
>  [<ffffffff802a7a17>] __do_IRQ+0xa4/0x105
>  [<ffffffff802699cf>] do_IRQ+0xe7/0xf5
>  [<ffffffff8038dede>] evtchn_do_upcall+0x86/0xe0
>  [<ffffffff8025cbfe>] do_hypervisor_callback+0x1e/0x2c
>  [<ffffffff8020622a>] hypercall_page+0x22a/0x1000
>  [<ffffffff8020622a>] hypercall_page+0x22a/0x1000
>  [<ffffffff8038d649>] force_evtchn_callback+0xa/0xb
>  [<ffffffff8020ab34>] kmem_cache_alloc+0x62/0x6d
>  [<ffffffff802350a4>] alloc_skb_from_cache+0x52/0x13c
>  [<ffffffff803f183f>] __netdev_alloc_skb+0x12/0x2d
>  [<ffffffff8847b31b>] :ixgbe:ixgbe_alloc_rx_buffers+0xfb/0x200
>  [<ffffffff8847bcd2>] :ixgbe:ixgbe_clean_rx_irq+0x8b2/0xa40
>  [<ffffffff8847aac4>] :ixgbe:ixgbe_unmap_and_free_tx_resource+0x44/0x50
>  [<ffffffff8847bf4d>] :ixgbe:ixgbe_intr+0xed/0x220
>  [<ffffffff80210a87>] handle_IRQ_event+0x2d/0x60
>  [<ffffffff802a7a17>] __do_IRQ+0xa4/0x105
>  [<ffffffff802699cf>] do_IRQ+0xe7/0xf5
>  [<ffffffff80270394>] xen_send_IPI_mask+0xa5/0xaa
>  [<ffffffff8038dede>] evtchn_do_upcall+0x86/0xe0
>  [<ffffffff8026fa43>] smp_send_reschedule+0x4b/0x50
>  [<ffffffff8025cbfe>] do_hypervisor_callback+0x1e/0x2c
>  [<ffffffff8020622a>] hypercall_page+0x22a/0x1000
>  [<ffffffff8020622a>] hypercall_page+0x22a/0x1000
>  [<ffffffff8023dcca>] lock_timer_base+0x1b/0x3c
>  [<ffffffff8038d649>] force_evtchn_callback+0xa/0xb
>  [<ffffffff8021bf22>] __mod_timer+0xb0/0xbe
>  [<ffffffff80253b8d>] sk_reset_timer+0xf/0x19
>  [<ffffffff80226a6f>] tcp_v4_rcv+0x67f/0xa59
>  [<ffffffff8025e499>] __sched_text_start+0x2d9/0x97b
>  [<ffffffff8023463b>] ip_local_deliver+0x19d/0x263
>  [<ffffffff8023591a>] ip_rcv+0x49c/0x4df
>  [<ffffffff8021fe67>] netif_receive_skb+0x361/0x3df
>  [<ffffffff802307e3>] process_backlog+0x96/0xff
>  [<ffffffff8020622a>] hypercall_page+0x22a/0x1000
>  [<ffffffff8020c5ca>] net_rx_action+0xa8/0x1b4
>  [<ffffffff80211ed3>] __do_softirq+0x62/0xdd
>  [<ffffffff8025d0cc>] call_softirq+0x1c/0x28
>  <EOI>  [<ffffffff80269b59>] do_softirq+0x31/0x98
>  [<ffffffff8022b2e6>] local_bh_enable+0x93/0xa4
>  [<ffffffff8025308f>] __tcp_checksum_complete_user+0x19/0x2c
>  [<ffffffff8021aeb2>] tcp_rcv_established+0x45c/0x917
>  [<ffffffff8023b449>] tcp_v4_do_rcv+0x2a/0x300
>  [<ffffffff80230e98>] release_sock+0x54/0xaa
>  [<ffffffff8021cde4>] tcp_recvmsg+0x9db/0xaf0
>  [<ffffffff80231b2b>] sock_common_recvmsg+0x2d/0x42
>  [<ffffffff8023066b>] sock_recvmsg+0x101/0x120
>  [<ffffffff8029448d>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff80246001>] sprintf+0x51/0x59
>  [<ffffffff8022fcfe>] dev_queue_xmit+0x2f2/0x313
>  [<ffffffff8022b25c>] local_bh_enable+0x9/0xa4
>  [<ffffffff8023356b>] lock_sock+0xa7/0xb2
>  [<ffffffff80260711>] _spin_lock_bh+0x9/0x14
>  [<ffffffff80230e57>] release_sock+0x13/0xaa
>  [<ffffffff8022b25c>] local_bh_enable+0x9/0xa4
>  [<ffffffff8023356b>] lock_sock+0xa7/0xb2
>  [<ffffffff8023af7b>] d_instantiate+0x4a/0x82
>  [<ffffffff802408aa>] d_rehash+0x21/0x34
>  [<ffffffff8022b16f>] sys_recvfrom+0xd4/0x137
>  [<ffffffff803ed57c>] move_addr_to_user+0x5d/0x78
>  [<ffffffff803ed641>] sys_getpeername+0x9f/0xb5
>  [<ffffffff8025c621>] tracesys+0xa7/0xb2
>
>
>   

