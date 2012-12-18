From: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Subject: Re: skb_warn_bad_offload with kernel 3.5 (maybe gso/bridge related
 ?)
Date: Tue, 18 Dec 2012 15:13:35 +0100
Message-ID: <50D07A0F.2010709@univ-nantes.fr>
References: <501B8792.6040605@univ-nantes.fr> <1343983887.9299.817.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtptls2-lmb.cpub.univ-nantes.fr ([193.52.103.111]:56000 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754909Ab2LROWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 09:22:46 -0500
In-Reply-To: <1343983887.9299.817.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/08/2012 10:51, Eric Dumazet a =C3=A9crit :
>
> As the problem seems more or less gso related, I've deactivated gso t=
wo
> days ago. This cure the symptom, running ok since.
>
> Anyone here  seeing this problem ?
>
> Cheers,
>
> I dont know, maybe its more a GRO issue ?
>
> When a NIC delivers skbs with ip_summed set to CHECKSUM_UNNECESSARY,
> should resulting GRO packet have ip_summed set to CHECKSUM_PARTIAL ?
>
> CC Ben and Herbert
>
>


Hello. I'm still seeing this issue with 3.7.0
example  :

[335685.629630] ------------[ cut here ]------------
[335685.629661] WARNING: at net/core/dev.c:1941=20
skb_warn_bad_offload+0xb6/0xc1()
[335685.629691] Hardware name: PowerEdge M610
[335685.629720] : caps=3D(0x0000000000005000, 0x0000000000000000)=20
len=3D12808 data_len=3D11308 gso_size=3D1448 gso_type=3D1 ip_summed=3D1
[335685.629769] Modules linked in: nfnetlink_log nfnetlink ip6table_raw=
=20
iptable_raw openvswitch veth ebtable_nat ebtables dlm sctp configfs nfs=
d=20
auth_rpcgss nfs_acl nfs lockd fscache sunrpc xt_physdev xt_multiport=20
ip6table_filter ip6_tables xt_LOG xt_limit xt_tcpudp xt_state=20
iptable_filter ip_tables x_tables nf_conntrack_tftp nf_conntrack_ftp=20
nf_conntrack_ipv4 nf_defrag_ipv4 8021q bridge stp llc ext2 mbcache=20
dm_round_robin nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack=20
dm_multipath scsi_dh ipv6 coretemp kvm iTCO_wdt snd_pcm ioatdma lpc_ich=
=20
snd_page_alloc i7core_edac mfd_core snd_timer edac_core crc32c_intel sn=
d=20
soundcore pcspkr dca dcdbas microcode joydev evdev processor hed button=
=20
thermal_sys xfs exportfs btrfs zlib_deflate dm_mod sg sd_mod hid_generi=
c=20
usbhid hid ata_generic uhci_hcd ata_piix libata ide_pci_generic lpfc=20
ide_core mptsas bnx2x scsi_transport_sas mptscsih mdio mptbase ehci_hcd=
=20
scsi_transport_fc scsi_tgt crc32c scsi_mod libcrc32c bnx2
[335685.630305] Pid: 0, comm: swapper/4 Tainted: G        W=20
3.7.0-dsiun-121008 #2
[335685.630348] Call Trace:
[335685.630368]  <IRQ>  [<ffffffff813d1400>] ?=20
skb_warn_bad_offload+0x74/0xc1
[335685.630403]  [<ffffffff8103e839>] ? warn_slowpath_common+0x79/0xc0
[335685.630430]  [<ffffffff8103e935>] ? warn_slowpath_fmt+0x45/0x50
[335685.630458]  [<ffffffff813d1442>] ? skb_warn_bad_offload+0xb6/0xc1
[335685.630486]  [<ffffffff81321af6>] ? skb_gso_segment+0x206/0x280
[335685.630513]  [<ffffffff81324ada>] ? dev_hard_start_xmit+0x9a/0x4a0
[335685.630542]  [<ffffffffa0087cde>] ? ipv4_confirm+0xae/0x110=20
[nf_conntrack_ipv4]
[335685.630590]  [<ffffffffa13ceeb0>] ? br_parse_ip_options+0x220/0x220=
=20
[bridge]
[335685.630620]  [<ffffffff813403dd>] ? sch_direct_xmit+0xfd/0x1d0
[335685.630647]  [<ffffffff8132529e>] ? dev_queue_xmit+0x16e/0x410
[335685.630679]  [<ffffffffa13c8c62>] ? br_dev_queue_push_xmit+0x72/0xc=
0=20
[bridge]
[335685.630723]  [<ffffffffa13cfb33>] ? br_nf_post_routing+0x223/0x340=20
[bridge]
[335685.630754]  [<ffffffffa13c8bf0>] ? deliver_clone+0x60/0x60 [bridge=
]
[335685.630785]  [<ffffffff8134d50d>] ? nf_iterate+0x8d/0xc0
[335685.630813]  [<ffffffffa13cef30>] ? br_nf_dev_queue_xmit+0x80/0x80=20
[bridge]
[335685.630843]  [<ffffffffa13c8bf0>] ? deliver_clone+0x60/0x60 [bridge=
]
[335685.630871]  [<ffffffff8134d5ae>] ? nf_hook_slow+0x6e/0x130
[335685.630898]  [<ffffffffa13c8bf0>] ? deliver_clone+0x60/0x60 [bridge=
]
[335685.630927]  [<ffffffffa13c8f20>] ? br_multicast_flood+0x170/0x170=20
[bridge]
[335685.630958]  [<ffffffffa13c8f62>] ? br_forward_finish+0x42/0x50 [br=
idge]
[335685.630988]  [<ffffffffa13cefe9>] ? br_nf_forward_finish+0xb9/0x180=
=20
[bridge]
[335685.631018]  [<ffffffffa13cf7d3>] ? br_nf_forward_ip+0x293/0x3d0=20
[bridge]
[335685.631051]  [<ffffffffa13c8f20>] ? br_multicast_flood+0x170/0x170=20
[bridge]
[335685.631081]  [<ffffffff8134d50d>] ? nf_iterate+0x8d/0xc0
[335685.631111]  [<ffffffffa13c8f20>] ? br_multicast_flood+0x170/0x170=20
[bridge]
[335685.631140]  [<ffffffff8134d5ae>] ? nf_hook_slow+0x6e/0x130
[335685.631168]  [<ffffffffa13c8f20>] ? br_multicast_flood+0x170/0x170=20
[bridge]
[335685.631198]  [<ffffffffa13c9000>] ? __br_forward+0x90/0xb0 [bridge]
[335685.631227]  [<ffffffffa13c9e44>] ?=20
br_handle_frame_finish+0x214/0x2b0 [bridge]
[335685.631272]  [<ffffffffa13cf31f>] ?=20
br_nf_pre_routing_finish+0x14f/0x370 [bridge]
[335685.631317]  [<ffffffffa13d01e2>] ? br_nf_pre_routing+0x3a2/0x650=20
[bridge]
[335685.631348]  [<ffffffffa13c9c30>] ? br_handle_local_finish+0x50/0x5=
0=20
[bridge]
[335685.631391]  [<ffffffff8134d50d>] ? nf_iterate+0x8d/0xc0
[335685.631419]  [<ffffffffa13c9c30>] ? br_handle_local_finish+0x50/0x5=
0=20
[bridge]
[335685.631462]  [<ffffffff8134d5ae>] ? nf_hook_slow+0x6e/0x130
[335685.631514]  [<ffffffffa13c9c30>] ? br_handle_local_finish+0x50/0x5=
0=20
[bridge]
[335685.631562]  [<ffffffffa13ca0c0>] ? br_handle_frame+0x1e0/0x280 [br=
idge]
[335685.631591]  [<ffffffff81323135>] ? __netif_receive_skb+0x215/0x860
[335685.631619]  [<ffffffff81125417>] ? alloc_pages_current+0xb7/0x130
[335685.631648]  [<ffffffff8100a3f5>] ? read_tsc+0x5/0x20
[335685.631677]  [<ffffffff8132390a>] ? netif_receive_skb+0x1a/0x80
[335685.631704]  [<ffffffff81323a60>] ? napi_skb_finish+0x50/0x70
[335685.631735]  [<ffffffffa02456e6>] ? bnx2x_rx_int+0x6a6/0x1500 [bnx2=
x]
[335685.631765]  [<ffffffffa13c9c30>] ? br_handle_local_finish+0x50/0x5=
0=20
[bridge]
[335685.631810]  [<ffffffffa13ca0c0>] ? br_handle_frame+0x1e0/0x280 [br=
idge]
[335685.632982]  [<ffffffffa02465d3>] ? bnx2x_poll+0x93/0x2b0 [bnx2x]
[335685.633010]  [<ffffffff81323135>] ? __netif_receive_skb+0x215/0x860
[335685.633038]  [<ffffffff813242e8>] ? net_rx_action+0x138/0x240
[335685.633065]  [<ffffffff810469ae>] ? __do_softirq+0xbe/0x1f0
[335685.633092]  [<ffffffff813d5cdc>] ? call_softirq+0x1c/0x30
[335685.633118]  [<ffffffff81004cb5>] ? do_softirq+0x75/0xb0
[335685.633144]  [<ffffffff81046c45>] ? irq_exit+0xa5/0xb0
[335685.633170]  [<ffffffff8100492b>] ? do_IRQ+0x5b/0xd0
[335685.633196]  [<ffffffff813d416d>] ? common_interrupt+0x6d/0x6d
[335685.633222]  <EOI>  [<ffffffff8125204c>] ? intel_idle+0xec/0x160
[335685.633257]  [<ffffffff8125202a>] ? intel_idle+0xca/0x160
[335685.633286]  [<ffffffff812f71bd>] ? cpuidle_idle_call+0x9d/0x240
[335685.633315]  [<ffffffff8100c335>] ? cpu_idle+0x65/0xd0
[335685.633340] ---[ end trace 2142bc9cd23c0d87 ]---


Only seeing this with bridge activated, and with bnx2x
ethtool -K eth2 gso cure the problem.

Cheers,

--=20
Yann Dupont - Service IRTS, DSI Universit=C3=A9 de Nantes
Tel : 02.53.48.49.20 - Mail/Jabber : Yann.Dupont@univ-nantes.fr
