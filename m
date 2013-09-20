From: Michele Baldessari <michele@acksyn.org>
Subject: Re: IPv6 kernel warning
Date: Fri, 20 Sep 2013 17:08:30 +0100
Message-ID: <20130920160830.GA4241@marquez.int.rhx>
References: <20130920131153.GF12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ycheng@google.com
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palahniuk.acksyn.org ([5.9.7.26]:51340 "EHLO
	palahniuk.acksyn.org" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752549Ab3ITQIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 12:08:34 -0400
Content-Disposition: inline
In-Reply-To: <20130920131153.GF12758@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Russell,

On Fri, Sep 20, 2013 at 02:11:53PM +0100, Russell King - ARM Linux wrote:
> While running v3.11 on my firewall, I saw this warning.  I'm not sure
> what it means or what its implications are:
> 
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 0 at /home/rmk/git/linux-rmk/net/ipv4/tcp_input.c:2711 tcp_fastretrans_alert+0x178/0x840()
> Modules linked in: ipt_REJECT xt_multiport iptable_filter ipt_MASQUERADE xt_nat
> xt_mark iptable_nat nf_nat_ipv4 nf_nat ip6table_mangle xt_LOG xt_limit nf_conntrack_ipv6 nf_defrag_ipv6 xt_state ip6table_filter pata_pcmcia libata scsi_mod 3c589_cs ide_gd_mod ide_cs ide_core sa1111_cs sa1100_cs sa11xx_base soc_common sa11x0_dma virt_dma usbcore usb_common
> CPU: 0 PID: 0 Comm: swapper Not tainted 3.11.0+ #15
> Backtrace:
> [<c02111a8>] (dump_backtrace+0x0/0x114) from [<c02115a0>] (show_stack+0x18/0x1c) r6:c0520824 r5:00000009 r4:00000000
> [<c0211588>] (show_stack+0x0/0x1c) from [<c04d65e0>] (dump_stack+0x20/0x28)
> [<c04d65c0>] (dump_stack+0x0/0x28) from [<c021bfb0>] (warn_slowpath_common+0x68/0x88)
> [<c021bf48>] (warn_slowpath_common+0x0/0x88) from [<c021bff4>] (warn_slowpath_null+0x24/0x28)
>  r8:00000000 r7:00000001 r6:00000006 r5:00004320 r4:c11c6580
> [<c021bfd0>] (warn_slowpath_null+0x0/0x28) from [<c04515bc>] (tcp_fastretrans_alert+0x178/0x840)
> [<c0451444>] (tcp_fastretrans_alert+0x0/0x840) from [<c045273c>] (tcp_ack+0xa14/0xc18)
> [<c0451d28>] (tcp_ack+0x0/0xc18) from [<c0453138>] (tcp_rcv_established+0x494/0x594)
> [<c0452ca4>] (tcp_rcv_established+0x0/0x594) from [<c04a977c>] (tcp_v6_do_rcv+0xd0/0x428)
> [<c04a96ac>] (tcp_v6_do_rcv+0x0/0x428) from [<c04a9e70>] (tcp_v6_rcv+0x340/0x63c)
> [<c04a9b30>] (tcp_v6_rcv+0x0/0x63c) from [<c048b334>] (ip6_input_finish+0x214/0x3c4)
> [<c048b120>] (ip6_input_finish+0x0/0x3c4) from [<c048ba60>] (ip6_input+0x64/0x74)
> [<c048b9fc>] (ip6_input+0x0/0x74) from [<c048b564>] (ip6_rcv_finish+0x80/0x8c)
>  r4:c1c9ee20
> [<c048b4e4>] (ip6_rcv_finish+0x0/0x8c) from [<c048b994>] (ipv6_rcv+0x424/0x48c)
>  r4:c1c9ee20
> [<c048b570>] (ipv6_rcv+0x0/0x48c) from [<c0407624>] (__netif_receive_skb_core+0x618/0x688)
>  r8:0000dd86 r7:00000000 r6:c11f6800 r5:c05ee6cc r4:c05f1b98
> [<c040700c>] (__netif_receive_skb_core+0x0/0x688) from [<c040770c>] (__netif_receive_skb+0x78/0x80)
> [<c0407694>] (__netif_receive_skb+0x0/0x80) from [<c04077a8>] (process_backlog+0x94/0x14c)
>  r5:c06091e0 r4:c0609220
> [<c0407714>] (process_backlog+0x0/0x14c) from [<c0407af4>] (net_rx_action+0x78/0x1ac)
> [<c0407a7c>] (net_rx_action+0x0/0x1ac) from [<c021f500>] (__do_softirq+0xb4/0x198)
> [<c021f44c>] (__do_softirq+0x0/0x198) from [<c021f90c>] (irq_exit+0x74/0xc8)
> [<c021f898>] (irq_exit+0x0/0xc8) from [<c020f1ac>] (handle_IRQ+0x68/0x88)
>  r4:0000000b
> [<c020f144>] (handle_IRQ+0x0/0x88) from [<c0208210>] (asm_do_IRQ+0x10/0x14)
>  r5:60000013 r4:c0246818
> [<c0208200>] (asm_do_IRQ+0x0/0x14) from [<c0211fcc>] (__irq_svc+0x2c/0x98)
> Exception stack(0xc05e7f54 to 0xc05e7f9c)
> 7f40:                                              00000000 00000000 00000000
> 7f60: 60000013 c05e6000 c06092a4 c05ee080 00000001 c0204000 6901b115 c05e0800
> 7f80: c05e7fb8 c05e7f9c c05e7f9c c020f348 c0246818 60000013 ffffffff
> [<c0246794>] (cpu_startup_entry+0x0/0xe8) from [<c04d4d70>] (rest_init+0x64/0x7c)
>  r7:c05f3940 r6:c0922200 r5:c0609340 r4:c05ee0c0
> [<c04d4d0c>] (rest_init+0x0/0x7c) from [<c05c3acc>] (start_kernel+0x350/0x3ac)
> [<c05c377c>] (start_kernel+0x0/0x3ac) from [<c0208040>] (0xc0208040)
> ---[ end trace ab55f0e3f592fa5e ]---

there's been multiple reports about this one:
https://bugzilla.redhat.com/show_bug.cgi?id=989251
http://bugzilla.kernel.org/show_bug.cgi?id=60779

Could you try Yuchung's debug patch?
http://www.spinics.net/lists/netdev/msg250193.html

thanks,
Michele
-- 
Michele Baldessari            <michele@acksyn.org>
C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
