From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: kernel WARNING on skb_complete_tx_timestamp
Date: Sat, 11 Apr 2015 01:34:58 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5857511D7A@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Richard Cochran (richardcochran@gmail.com)"
	<richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:53712 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755239AbbDKBfB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 21:35:01 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

I don't know if you'd know this but I believe you're the best person to ask. If anyone else has an answer please feel free to chime in.

[ 2744.552823] Modules linked in: fm10k(OE) vxlan ip6_udp_tunnel udp_tunnel uio fuse xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack tun bridge stp llc openvswitch libcrc32c joydev x86_pkg_temp_thermal coretemp kvm_intel kvm mei_me crct10dif_pclmul crc32_pclmul wmi crc32c_intel mei ipmi_ssif iTCO_wdt iTCO_vendor_support ipmi_devintf ghash_clmulni_intel lpc_ich ipmi_si tpm_tis mfd_core tpm ipmi_msghandler ioatdma sb_edac shpchp edac_core i2c_i801 mgag200 drm_kms_helper ttm drm isci igb firewire_ohci firewire_core libsas ptp crc_itu_t dca scsi_transport_sas pps_core i2c_algo_bit [last unloaded: fm10k]
[ 2744.552896] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W  OE  3.19.3-200.fc21.x86_64 #1
[ 2744.552899] Hardware name: Intel Corporation S2600CO/S2600CO, BIOS SE5C600.86B.02.03.8x23.060520140825 06/05/2014
[ 2744.552901]  0000000000000000 2f4c8b10ea3f9848 ffff88081ee03a38 ffffffff8176e215
[ 2744.552906]  0000000000000000 0000000000000000 ffff88081ee03a78 ffffffff8109bc1a
[ 2744.552910]  ffff88081ee03c50 ffff88080e55fc00 ffff88080e55fc00 ffffffff81647c50
[ 2744.552914] Call Trace:
[ 2744.552917]  <IRQ>  [<ffffffff8176e215>] dump_stack+0x45/0x57
[ 2744.552931]  [<ffffffff8109bc1a>] warn_slowpath_common+0x8a/0xc0
[ 2744.552936]  [<ffffffff81647c50>] ? skb_queue_purge+0x20/0x40
[ 2744.552941]  [<ffffffff8109bd4a>] warn_slowpath_null+0x1a/0x20
[ 2744.552946]  [<ffffffff81646911>] skb_release_head_state+0xe1/0xf0
[ 2744.552950]  [<ffffffff81647b26>] skb_release_all+0x16/0x30
[ 2744.552954]  [<ffffffff81647ba6>] kfree_skb+0x36/0x90
[ 2744.552958]  [<ffffffff81647c50>] skb_queue_purge+0x20/0x40
[ 2744.552964]  [<ffffffff81751f8d>] packet_sock_destruct+0x1d/0x90
[ 2744.552968]  [<ffffffff81642053>] __sk_free+0x23/0x140
[ 2744.552973]  [<ffffffff81642189>] sk_free+0x19/0x20
[ 2744.552977]  [<ffffffff81647d60>] skb_complete_tx_timestamp+0x50/0x60
[ 2744.552988]  [<ffffffffa02eee40>] fm10k_ts_tx_hwtstamp+0xd0/0x100 [fm10k]
[ 2744.552994]  [<ffffffffa02e054e>] fm10k_1588_msg_pf+0x12e/0x140 [fm10k]
[ 2744.553002]  [<ffffffffa02edf1d>] fm10k_tlv_msg_parse+0x8d/0xc0 [fm10k]
[ 2744.553010]  [<ffffffffa02eb2d0>] fm10k_mbx_dequeue_rx+0x60/0xb0 [fm10k]
[ 2744.553016]  [<ffffffffa02ebf98>] fm10k_sm_mbx_process+0x178/0x3c0 [fm10k]
[ 2744.553022]  [<ffffffffa02e09ca>] fm10k_msix_mbx_pf+0xfa/0x360 [fm10k]
[ 2744.553030]  [<ffffffff811030a7>] ? get_next_timer_interrupt+0x1f7/0x270
[ 2744.553036]  [<ffffffff810f2a47>] handle_irq_event_percpu+0x77/0x1a0
[ 2744.553041]  [<ffffffff810f2bab>] handle_irq_event+0x3b/0x60
[ 2744.553045]  [<ffffffff810f5d6e>] handle_edge_irq+0x6e/0x120
[ 2744.553054]  [<ffffffff81017414>] handle_irq+0x74/0x140
[ 2744.553061]  [<ffffffff810bb54a>] ? atomic_notifier_call_chain+0x1a/0x20
[ 2744.553066]  [<ffffffff8177777f>] do_IRQ+0x4f/0xf0
[ 2744.553072]  [<ffffffff8177556d>] common_interrupt+0x6d/0x6d
[ 2744.553074]  <EOI>  [<ffffffff81609b16>] ? cpuidle_enter_state+0x66/0x160
[ 2744.553084]  [<ffffffff81609b01>] ? cpuidle_enter_state+0x51/0x160
[ 2744.553087]  [<ffffffff81609cf7>] cpuidle_enter+0x17/0x20
[ 2744.553092]  [<ffffffff810de101>] cpu_startup_entry+0x321/0x3c0
[ 2744.553098]  [<ffffffff81764497>] rest_init+0x77/0x80
[ 2744.553103]  [<ffffffff81d4f02c>] start_kernel+0x4a4/0x4c5
[ 2744.553107]  [<ffffffff81d4e120>] ? early_idt_handlers+0x120/0x120
[ 2744.553110]  [<ffffffff81d4e4d7>] x86_64_start_reservations+0x2a/0x2c
[ 2744.553114]  [<ffffffff81d4e62b>] x86_64_start_kernel+0x152/0x175

This occurs because of the WARN_ON in kfree_skb which results from sock_hold(sk) and sock_put(sk)

I have a driver (fm10k) which receives a notification of Tx timestamp via an IRQ, and then when I call skb_complete_tx_timestamp I get this warning. I believe this is a result of calling sk_free, which the description *says* is ok to call in any context.. but then we get this warning.

I'm really not sure exactly how this situation occurred. Eventually we call kfree_skb() while we are in irq context which results in the warning.

Regards,
Jake
