From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Wed, 26 Mar 2008 13:26:00 -0700
Message-ID: <47EAB158.3080806@sun.com>
References: <47EA7DE8.9070203@sun.com> <47EAAE9A.9050305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:61729 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756517AbYCZU1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 16:27:17 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m2QKRGDF008800
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 13:27:16 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JYC00J01TPI2F00@fe-sfbay-09.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Wed,
 26 Mar 2008 13:27:16 -0700 (PDT)
In-reply-to: <47EAAE9A.9050305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Matheos Worku wrote, On 03/26/2008 05:46 PM:
> ...
>
>   
>> outside the driver as well.  I have attached several lockup  error 
>> traces and corresponding profile data. Any clues?
>>     
>
> Are network cards' irqs balanced? If so, could you reproduce this
> with affinity set?
>
> Regards,
> Jarek P.
>   
Jarek,

Reproduced the lockup with irqbalance disabled and with single src of 
interrupt (TX interrupt, UDP transmit).  Lockup appears in different 
location though.

Regards
matheos

irq of interest: 454 (TX interrupt)


454:      19249      93234     907186       2691          0        
188          0        160   PCI-MSI-edge      eth6
455:      22607      15083          5      13104      25569     
161519      62514      25637   PCI-MSI-edge      eth6
456:      22390      14921          5      24605      37438     
110453     251315         66   PCI-MSI-edge      eth6
457:      11109      26849          2      58895     251720         
84          0      67420   PCI-MSI-edge      eth6
458:      22348      15859          1      21978      27839      
10231          0     267743   PCI-MSI-edge      eth6
459:      19922      15331          2      59275          0     
149788      12394      82549   PCI-MSI-edge      eth6
460:      22928      19058          4       1268      49775     
183189     160901      25150   PCI-MSI-edge      eth6
461:        497      32134          1      31428          0      
69182      68889      45407   PCI-MSI-edge      eth6
462:      11932      23212         10      11355     120509      
47588          1     118637   PCI-MSI-edge      eth6
463:          0          0          0          0          0          
0          0          0   PCI-MSI-edge      eth6
464:          0          0          0          0          0          
0          0          0   PCI-MSI-edge      eth6
465:          0          0          0          0          0          
0          0          0   PCI-MSI-edge      eth6



.......

454:      19249     126519     907186       2691          0        
188          0        160   PCI-MSI-edge      eth6
455:      22609      15083          5      13104      25569     
161519      62514      25637   PCI-MSI-edge      eth6
456:      22390      14923          5      24605      37438     
110453     251315         66   PCI-MSI-edge      eth6
457:      11109      26849          2      58895     251720         
84          0      67420   PCI-MSI-edge      eth6
458:      22348      15867          1      21978      27839      
10231          0     267744   PCI-MSI-edge      eth6
459:      19922      15331          2      59275          0     
149788      12394      82549   PCI-MSI-edge      eth6
460:      22928      19058          4       1268      49775     
183189     160901      25150   PCI-MSI-edge      eth6
461:        498      32134          1      31428          0      
69182      68889      45407   PCI-MSI-edge      eth6
462:      11932      23216         10      11355     120509      
47588          1     118637   PCI-MSI-edge      eth6
463:          0          0          0          0          0          
0          0          0   PCI-MSI-edge      eth6
464:          0          0          0          0          0          
0          0          0   PCI-MSI-edge      eth6
465:          0          0          0          0          0          
0          0          0   PCI-MSI-edge      eth6




nsn57-110 login: BUG: soft lockup - CPU#2 stuck for 11s! 
[uperf.x86_64:16606]
CPU 2:
Modules linked in: ixgbe oprofile niu nfs lockd nfs_acl autofs4 hidp 
rfcomm l2cap bluetooth sunrpc ipv6 cpufreq_ondemand rdma_ucm ib_ucm 
rdma_cm iw_cm ib_addr ib_srp scsi_transport_srp ib_cm ib_ipoib ib_sa 
ib_uverbs ib_umad ib_mad ib_core dm_multipath battery ac parport_pc lp 
parport joydev sr_mod sg e1000 button i2c_nforce2 pcspkr shpchp i2c_core 
dm_snapshot dm_zero dm_mirror dm_mod usb_storage mptsas mptscsih mptbase 
scsi_transport_sas sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd
Pid: 16606, comm: uperf.x86_64 Not tainted 2.6.24-mati #3
RIP: 0010:[<ffffffff803ef525>]  [<ffffffff803ef525>] 
__copy_skb_header+0x10d/0x134
RSP: 0018:ffff8101ae14ba38  EFLAGS: 00000246
RAX: 0000000020000000 RBX: ffff8101d059a400 RCX: 000000000000000c
RDX: 0000000000000000 RSI: ffff8101d059a468 RDI: ffff8101f7db4868
RBP: ffff8101ffe50d80 R08: ffff8101f7db4800 R09: ffff8101d059a400
R10: 00000001b1c64660 R11: ffffffff80221995 R12: 0000000000000000
R13: 0000000100000000 R14: ffffffff802858e4 R15: ffff8101fec71900
FS:  0000000040800940(0063) GS:ffff8101fb072700(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000044005f48 CR3: 00000001d0513000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 [<ffffffff803ef5f6>] __skb_clone+0x24/0xdc
 [<ffffffff803f152e>] skb_realloc_headroom+0x30/0x63
 [<ffffffff882edd40>] :niu:niu_start_xmit+0x114/0x5af
 [<ffffffff80221995>] gart_map_single+0x0/0x70
 [<ffffffff803f5e2b>] dev_hard_start_xmit+0x1d2/0x246
 [<ffffffff80406fb8>] pfifo_fast_dequeue+0x3b/0x59
 [<ffffffff80406dab>] __qdisc_run+0x77/0x174
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

BUG: soft lockup - CPU#2 stuck for 11s! [uperf.x86_64:16606]
CPU 2:
Modules linked in: ixgbe oprofile niu nfs lockd nfs_acl autofs4 hidp 
rfcomm l2cap bluetooth sunrpc ipv6 cpufreq_ondemand rdma_ucm ib_ucm 
rdma_cm iw_cm ib_addr ib_srp scsi_transport_srp ib_cm ib_ipoib ib_sa 
ib_uverbs ib_umad ib_mad ib_core dm_multipath battery ac parport_pc lp 
parport joydev sr_mod sg e1000 button i2c_nforce2 pcspkr shpchp i2c_core 
dm_snapshot dm_zero dm_mirror dm_mod usb_storage mptsas mptscsih mptbase 
scsi_transport_sas sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd
Pid: 16606, comm: uperf.x86_64 Not tainted 2.6.24-mati #3
RIP: 0010:[<ffffffff803ef462>]  [<ffffffff803ef462>] 
__copy_skb_header+0x4a/0x134
RSP: 0018:ffff8101ae14ba38  EFLAGS: 00000202
RAX: ffff8101fa048300 RBX: ffff8103fb35c100 RCX: ffffffff803f0453
RDX: ffff8101fa1e5d00 RSI: ffff8103fb35c100 RDI: ffff8101fa1e5d00
RBP: 0000000000000020 R08: ffff8101fa1e5d00 R09: ffff8103fb35c100
R10: 00000001c6920e60 R11: ffffffff80221995 R12: ffff810100052cc0
R13: ffffffff805abb88 R14: ffff8101ff231b80 R15: 0000000000000000
FS:  0000000040800940(0063) GS:ffff8101fb072700(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000044005f48 CR3: 00000001d0513000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 [<ffffffff803ef5f6>] __skb_clone+0x24/0xdc
 [<ffffffff803f152e>] skb_realloc_headroom+0x30/0x63
 [<ffffffff882edd40>] :niu:niu_start_xmit+0x114/0x5af
 [<ffffffff80221995>] gart_map_single+0x0/0x70
 [<ffffffff803f5e2b>] dev_hard_start_xmit+0x1d2/0x246
 [<ffffffff80406daf>] __qdisc_run+0x7b/0x174
 [<ffffffff80406dab>] __qdisc_run+0x77/0x174
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

BUG: soft lockup - CPU#2 stuck for 11s! [uperf.x86_64:16606]
CPU 2:
Modules linked in: ixgbe oprofile niu nfs lockd nfs_acl autofs4 hidp 
rfcomm l2cap bluetooth sunrpc ipv6 cpufreq_ondemand rdma_ucm ib_ucm 
rdma_cm iw_cm ib_addr ib_srp scsi_transport_srp ib_cm ib_ipoib ib_sa 
ib_uverbs ib_umad ib_mad ib_core dm_multipath battery ac parport_pc lp 
parport joydev sr_mod sg e1000 button i2c_nforce2 pcspkr shpchp i2c_core 
dm_snapshot dm_zero dm_mirror dm_mod usb_storage mptsas mptscsih mptbase 
scsi_transport_sas sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd
Pid: 16606, comm: uperf.x86_64 Not tainted 2.6.24-mati #3
RIP: 0010:[<ffffffff803f065e>]  [<ffffffff803f065e>] 
pskb_expand_head+0x73/0x147
RSP: 0018:ffff8101ae14ba18  EFLAGS: 00000286
RAX: 0000000000000080 RBX: ffff8101c6476080 RCX: 000000000000059f
RDX: 0000000000000138 RSI: ffff8103f64ad841 RDI: ffff8101c64760c1
RBP: 0000000000000000 R08: ffff8101fb0722cb R09: 0000000000000002
R10: 0000000000000001 R11: 0000000000000002 R12: ffffffff8028725b
R13: ffff8101c6478000 R14: ffff8101ff191d80 R15: ffffffff805abb88
FS:  0000000040800940(0063) GS:ffff8101fb072700(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000044005f48 CR3: 00000001d0513000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 [<ffffffff803f0630>] pskb_expand_head+0x45/0x147
 [<ffffffff803f154b>] skb_realloc_headroom+0x4d/0x63
 [<ffffffff882edd40>] :niu:niu_start_xmit+0x114/0x5af
 [<ffffffff80221995>] gart_map_single+0x0/0x70
 [<ffffffff803f5e2b>] dev_hard_start_xmit+0x1d2/0x246
 [<ffffffff80406fb8>] pfifo_fast_dequeue+0x3b/0x59
 [<ffffffff80406dab>] __qdisc_run+0x77/0x174
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


