From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Fri, 31 Aug 2012 19:21:04 -0700 (PDT)
Message-ID: <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Madore <david+ml@madore.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120829002548.GA7063@aldebaran.gro-tsen.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ Cc'ing original mail to netdev as the problem may be recognized there ]

On Wed, 29 Aug 2012, David Madore wrote:
> Dear all,
> 
> I hope this is the right place to send this sort of backtrace dump.
> 
> I'm getting the following sort of dumps (below) on a 3.2.27 kernel on
> an arm/kirkwood (actually DreamPlug) machine that's used as a router.
> 
> I imagine it being somehow related to the fact that it operates a
> network bridge (I imagine this because I have another identical
> machine with exactly the same kernel and a very similar config but not
> running a bridge, and the warning never pops up).
> 
> Is this worth investigating?  (I will, of course, provide the config
> file and any other relevant data if the answer is "yes".)  Is this
> potentially serious?  (I'm getting hard lockups on this machine which
> I suspect are due to hardware and unrelated to this, but if someone
> tells me it could be the cause, I'd be more than happy to believe it.)
> 
> [24711.204492] ------------[ cut here ]------------
> [24711.209151] WARNING: at mm/page_alloc.c:2109 __alloc_pages_nodemask+0x1d4/0x68c()
> [24711.216667] Modules linked in: 8021q ath9k_htc mac80211 ath9k_common ath9k_hw ath cfg80211 bnep rfcomm sit tunnel4 sch_ingress cls_fw cls_u32 sch_sfq sch_htb pppoe pppox ppp_generic slhc bridge stp llc ip6t_REJECT ip6table_filter ip6table_mangle xt_NOTRACK ip6table_raw ip6_tables nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ftp nf_conntrack_ftp ipt_REJECT xt_conntrack iptable_filter ipt_MASQUERADE iptable_nat nf_nat xt_TCPMSS xt_tcpudp xt_mark iptable_mangle ip_tables x_tables nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 orion_wdt ipv6 snd_usb_audio snd_pcm snd_page_alloc snd_hwdep snd_usbmidi_lib snd_seq_midi snd_seq_midi_event snd_rawmidi btmrvl_sdio btmrvl snd_seq snd_timer snd_seq_device snd bluetooth soundcore
> [24711.280663] [<c000d728>] (unwind_backtrace+0x0/0xf0) from [<c0022f74>] (warn_slowpath_common+0x50/0x68)
> [24711.290124] [<c0022f74>] (warn_slowpath_common+0x50/0x68) from [<c0022fa8>] (warn_slowpath_null+0x1c/0x24)
> [24711.299845] [<c0022fa8>] (warn_slowpath_null+0x1c/0x24) from [<c009caec>] (__alloc_pages_nodemask+0x1d4/0x68c)
> [24711.309914] [<c009caec>] (__alloc_pages_nodemask+0x1d4/0x68c) from [<c009cfb4>] (__get_free_pages+0x10/0x3c)
> [24711.319805] [<c009cfb4>] (__get_free_pages+0x10/0x3c) from [<c00c9fd0>] (kmalloc_order_trace+0x24/0xdc)
> [24711.329269] [<c00c9fd0>] (kmalloc_order_trace+0x24/0xdc) from [<c038d638>] (pskb_expand_head+0x68/0x298)
> [24711.338901] [<c038d638>] (pskb_expand_head+0x68/0x298) from [<bf0dd3ec>] (ip6_forward+0x4d4/0x7bc [ipv6])
> [24711.348638] [<bf0dd3ec>] (ip6_forward+0x4d4/0x7bc [ipv6]) from [<bf0dfebc>] (ipv6_rcv+0x2bc/0x3dc [ipv6])
> [24711.358333] [<bf0dfebc>] (ipv6_rcv+0x2bc/0x3dc [ipv6]) from [<c0394870>] (__netif_receive_skb+0x544/0x66c)
> [24711.368106] [<c0394870>] (__netif_receive_skb+0x544/0x66c) from [<bf1cd054>] (br_nf_pre_routing_finish_ipv6+0x10c/0x160 [bridge])
> [24711.379899] [<bf1cd054>] (br_nf_pre_routing_finish_ipv6+0x10c/0x160 [bridge]) from [<bf1cdae8>] (br_nf_pre_routing+0x59c/0x67c [bridge])
> [24711.392271] [<bf1cdae8>] (br_nf_pre_routing+0x59c/0x67c [bridge]) from [<c03bd2a4>] (nf_iterate+0x8c/0xb4)
> [24711.401988] [<c03bd2a4>] (nf_iterate+0x8c/0xb4) from [<c03bd328>] (nf_hook_slow+0x5c/0x118)
> [24711.410540] [<c03bd328>] (nf_hook_slow+0x5c/0x118) from [<bf1c7fa4>] (br_handle_frame+0x1b8/0x290 [bridge])
> [24711.420367] [<bf1c7fa4>] (br_handle_frame+0x1b8/0x290 [bridge]) from [<c03946f8>] (__netif_receive_skb+0x3cc/0x66c)
> [24711.430872] [<c03946f8>] (__netif_receive_skb+0x3cc/0x66c) from [<c031e254>] (mv643xx_eth_poll+0x540/0x734)
> [24711.440680] [<c031e254>] (mv643xx_eth_poll+0x540/0x734) from [<c0397390>] (net_rx_action+0x118/0x314)
> [24711.449970] [<c0397390>] (net_rx_action+0x118/0x314) from [<c0029924>] (__do_softirq+0xac/0x234)
> [24711.458817] [<c0029924>] (__do_softirq+0xac/0x234) from [<c0029f00>] (irq_exit+0x94/0x9c)
> [24711.467046] [<c0029f00>] (irq_exit+0x94/0x9c) from [<c00094b0>] (handle_IRQ+0x34/0x84)
> [24711.475007] [<c00094b0>] (handle_IRQ+0x34/0x84) from [<c04398d4>] (__irq_svc+0x34/0x98)
> [24711.483068] [<c04398d4>] (__irq_svc+0x34/0x98) from [<c0011d6c>] (kirkwood_enter_idle+0x4c/0x94)
> [24711.491908] [<c0011d6c>] (kirkwood_enter_idle+0x4c/0x94) from [<c0357a00>] (cpuidle_idle_call+0xc8/0x35c)
> [24711.501532] [<c0357a00>] (cpuidle_idle_call+0xc8/0x35c) from [<c0009764>] (cpu_idle+0x88/0xdc)
> [24711.510201] [<c0009764>] (cpu_idle+0x88/0xdc) from [<c05d8720>] (start_kernel+0x2a0/0x2f0)
> [24711.518512] ---[ end trace e1776fbe32468909 ]---

Francois is right that a GFP_ATOMIC allocation from pskb_expand_head()
is failing, which can easily happen, and cause your "failed to reallocate
TX buffer" errors; but it's well worth looking up what's actually on
lines 2108 and 2109 of mm/page_alloc.c in 3.2.27:

	if (order >= MAX_ORDER) {
		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));

That was probably not a sane allocation request, it has gone out of range:
maybe the skb header is even corrupted.  If you're lucky, it might be
something that netdev will recognize as already fixed.

Hugh
