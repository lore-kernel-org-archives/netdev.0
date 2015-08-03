From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ebpf: add skb->hash to offset map for usage
 in {cls,act}_bpf or filters
Date: Sun, 02 Aug 2015 17:21:15 -0700 (PDT)
Message-ID: <20150802.172115.1166803002987723606.davem@davemloft.net>
References: <4b25d0b28e9c366a8a307d855d1690038956e6bd.1438382433.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbbHCAVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2015 20:21:16 -0400
In-Reply-To: <4b25d0b28e9c366a8a307d855d1690038956e6bd.1438382433.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat,  1 Aug 2015 00:46:29 +0200

> Add skb->hash to the __sk_buff offset map, so it can be accessed from
> an eBPF program. We currently already do this for classic BPF filters,
> but not yet on eBPF, it might be useful as a demuxer in combination with
> helpers like bpf_clone_redirect(), toy example:
> 
>   __section("cls-lb") int ingress_main(struct __sk_buff *skb)
>   {
>     unsigned int which = 3 + (skb->hash & 7);
>     /* bpf_skb_store_bytes(skb, ...); */
>     /* bpf_l{3,4}_csum_replace(skb, ...); */
>     bpf_clone_redirect(skb, which, 0);
>     return -1;
>   }
> 
> I was thinking whether to add skb_get_hash(), but then concluded the
> raw skb->hash seems fine in this case: we can directly access the hash
> w/o extra eBPF helper function call, it's filled out by many NICs on
> ingress, and in case the entropy level would not be sufficient, people
> can still implement their own specific sw fallback hash mix anyway.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks Daniel.
