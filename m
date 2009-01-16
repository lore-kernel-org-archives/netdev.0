From: Divy Le Ray <divy@chelsio.com>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Fri, 16 Jan 2009 03:12:07 -0800
Message-ID: <49706B87.7080806@chelsio.com>
References: <20090115235803.GA9000@gondor.apana.org.au> <49704015.6020503@chelsio.com> <20090116085645.GA14678@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:22087 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760967AbZAPLNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 06:13:22 -0500
In-Reply-To: <20090116085645.GA14678@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I presume the server is receiving?
Yes, it is receiving. The adapter is set up with one queue, its irq
pinned to cpu1, irq balance disabled. CPU1 is pegged in all tests.
> 
>> without the patch, lro off: 3.8Gbs
>> without the patch, lro on: 6.1Gbs
>> with the patch, GRO on: 4.8Gbs.
> 
> What about the case of GRO off with the patch? Just checking to
> make sure that nothing else has changed.

I'm getting about 3.4Gbs with the patch and GRO off.

I did some profiling with GRO on and LRO on. Here are typical outputs:
GRO on:
CPU 1 :
      26.445100  copy_user_generic_unrolled          vmlinux
      10.050300  skb_copy_datagram_iovec             vmlinux
       5.076900  memcpy                              vmlinux
       4.636400  process_responses                  cxgb3.ko
       4.625100  __pskb_pull_tail                    vmlinux
       4.463300  eth_type_trans                      vmlinux
       4.420600  inet_gro_receive                    vmlinux
       4.310500  refill_fl                          cxgb3.ko
       3.312700  skb_copy_bits                       vmlinux
       3.155300  put_page                            vmlinux
       2.818200  kfree                               vmlinux
       2.537300  tcp_gro_receive                     vmlinux
       2.422700  dev_gro_receive                     vmlinux
       2.229400  kmem_cache_alloc_node               vmlinux
       1.526000  skb_gro_receive                     vmlinux
       1.319200  free_hot_cold_page                  vmlinux
       1.224800  get_page_from_freelist              vmlinux
       1.112500  __alloc_skb                         vmlinux
       0.910200  kmem_cache_free                     vmlinux
       0.872000  napi_fraginfo_skb                   vmlinux

LRO on:
CPU 1 :
      48.511600  copy_user_generic_unrolled          vmlinux
       5.859600  put_page                            vmlinux
       4.405500  process_responses                  cxgb3.ko
       4.006400  refill_fl                          cxgb3.ko
       2.547200  irq_entries_start                   vmlinux
       2.315900  free_hot_cold_page                  vmlinux
       2.224400  skb_copy_datagram_iovec             vmlinux
       1.985400  tcp_recvmsg                         vmlinux
       1.311700  csum_partial                        vmlinux
       1.276200  _raw_spin_lock                      vmlinux
       1.088000  get_page_from_freelist              vmlinux
       1.016900  get_pageblock_flags_group           vmlinux
       0.920300  memcpy_toiovec                      vmlinux
       0.859200  kfree                               vmlinux
       0.688900  dst_release                         vmlinux
       0.630400  t3_sge_intr_msix_napi              cxgb3.ko
       0.559300  tcp_rcv_established                 vmlinux
       0.472800  kmem_cache_alloc_node               vmlinux
       0.404200  __inet_lookup_established           vmlinux
       0.399100  memset                              vmlinux

I have not looked at the code yet. It's getting late :)

Cheers,
Divy
