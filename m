From: Divy Le Ray <divy@chelsio.com>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Thu, 22 Jan 2009 01:42:22 -0800
Message-ID: <49783F7E.6000202@chelsio.com>
References: <20090120101418.13898.57172.stgit@speedy5> <20090121082937.GA1116@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:7016 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754636AbZAVJnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 04:43:39 -0500
In-Reply-To: <20090121082937.GA1116@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:


> there is a lot
> of microoptimisations that we can perform to minimise the cost
> and also reduce the cost of some existing checks.
> 
> Please try the following patch (compile tested only since I'm
> at LCA) and let me know if it improves things.
> 

I'm now getting about an average 5.7Gbs, oprofile typically showing:

      37.294500  copy_user_generic_unrolled          vmlinux
       8.733800  process_responses                  cxgb3.ko
       6.123700  refill_fl                          cxgb3.ko
       5.006900  put_page                            vmlinux
       3.400700  napi_fraginfo_skb                   vmlinux
       2.484600  tcp_gro_receive                     vmlinux
       2.308900  inet_gro_receive                    vmlinux
       2.196000  free_hot_cold_page                  vmlinux
       2.032900  skb_gro_header                      vmlinux
       1.970100  get_page_from_freelist              vmlinux
       1.869700  skb_copy_datagram_iovec             vmlinux
       1.380300  dev_gro_receive                     vmlinux
       1.242300  tcp_recvmsg                         vmlinux
       1.079200  irq_entries_start                   vmlinux
       1.003900  get_pageblock_flags_group           vmlinux
       0.991300  skb_gro_receive                     vmlinux
       0.878400  _raw_spin_lock                      vmlinux
       0.878400  memcpy                              vmlinux
       0.840800  kfree                               vmlinux
       0.828200  list_del                            vmlinux

Cheers,
Divy
