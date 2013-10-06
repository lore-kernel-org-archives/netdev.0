From: Jamie Heilman <jamie@audible.transient.net>
Subject: Re: Bug - regression - Via velocity interface coming up freezes
 kernel
Date: Sun, 6 Oct 2013 08:19:30 +0000
Message-ID: <20131006081930.GA4139@cucamonga.audible.transient.net>
References: <CAFES+i+9Wk6GMo8jMPH4uAz0AFi16RCWaRjG2YOyjRiBnx7OVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from audible.transient.net ([24.143.126.66]:41270 "HELO
	audible.transient.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752212Ab3JFI0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Oct 2013 04:26:13 -0400
Content-Disposition: inline
In-Reply-To: <CAFES+i+9Wk6GMo8jMPH4uAz0AFi16RCWaRjG2YOyjRiBnx7OVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FWIW, I encountered this same issue on my EPIA-SN with its onboard
VT6130, I bisected back to the same commit, and Francois's patch
against 3.11.4 also eliminated the warning for me.  Hopefully a fix
is queued up for stable soon.


For the record the full trace was:

WARNING: CPU: 0 PID: 0 at kernel/softirq.c:159 _local_bh_enable_ip.isra.14+0x32/0x6e()
Modules linked in: quota_v2 quota_tree nfsd auth_rpcgss oid_registry exportfs nfs lockd fscache sunrpc xt_mark cls_fw sch_htb xt_nat iptable_nat nf_nat_ipv4 nf_nat ipt_REJECT xt_tcpudp xt_multiport iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack xt_LOG xt_limit iptable_filter ip_tables x_tables dm_crypt dm_mod snd_hda_codec_via snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_page_alloc snd_timer snd soundcore psmouse via_rhine mii via_velocity evdev via_agp ioapic agpgart
CPU: 0 PID: 0 Comm: swapper Not tainted 3.11.4 #1
Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled by O.E.M., BIOS 080014  06/01/2009
 00000000 00000000 c1355d04 c125c0f9 c1355d34 c1024360 c12ecca6 00000000
 00000000 c12ece5c 0000009f c1026769 c1026769 f5041cc0 c138cb2c f5ae3000
 c1355d44 c10243f3 00000009 00000000 c1355d4c c1026769 c1355d54 c10267ad
Call Trace:
 [<c125c0f9>] dump_stack+0x16/0x18
 [<c1024360>] warn_slowpath_common+0x70/0x87
 [<c1026769>] ? _local_bh_enable_ip.isra.14+0x32/0x6e
 [<c1026769>] ? _local_bh_enable_ip.isra.14+0x32/0x6e
 [<c10243f3>] warn_slowpath_null+0x1d/0x1f
 [<c1026769>] _local_bh_enable_ip.isra.14+0x32/0x6e
 [<c10267ad>] local_bh_enable+0x8/0xa
 [<c120e15f>] neigh_lookup+0x95/0x9e
 [<c124239a>] __neigh_lookup.constprop.16+0x1b/0x4e
 [<c1242b3f>] arp_process+0x3ac/0x461
 [<c1216860>] ? sch_direct_xmit+0x37/0xd9
 [<c10267ad>] ? local_bh_enable+0x8/0xa
 [<c1208ccd>] ? dev_queue_xmit+0x2aa/0x2b7
 [<c1242cc2>] arp_rcv+0xc4/0x107
 [<c1242714>] ? arp_xmit+0x18/0x4f
 [<c1206c67>] __netif_receive_skb_core+0x366/0x39f
 [<c1004f09>] ? text_poke_smp_batch+0x2a/0x2a
 [<c1206cb1>] __netif_receive_skb+0x11/0x4d
 [<c1004f09>] ? text_poke_smp_batch+0x2a/0x2a
 [<c1207747>] netif_receive_skb+0x30/0x33
 [<f84465aa>] velocity_rx_srv+0x229/0x304 [via_velocity]
 [<f84466b6>] velocity_poll+0x31/0x7a [via_velocity]
 [<c12078bb>] net_rx_action+0x69/0xe9
 [<c1026a0b>] __do_softirq+0x87/0x12d
 [<c1026b57>] irq_exit+0x36/0x6d
 [<c1002c4e>] do_IRQ+0x74/0x87
 [<c125ef73>] common_interrupt+0x33/0x38
 [<c1006739>] ? default_idle+0x5/0x7
 [<c1006a9d>] arch_cpu_idle+0x12/0x17
 [<c1040a04>] cpu_startup_entry+0xbe/0x109
 [<c1257758>] rest_init+0x57/0x59
 [<c1394920>] start_kernel+0x2be/0x2c4
 [<c1394494>] ? repair_env_string+0x51/0x51
 [<c13942c3>] i386_start_kernel+0x79/0x7d
---[ end trace 96eca78d04cc6ac3 ]---

-- 
Jamie Heilman                     http://audible.transient.net/~jamie/
