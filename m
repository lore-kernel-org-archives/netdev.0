From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skb_warn_bad_offload with kernel 3.5 (maybe gso/bridge related
 ?)
Date: Fri, 03 Aug 2012 10:51:27 +0200
Message-ID: <1343983887.9299.817.camel@edumazet-glaptop>
References: <501B8792.6040605@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63913 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753374Ab2HCIvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 04:51:33 -0400
Received: by bkwj10 with SMTP id j10so145883bkw.19
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2012 01:51:31 -0700 (PDT)
In-Reply-To: <501B8792.6040605@univ-nantes.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-03 at 10:10 +0200, Yann Dupont wrote:
> Hello everybody,
> 
> I have a machine using ceph rbd volume, as a client (rbd module) to 
> backup data.
> 
> I was running kernel 3.2.22 ok. Tried 3.5.0 because some rbd fixes went in.
> 
> Now, shortly after the start, my logs are filled by that :
> 
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.780860] 
> WARNING: at net/core/dev.c:1888 skb_warn_bad_offload+0xb6/0xc1()
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.780920] 
> Hardware name: PowerEdge M605
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.780990] : 
> caps=(0x0000000000005000, 0x0000000000000000) len=7292 data_len=5792 
> gso_size=1448 gso_type=1 ip_summed=1
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.781071] 
> Modules linked in: rbd libceph ipt_MASQUERADE iptable_nat nf_nat 
> ipt_REJECT veth fuse xt_physdev xt_iprange xt_multiport ip6table_filter 
> ip6_tables xt_LOG xt_limit xt_tcpudp xt_state iptable_filter ip_tables 
> x_tables nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 
> nf_defrag_ipv4 8021q bridge stp llc ext2 mbcache dm_round_robin 
> dm_multipath scsi_dh nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 
> powernow_k8 freq_table mperf kvm_amd snd_pcm kvm snd_timer snd soundcore 
> snd_page_alloc tpm_tis tpm tpm_bios pcspkr evdev psmouse microcode 
> joydev dcdbas shpchp i2c_nforce2 pci_hotplug serio_raw processor 
> i2c_core hid_generic thermal_sys hed button xfs exportfs dm_mod ses 
> enclosure usbhid hid sg sr_mod sd_mod cdrom usb_storage lpfc 
> scsi_transport_fc scsi_tgt ohci_hcd bnx2x mptsas mptscsih bnx2 mptbase 
> scsi_transport_sas crc32c scsi_mod libcrc32c mdio ehci_hcd [last 
> unloaded: scsi_wait_scan]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.785995] 
> Pid: 0, comm: swapper/0 Not tainted 3.5.0-dsiun-120521 #5
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786055] 
> Call Trace:
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786108]  
> <IRQ>  [<ffffffff813bde00>] ? skb_warn_bad_offload+0x6f/0xc1
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786209]  
> [<ffffffff8103a109>] ? warn_slowpath_common+0x79/0xc0
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786269]  
> [<ffffffff8103a205>] ? warn_slowpath_fmt+0x45/0x50
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786330]  
> [<ffffffff81068647>] ? get_nohz_timer_target+0x57/0xd0
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786390]  
> [<ffffffff813bde47>] ? skb_warn_bad_offload+0xb6/0xc1
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786452]  
> [<ffffffff813110e7>] ? skb_gso_segment+0x207/0x280
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786512]  
> [<ffffffff81313f26>] ? dev_hard_start_xmit+0x1f6/0x620
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786574]  
> [<ffffffff8132f17d>] ? sch_direct_xmit+0xfd/0x1d0
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786633]  
> [<ffffffff813147a4>] ? dev_queue_xmit+0x454/0x610
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786697]  
> [<ffffffffa06f3c42>] ? br_dev_queue_push_xmit+0x72/0xc0 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786762]  
> [<ffffffffa06fa673>] ? br_nf_post_routing+0x223/0x340 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786825]  
> [<ffffffff8133c0c4>] ? nf_iterate+0x84/0xa0
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786885]  
> [<ffffffffa06f3bd0>] ? deliver_clone+0x60/0x60 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.786945]  
> [<ffffffff8133c14e>] ? nf_hook_slow+0x6e/0x130
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787005]  
> [<ffffffffa06f3bd0>] ? deliver_clone+0x60/0x60 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787067]  
> [<ffffffffa06f3f00>] ? br_multicast_flood+0x170/0x170 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787130]  
> [<ffffffffa06f3f42>] ? br_forward_finish+0x42/0x50 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787193]  
> [<ffffffffa06f9f29>] ? br_nf_forward_finish+0xb9/0x180 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787256]  
> [<ffffffffa06faa21>] ? br_nf_forward_ip+0x291/0x3d0 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787318]  
> [<ffffffff8133c0c4>] ? nf_iterate+0x84/0xa0
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787379]  
> [<ffffffffa06a301f>] ? tcp_packet+0x82f/0xf10 [nf_conntrack]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787442]  
> [<ffffffffa06f3f00>] ? br_multicast_flood+0x170/0x170 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787503]  
> [<ffffffff8133c14e>] ? nf_hook_slow+0x6e/0x130
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787563]  
> [<ffffffffa06f3f00>] ? br_multicast_flood+0x170/0x170 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787626]  
> [<ffffffffa06f3fe0>] ? __br_forward+0x90/0xb0 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787688]  
> [<ffffffffa06f4e34>] ? br_handle_frame_finish+0x214/0x2b0 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787765]  
> [<ffffffffa06fa2ab>] ? br_nf_pre_routing_finish+0x19b/0x340 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787842]  
> [<ffffffffa06fb0f2>] ? br_nf_pre_routing+0x3a2/0x650 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787904]  
> [<ffffffff8108b184>] ? generic_exec_single+0xb4/0xc0
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.787964]  
> [<ffffffff8133c0c4>] ? nf_iterate+0x84/0xa0
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788025]  
> [<ffffffffa06f4c20>] ? br_handle_local_finish+0x50/0x50 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788087]  
> [<ffffffff8133c14e>] ? nf_hook_slow+0x6e/0x130
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788147]  
> [<ffffffffa06f4c20>] ? br_handle_local_finish+0x50/0x50 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788210]  
> [<ffffffffa06f5098>] ? br_handle_frame+0x1c8/0x260 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788273]  
> [<ffffffffa06f4ed0>] ? br_handle_frame_finish+0x2b0/0x2b0 [bridge]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788348]  
> [<ffffffff813121b8>] ? __netif_receive_skb+0x418/0x5a0
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788409]  
> [<ffffffffa0736954>] ? ipt_do_table+0x344/0x5e0 [ip_tables]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788470]  
> [<ffffffff813124ca>] ? netif_receive_skb+0x1a/0x80
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788530]  
> [<ffffffff81312620>] ? napi_skb_finish+0x50/0x70
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788599]  
> [<ffffffffa0126bc6>] ? bnx2x_rx_int+0x656/0x13d0 [bnx2x]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788671]  
> [<ffffffffa01994ae>] ? lpfc_sli_handle_fast_ring_event+0x26e/0x5d0 [lpfc]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788748]  
> [<ffffffffa071abf5>] ? ipv4_confirm+0x175/0x200 [nf_conntrack_ipv4]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788828]  
> [<ffffffffa0129073>] ? bnx2x_poll+0x93/0x2b0 [bnx2x]
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788889]  
> [<ffffffff81312e98>] ? net_rx_action+0x138/0x220
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.788949]  
> [<ffffffff810424ae>] ? __do_softirq+0xae/0x1c0
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789009]  
> [<ffffffff813c281c>] ? call_softirq+0x1c/0x30
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789068]  
> [<ffffffff81004b95>] ? do_softirq+0x75/0xb0
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789127]  
> [<ffffffff81042845>] ? irq_exit+0xa5/0xb0
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789185]  
> [<ffffffff8100480b>] ? do_IRQ+0x5b/0xd0
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789243]  
> [<ffffffff813c0aea>] ? common_interrupt+0x6a/0x6a
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789301]  
> <EOI>  [<ffffffff8104ac21>] ? get_next_timer_interrupt+0x1e1/0x280
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789414]  
> [<ffffffff8102ab82>] ? native_safe_halt+0x2/0x10
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789474]  
> [<ffffffff8100b847>] ? default_idle+0x47/0x190
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789533]  
> [<ffffffff8100b9e0>] ? amd_e400_idle+0x50/0x110
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789593]  
> [<ffffffff8100c466>] ? cpu_idle+0xb6/0xd0
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789651]  
> [<ffffffff8157fb77>] ? start_kernel+0x366/0x371
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789711]  
> [<ffffffff8157f627>] ? repair_env_string+0x5b/0x5b
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789771]  
> [<ffffffff8157f436>] ? x86_64_start_kernel+0x105/0x114
> Jul 31 18:15:01 singleton.u06.univ-nantes.prive kernel: [ 1175.789831] 
> ---[ end trace ad41e3fec21667dd ]---
> 
> 
> Shorter traces :
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537129] 
> WARNING: at net/core/dev.c:1888 skb_warn_bad_offload+0xb6/0xc1()
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537156] 
> Hardware name: PowerEdge M605
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537178] : 
> caps=(0x0000000000005000, 0x0000000000000000) len=23220 data_len=21720 
> gso_size=1448 gso_type=1 ip_summed=1
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537226] 
> Modules linked in: rbd libceph ipt_MASQUERADE iptable_nat nf_nat 
> ipt_REJECT veth fuse xt_physdev xt_iprange xt_multiport ip6table_filter 
> ip6_tables xt_LOG xt_limit xt_tcpudp xt_state iptable_filter ip_tables 
> x_tables nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 
> nf_defrag_ipv4 8021q bridge stp llc ext2 mbcache dm_round_robin 
> dm_multipath scsi_dh nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 
> powernow_k8 freq_table mperf kvm_amd snd_pcm kvm snd_timer snd soundcore 
> snd_page_alloc tpm_tis tpm tpm_bios pcspkr evdev psmouse microcode 
> joydev dcdbas shpchp i2c_nforce2 pci_hotplug serio_raw processor 
> i2c_core hid_generic thermal_sys hed button xfs exportfs dm_mod ses 
> enclosure usbhid hid sg sr_mod sd_mod cdrom usb_storage lpfc 
> scsi_transport_fc scsi_tgt ohci_hcd bnx2x mptsas mptscsih bnx2 mptbase 
> scsi_transport_sas crc32c scsi_mod libcrc32c mdio ehci_hcd [last 
> unloaded: scsi_wait_scan]
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537632] 
> Pid: 22553, comm: smtp Tainted: G        W 3.5.0-dsiun-120521 #5
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537673] 
> Call Trace:
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537691]  
> <IRQ>  [<ffffffff813bde00>] ? skb_warn_bad_offload+0x6f/0xc1
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537720]  
> [<ffffffff8103a109>] ? warn_slowpath_common+0x79/0xc0
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537747]  
> [<ffffffff8103a205>] ? warn_slowpath_fmt+0x45/0x50
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537773]  
> [<ffffffff813bde47>] ? skb_warn_bad_offload+0xb6/0xc1
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537800]  
> [<ffffffff813110e7>] ? skb_gso_segment+0x207/0x280
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537826]  
> [<ffffffff81313f26>] ? dev_hard_start_xmit+0x1f6/0x620
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537853]  
> [<ffffffff8132f17d>] ? sch_direct_xmit+0xfd/0x1d0
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537879]  
> [<ffffffff813147a4>] ? dev_queue_xmit+0x454/0x610
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537907]  
> [<ffffffffa06f3c42>] ? br_dev_queue_push_xmit+0x72/0xc0 [bridge]
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.537937]  
> [<ffffffffa06fa673>] ? br_nf_post_routing+0x223/0x340 [bridge]
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.538103]  
> [<ffffffffa06f3f42>] ? br_forward_finish+0x42/0x50 [bridge]
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.538132]  
> [<ffffffffa06f9f29>] ? br_nf_forward_finish+0xb9/0x180 [bridge]
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.538704]  
> [<ffffffff813124ca>] ? netif_receive_skb+0x1a/0x80
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.539024]  
> <EOI>
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.539162] : 
> caps=(0x0000000000005000, 0x0000000000000000) len=6250 data_len=4750 
> gso_size=1448 gso_type=1 ip_summed=1
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.539209] 
> Modules linked in: rbd libceph ipt_MASQUERADE iptable_nat nf_nat 
> ipt_REJECT veth fuse xt_physdev xt_iprange xt_multiport ip6table_filter 
> ip6_tables xt_LOG xt_limit xt_tcpudp xt_state iptable_filter ip_tables 
> x_tables nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 
> nf_defrag_ipv4 8021q bridge stp llc ext2 mbcache dm_round_robin 
> dm_multipath scsi_dh nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 
> powernow_k8 freq_table mperf kvm_amd snd_pcm kvm snd_timer snd soundcore 
> snd_page_alloc tpm_tis tpm tpm_bios pcspkr evdev psmouse microcode 
> joydev dcdbas shpchp i2c_nforce2 pci_hotplug serio_raw processor 
> i2c_core hid_generic thermal_sys hed button xfs exportfs dm_mod ses 
> enclosure usbhid hid sg sr_mod sd_mod cdrom usb_storage lpfc 
> scsi_transport_fc scsi_tgt ohci_hcd bnx2x mptsas mptscsih bnx2 mptbase 
> scsi_transport_sas crc32c scsi_mod libcrc32c mdio ehci_hcd [last 
> unloaded: scsi_wait_scan]
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.539614] 
> Pid: 22553, comm: smtp Tainted: G        W 3.5.0-dsiun-120521 #5
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.539654] 
> Call Trace:
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.539673]  
> <IRQ>  [<ffffffff813bde00>] ? skb_warn_bad_offload+0x6f/0xc1
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.539702]  
> [<ffffffff8103a109>] ? warn_slowpath_common+0x79/0xc0
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.539728]  
> [<ffffffff8103a205>] ? warn_slowpath_fmt+0x45/0x50
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.539755]  
> [<ffffffff813bde47>] ? skb_warn_bad_offload+0xb6/0xc1
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.539782]  
> [<ffffffff813110e7>] ? skb_gso_segment+0x207/0x280
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.539808]  
> [<ffffffff81313f26>] ? dev_hard_start_xmit+0x1f6/0x620
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.540933]  
> [<ffffffff81042845>] ? irq_exit+0xa5/0xb0
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.543067]  
> [<ffffffff813147a4>] ? dev_queue_xmit+0x454/0x610
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.543095]  
> [<ffffffffa06f3c42>] ? br_dev_queue_push_xmit+0x72/0xc0 [bridge]
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.543125]  
> [<ffffffffa06fa673>] ? br_nf_post_routing+0x223/0x340 [bridge]
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.543514]  
> [<ffffffffa06f3fe0>] ? __br_forward+0x90/0xb0 [bridge]
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.543585]  
> [<ffffffffa06fa2ab>] ? br_nf_pre_routing_finish+0x19b/0x340 [bridge]
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.543629]  
> [<ffffffffa06fb0f2>] ? br_nf_pre_routing+0x3a2/0x650 [bridge]
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.543657]  
> [<ffffffff8133c0c4>] ? nf_iterate+0x84/0xa0
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.543684]  
> [<ffffffffa06f4c20>] ? br_handle_local_finish+0x50/0x50 [bridge]
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.543712]  
> [<ffffffff8133c14e>] ? nf_hook_slow+0x6e/0x130
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.543739]  
> [<ffffffffa06f4c20>] ? br_handle_local_finish+0x50/0x50 [bridge]
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.543767]  
> [<ffffffff8133c14e>] ? nf_hook_slow+0x6e/0x130
> Aug  1 14:37:41 singleton.u06.univ-nantes.prive kernel: [74424.543795]  
> [<ffffffffa06f5098>] ? br_handle_frame+0x1c8/0x260 [bridge]
> 
> Despite thoses messages, the machine is still running OK. It runs lxc 
> instances (and so , bridge & tun/tap), only one of thoses instances uses 
> rbd.
> 
> I don't think the problem is ceph related.
> 
> This machine have bnx2 (Gb) & bnx2x (10Gb) - Lots of trafic is using 
> bnx2x-.
> 
> I'm running 3.5.0 on other hosts (bnx2/bnx2x or ixgbe drivers) without 
> problems. But it's not the same workload.
> 
> As the problem seems more or less gso related, I've deactivated gso two 
> days ago. This cure the symptom, running ok since.
> 
> Anyone here  seeing this problem ?
> 
> Cheers,
> 

I dont know, maybe its more a GRO issue ?

When a NIC delivers skbs with ip_summed set to CHECKSUM_UNNECESSARY,
should resulting GRO packet have ip_summed set to CHECKSUM_PARTIAL ?

CC Ben and Herbert
