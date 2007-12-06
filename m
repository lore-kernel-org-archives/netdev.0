From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-rc4-mm1
Date: Wed, 5 Dec 2007 23:35:04 -0800
Message-ID: <20071205233504.67366c5b.akpm@linux-foundation.org>
References: <20071204211701.994dfce6.akpm@linux-foundation.org>
	<47579DD9.9030909@reub.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Ilpo =?ISO-8859-1?B?SuRydmluZW4=?= <ilpo.jarvinen@helsinki.fi>
To: Reuben Farrelly <reuben-linuxkernel@reub.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54977 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753161AbXLFHfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 02:35:18 -0500
In-Reply-To: <47579DD9.9030909@reub.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 Dec 2007 17:59:37 +1100 Reuben Farrelly <reuben-linuxkernel@reub.net> wrote:

> On 5/12/2007 4:17 PM, Andrew Morton wrote:
> > Temporarily at
> > 
> >   http://userweb.kernel.org/~akpm/2.6.24-rc4-mm1/
> > 
> > Will appear later at
> > 
> >   ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc4/2.6.24-rc4-mm1/
> > 
> > 
> > - Lots of device IDs have been removed from the e1000 driver and moved over
> >   to e1000e.  So if your e1000 stops working, you forgot to set CONFIG_E1000E.
> 
> This non fatal oops which I have just noticed may be related to this change then 
> - certainly looks networking related.

yep, but it isn't e1000.  It's core TCP.

> WARNING: at net/ipv4/tcp_input.c:2518 tcp_fastretrans_alert()
> Pid: 0, comm: swapper Not tainted 2.6.24-rc4-mm1 #1
> 
> Call Trace:
>   <IRQ>  [<ffffffff8046e038>] tcp_fastretrans_alert+0x229/0xe63
>   [<ffffffff80470975>] tcp_ack+0xa3f/0x127d
>   [<ffffffff804747b7>] tcp_rcv_established+0x55f/0x7f8
>   [<ffffffff8047b1aa>] tcp_v4_do_rcv+0xdb/0x3a7
>   [<ffffffff881148a8>] :nf_conntrack:nf_ct_deliver_cached_events+0x75/0x99
>   [<ffffffff88120179>] :nf_conntrack_ipv4:ipv4_confirm+0x29/0x51
>   [<ffffffff8047db71>] tcp_v4_rcv+0x9be/0xaed
>   [<ffffffff80455eaa>] nf_hook_slow+0x60/0xdf
>   [<ffffffff8045db6b>] ip_local_deliver_finish+0xd3/0x253
>   [<ffffffff8045e146>] ip_local_deliver+0x3b/0x85
>   [<ffffffff8045d7f9>] ip_rcv_finish+0x119/0x3b8
>   [<ffffffff8045e030>] ip_rcv+0x231/0x30c
>   [<ffffffff8043ef39>] netif_receive_skb+0x215/0x299
>   [<ffffffff880b82b9>] :e1000e:e1000_receive_skb+0x4d/0x1db
>   [<ffffffff880bc200>] :e1000e:e1000_clean_rx_irq+0x12c/0x341
>   [<ffffffff880ba31a>] :e1000e:e1000_clean+0x306/0x58f
>   [<ffffffff8022a16a>] rebalance_domains+0xec/0x423
>   [<ffffffff80261332>] handle_edge_irq+0x97/0x13b
>   [<ffffffff804412d3>] net_rx_action+0xb8/0x11d
>   [<ffffffff802344f8>] __do_softirq+0x71/0xdd
>   [<ffffffff8020c8fc>] call_softirq+0x1c/0x30
>   [<ffffffff8020e7a5>] do_softirq+0x3d/0x8d
>   [<ffffffff80234485>] irq_exit+0x84/0x86
>   [<ffffffff8020e89e>] do_IRQ+0x7e/0xe4
>   [<ffffffff8020a908>] mwait_idle+0x0/0x58
>   [<ffffffff8020a7f1>] default_idle+0x0/0x43
>   [<ffffffff8020bc81>] ret_from_intr+0x0/0xa
>   <EOI>  [<ffffffff8020a950>] mwait_idle+0x48/0x58
>   [<ffffffff80209f23>] enter_idle+0x22/0x24
>   [<ffffffff8020a897>] cpu_idle+0x63/0x88
>   [<ffffffff804ada75>] rest_init+0x55/0x60
>   [<ffffffff80627b9a>] start_kernel+0x2a4/0x32a
>   [<ffffffff8062710b>] _sinittext+0x10b/0x120
> 
> tornado home #
> 
> I have posted a full dmesg up as well as my .config and an lcpci at 
> http://www.reub.net/files/kernel/2.6.24-rc4-mm1/ .
> 

Ilpo, Reuben's kernel is talking to you ;)

