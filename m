From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: add napi_id read access to __sk_buff
Date: Fri, 21 Apr 2017 13:53:39 -0400 (EDT)
Message-ID: <20170421.135339.120415455520577597.davem@davemloft.net>
References: <9f477418c0db1091bfb119ef8c159f18384d6100.1492635441.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35926 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423234AbdDUSCv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:02:51 -0400
In-Reply-To: <9f477418c0db1091bfb119ef8c159f18384d6100.1492635441.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 19 Apr 2017 23:01:17 +0200

> Add napi_id access to __sk_buff for socket filter program types, tc
> program types and other bpf_convert_ctx_access() users. Having access
> to skb->napi_id is useful for per RX queue listener siloing, f.e.
> in combination with SO_ATTACH_REUSEPORT_EBPF and when busy polling is
> used, meaning SO_REUSEPORT enabled listeners can then select the
> corresponding socket at SYN time already [1]. The skb is marked via
> skb_mark_napi_id() early in the receive path (e.g., napi_gro_receive()).
> 
> Currently, sockets can only use SO_INCOMING_NAPI_ID from 6d4339028b35
> ("net: Introduce SO_INCOMING_NAPI_ID") as a socket option to look up
> the NAPI ID associated with the queue for steering, which requires a
> prior sk_mark_napi_id() after the socket was looked up.
> 
> Semantics for the __sk_buff napi_id access are similar, meaning if
> skb->napi_id is < MIN_NAPI_ID (e.g. outgoing packets using sender_cpu),
> then an invalid napi_id of 0 is returned to the program, otherwise a
> valid non-zero napi_id.
> 
>   [1] http://netdevconf.org/2.1/slides/apr6/dumazet-BUSY-POLLING-Netdev-2.1.pdf
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks Daniel.
