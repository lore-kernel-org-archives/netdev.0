From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer in __netdev_pick_tx()
Date: Mon, 06 Jul 2015 12:41:19 +0200
Message-ID: <1436179279.25714.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <559A3B9C.90905@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel <xen-devel@lists.xenproject.org>
To: Bob Liu <bob.liu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38826 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbbGFKlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 06:41:25 -0400
Received: by wibdq8 with SMTP id dq8so149057157wib.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 03:41:24 -0700 (PDT)
In-Reply-To: <559A3B9C.90905@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-07-06 at 16:26 +0800, Bob Liu wrote:
> Hi,
> 
> I tried to run the latest kernel v4.2-rc1, but often got below panic during system boot.
> 
> [   42.118983] BUG: unable to handle kernel paging request at 0000003fffffffff
> [   42.119008] IP: [<ffffffff8161cfd0>] __netdev_pick_tx+0x70/0x120
> [   42.119023] PGD 0 
> [   42.119026] Oops: 0000 [#1] PREEMPT SMP 
> [   42.119031] Modules linked in: bridge stp llc iTCO_wdt iTCO_vendor_support x86_pkg_temp_thermal coretemp pcspkr crc32_pclmul crc32c_intel ghash_clmulni_intel ixgbe ptp pps_core cdc_ether usbnet mii mdio sb_edac dca edac_core wmi i2c_i801 tpm_tis tpm lpc_ich mfd_core ipmi_si ipmi_msghandler shpchp nfsd auth_rpcgss nfs_acl lockd grace sunrpc uinput usb_storage mgag200 i2c_algo_bit drm_kms_helper ttm drm i2c_core nvme mpt2sas raid_class scsi_transport_sas
> [   42.119073] CPU: 12 PID: 0 Comm: swapper/12 Not tainted 4.2.0-rc1 #80
> [   42.119077] Hardware name: Oracle Corporation SUN SERVER X4-4/ASSY,MB WITH TRAY, BIOS 24030400 08/22/2014
> [   42.119081] task: ffff880300b84000 ti: ffff880300b90000 task.ti: ffff880300b90000
> [   42.119085] RIP: e030:[<ffffffff8161cfd0>]  [<ffffffff8161cfd0>] __netdev_pick_tx+0x70/0x120
> [   42.119091] RSP: e02b:ffff880306d03868  EFLAGS: 00010206
> [   42.119093] RAX: ffff8802f676b6b0 RBX: 0000003fffffffff RCX: ffffffff8161cf60
> [   42.119097] RDX: 000000000000001c RSI: ffff8802fe24c900 RDI: ffff8802f96c0000
> [   42.119100] RBP: ffff880306d038a8 R08: 0000000000023240 R09: ffffffff8160fb1c
> [   42.119104] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8802fe24c900
> [   42.119107] R13: 0000000000000000 R14: 00000000ffffffff R15: ffff8802f96c0000
> [   42.119121] FS:  0000000000000000(0000) GS:ffff880306d00000(0000) knlGS:0000000000000000
> [   42.119124] CS:  e033 DS: 002b ES: 002b CR0: 0000000080050033
> [   42.119127] CR2: 0000003fffffffff CR3: 0000000001c1c000 CR4: 0000000000042660
> [   42.119130] Stack:
> [   42.119132]  ffffffff81d63850 ffff8802f63040a0 ffff880306d03888 ffff8802fe24c900
> [   42.119137]  000000000000000e 0000000000000000 ffff8802f96c0000 ffff8802fe24c400
> [   42.119141]  ffff880306d038e8 ffffffffa028bea4 ffffffff8189cfe0 ffffffff81d1b900
> [   42.119146] Call Trace:
> [   42.119149]  <IRQ> 
> [   42.119160]  [<ffffffffa028bea4>] ixgbe_select_queue+0xc4/0x150 [ixgbe]
> [   42.119167]  [<ffffffff816240ee>] netdev_pick_tx+0x5e/0xf0
> [   42.119170]  [<ffffffff81624210>] __dev_queue_xmit+0x90/0x560
> [   42.119174]  [<ffffffff816246f3>] dev_queue_xmit_sk+0x13/0x20
> [   42.119181]  [<ffffffffa02d2b3a>] br_dev_queue_push_xmit+0x4a/0x80 [bridge]
> [   42.119186]  [<ffffffffa02d2cca>] br_forward_finish+0x2a/0x80 [bridge]
> [   42.119191]  [<ffffffffa02d2da8>] __br_forward+0x88/0x110 [bridge]
> [   42.119198]  [<ffffffff8160e18e>] ? __skb_clone+0x2e/0x140
> [   42.119202]  [<ffffffff8160fb33>] ? skb_clone+0x63/0xa0
> [   42.119206]  [<ffffffffa02d2d20>] ? br_forward_finish+0x80/0x80 [bridge]
> [   42.119211]  [<ffffffffa02d2ac7>] deliver_clone+0x37/0x60 [bridge]
> [   42.119215]  [<ffffffffa02d2c38>] br_flood+0xc8/0x130 [bridge]
> [   42.119220]  [<ffffffffa02d2d20>] ? br_forward_finish+0x80/0x80 [bridge]
> [   42.119255]  [<ffffffffa02d3229>] br_flood_forward+0x19/0x20 [bridge]
> [   42.119260]  [<ffffffffa02d4188>] br_handle_frame_finish+0x258/0x590 [bridge]
> [   42.119266]  [<ffffffff8172b5d0>] ? get_partial_node.isra.63+0x1b7/0x1d4
> [   42.119272]  [<ffffffffa02d4606>] br_handle_frame+0x146/0x270 [bridge]
> [   42.119277]  [<ffffffff8168ed39>] ? udp_gro_receive+0x129/0x150
> [   42.119281]  [<ffffffff81621836>] __netif_receive_skb_core+0x1d6/0xa20
> [   42.119286]  [<ffffffff81697a1d>] ? inet_gro_receive+0x9d/0x230
> [   42.119290]  [<ffffffff81622098>] __netif_receive_skb+0x18/0x60
> [   42.119294]  [<ffffffff81622113>] netif_receive_skb_internal+0x33/0xb0
> [   42.119297]  [<ffffffff81622d3f>] napi_gro_receive+0xbf/0x110
> [   42.119303]  [<ffffffffa028def0>] ixgbe_clean_rx_irq+0x490/0x9e0 [ixgbe]
> [   42.119308]  [<ffffffffa028f0c0>] ixgbe_poll+0x420/0x790 [ixgbe]
> [   42.119312]  [<ffffffff8162255d>] net_rx_action+0x15d/0x340
> [   42.119321]  [<ffffffff81095426>] __do_softirq+0xe6/0x2f0
> [   42.119324]  [<ffffffff81095904>] irq_exit+0xf4/0x100
> [   42.119333]  [<ffffffff814275c9>] xen_evtchn_do_upcall+0x39/0x50
> [   42.119340]  [<ffffffff817367de>] xen_do_hypervisor_callback+0x1e/0x30
> [   42.119343]  <EOI> 
> [   42.119348]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
> [   42.119351]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
> [   42.119356]  [<ffffffff8100bbf0>] ? xen_safe_halt+0x10/0x20
> [   42.119362]  [<ffffffff8101feab>] ? default_idle+0x1b/0xf0
> [   42.119365]  [<ffffffff8102062f>] ? arch_cpu_idle+0xf/0x20
> [   42.119370]  [<ffffffff810d273b>] ? default_idle_call+0x3b/0x50
> [   42.119374]  [<ffffffff810d2a7f>] ? cpu_startup_entry+0x2bf/0x350
> [   42.119379]  [<ffffffff8101290a>] ? cpu_bringup_and_idle+0x2a/0x40
> [   42.119382] Code: 8b 87 e8 03 00 00 48 85 c0 0f 84 af 00 00 00 41 8b 94 24 ac 00 00 00 83 ea 01 48 8d 44 d0 10 48 8b 18 48 85 db 0f 84 93 00 00 00 <8b> 03 83 f8 01 74 6b 41 f6 84 24 91 00 00 00 30 74 66 41 8b 94 
> [   42.119414] RIP  [<ffffffff8161cfd0>] __netdev_pick_tx+0x70/0x120
> [   42.119418]  RSP <ffff880306d03868>
> [   42.119420] CR2: 0000003fffffffff
> [   42.119425] ---[ end trace cbc4abc4d5c3f8b2 ]---
> [   43.391014] BUG: unable to handle kernel paging request at 0000003fffffffff
> [   43.391023] IP: [<ffffffff8161cfd0>] __netdev_pick_tx+0x70/0x120
> [   43.391030] PGD 0 
> [   43.391032] Oops: 0000 [#2] PREEMPT SMP 
> [   43.391036] Modules linked in: bridge stp llc iTCO_wdt iTCO_vendor_support x86_pkg_temp_thermal coretemp pcspkr crc32_pclmul crc32c_intel ghash_clmulni_intel ixgbe ptp pps_core cdc_ether usbnet mii mdio sb_edac dca edac_core wmi i2c_i801 tpm_tis tpm lpc_ich mfd_core ipmi_si ipmi_msghandler shpchp nfsd auth_rpcgss nfs_acl lockd grace sunrpc uinput usb_storage mgag200 i2c_algo_bit drm_kms_helper ttm drm i2c_core nvme mpt2sas raid_class scsi_transport_sas
> [   43.391070] CPU: 14 PID: 0 Comm: swapper/14 Tainted: G      D         4.2.0-rc1 #80
> [   43.391074] Hardware name: Oracle Corporation SUN SERVER X4-4/ASSY,MB WITH TRAY, BIOS 24030400 08/22/2014
> [   43.391078] task: ffff880300b98000 ti: ffff880300ba0000 task.ti: ffff880300ba0000
> [   43.391081] RIP: e030:[<ffffffff8161cfd0>]  [<ffffffff8161cfd0>] __netdev_pick_tx+0x70/0x120
> [   43.391086] RSP: e02b:ffff880306d83868  EFLAGS: 00010206
> [   43.391089] RAX: ffff8802f676b6c0 RBX: 0000003fffffffff RCX: ffffffff8161cf60
> [   43.391092] RDX: 000000000000001e RSI: ffff8802ff0aa400 RDI: ffff8802f96c0000
> [   43.391095] RBP: ffff880306d838a8 R08: 0000000000023240 R09: ffffffff8160fb1c
> [   43.391099] R10: 0000000000000000 R11: ffffea000bd88580 R12: ffff8802ff0aa400
> [   43.391102] R13: 0000000000000000 R14: 00000000ffffffff R15: ffff8802f96c0000
> [   43.391108] FS:  0000000000000000(0000) GS:ffff880306d80000(0000) knlGS:0000000000000000
> [   43.391111] CS:  e033 DS: 002b ES: 002b CR0: 0000000080050033
> [   43.391114] CR2: 0000003fffffffff CR3: 0000000001c1c000 CR4: 0000000000042660
> [   43.391118] Stack:
> [   43.391119]  0000000000000000 0000000000000000 0000000000000000 ffff8802ff0aa400
> [   43.391124]  000000000000000e 0000000000000000 ffff8802f96c0000 ffff8802ff0aad00
> [   43.391128]  ffff880306d838e8 ffffffffa028bea4 0000000000000000 0000000000000000
> [   43.391133] Call Trace:
> [   43.391135]  <IRQ> 
> [   43.391141]  [<ffffffffa028bea4>] ixgbe_select_queue+0xc4/0x150 [ixgbe]
> [   43.391146]  [<ffffffff816240ee>] netdev_pick_tx+0x5e/0xf0
> [   43.391150]  [<ffffffff81624210>] __dev_queue_xmit+0x90/0x560
> [   43.391154]  [<ffffffff816246f3>] dev_queue_xmit_sk+0x13/0x20
> [   43.391160]  [<ffffffffa02d2b3a>] br_dev_queue_push_xmit+0x4a/0x80 [bridge]
> [   43.391165]  [<ffffffffa02d2cca>] br_forward_finish+0x2a/0x80 [bridge]
> [   43.391170]  [<ffffffffa02d2da8>] __br_forward+0x88/0x110 [bridge]
> [   43.391177]  [<ffffffff81388f01>] ? list_del+0x11/0x40
> [   43.391181]  [<ffffffff8160e18e>] ? __skb_clone+0x2e/0x140
> [   43.391184]  [<ffffffff8160fb33>] ? skb_clone+0x63/0xa0
> [   43.391188]  [<ffffffffa02d2d20>] ? br_forward_finish+0x80/0x80 [bridge]
> [   43.391193]  [<ffffffffa02d2ac7>] deliver_clone+0x37/0x60 [bridge]
> [   43.391198]  [<ffffffffa02d2c38>] br_flood+0xc8/0x130 [bridge]
> [   43.391202]  [<ffffffffa02d2d20>] ? br_forward_finish+0x80/0x80 [bridge]
> [   43.391207]  [<ffffffffa02d3229>] br_flood_forward+0x19/0x20 [bridge]
> [   43.391212]  [<ffffffffa02d4188>] br_handle_frame_finish+0x258/0x590 [bridge]
> [   43.391216]  [<ffffffff8172b5d0>] ? get_partial_node.isra.63+0x1b7/0x1d4
> [   43.391221]  [<ffffffffa02d4606>] br_handle_frame+0x146/0x270 [bridge]
> [   43.391224]  [<ffffffff8172b95f>] ? __slab_alloc+0x193/0x4a3
> [   43.391228]  [<ffffffff81621836>] __netif_receive_skb_core+0x1d6/0xa20
> [   43.391233]  [<ffffffff81622098>] __netif_receive_skb+0x18/0x60
> [   43.391236]  [<ffffffff81622113>] netif_receive_skb_internal+0x33/0xb0
> [   43.391240]  [<ffffffff81622d3f>] napi_gro_receive+0xbf/0x110
> [   43.391246]  [<ffffffffa028def0>] ixgbe_clean_rx_irq+0x490/0x9e0 [ixgbe]
> [   43.391251]  [<ffffffffa028f0c0>] ixgbe_poll+0x420/0x790 [ixgbe]
> [   43.391255]  [<ffffffff8162255d>] net_rx_action+0x15d/0x340
> [   43.391259]  [<ffffffff81095426>] __do_softirq+0xe6/0x2f0
> [   43.391263]  [<ffffffff81095904>] irq_exit+0xf4/0x100
> [   43.391267]  [<ffffffff814275c9>] xen_evtchn_do_upcall+0x39/0x50
> [   43.391271]  [<ffffffff817367de>] xen_do_hypervisor_callback+0x1e/0x30
> [   43.391274]  <EOI> 
> [   43.391277]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
> [   43.391280]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
> [   43.391285]  [<ffffffff8100bbf0>] ? xen_safe_halt+0x10/0x20
> [   43.391289]  [<ffffffff8101feab>] ? default_idle+0x1b/0xf0
> [   43.391296]  [<ffffffff8102062f>] ? arch_cpu_idle+0xf/0x20
> [   43.391301]  [<ffffffff810d273b>] ? default_idle_call+0x3b/0x50
> [   43.391307]  [<ffffffff810d2a7f>] ? cpu_startup_entry+0x2bf/0x350
> [   43.391318]  [<ffffffff8101290a>] ? cpu_bringup_and_idle+0x2a/0x40
> [   43.391324] Code: 8b 87 e8 03 00 00 48 85 c0 0f 84 af 00 00 00 41 8b 94 24 ac 00 00 00 83 ea 01 48 8d 44 d0 10 48 8b 18 48 85 db 0f 84 93 00 00 00 <8b> 03 83 f8 01 74 6b 41 f6 84 24 91 00 00 00 30 74 66 41 8b 94 
> [   43.391358] RIP  [<ffffffff8161cfd0>] __netdev_pick_tx+0x70/0x120
> [   43.391362]  RSP <ffff880306d83868>
> [   43.391364] CR2: 0000003fffffffff
> [   43.391368] ---[ end trace cbc4abc4d5c3f8b3 ]---
> [   43.393487] Kernel panic - not syncing: Fatal exception in interrupt
> 

Hi Bob

I am suspecting something similar to what
c29390c6dfeee0944ac6b5610ebbe403944378fc ("xps: must clear sender_cpu
before forwarding") attempted to fix.

Trying to keep sk_buff small is hard.

Could you try something like :

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index e97572b5d2cc..0ff6e1bbca91 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -42,6 +42,7 @@ int br_dev_queue_push_xmit(struct sock *sk, struct sk_buff *skb)
 	} else {
 		skb_push(skb, ETH_HLEN);
 		br_drop_fake_rtable(skb);
+		skb_sender_cpu_clear(skb);
 		dev_queue_xmit(skb);
 	}
 
