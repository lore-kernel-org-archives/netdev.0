From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: sched: consolidate
 tc_classify{,_compat}
Date: Thu, 27 Aug 2015 16:11:45 -0700 (PDT)
Message-ID: <20150827.161145.2273321237879729255.davem@davemloft.net>
References: <0883dbc14bab78eb14cbed171c59143f24769edf.1440661724.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbbH0XLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 19:11:46 -0400
In-Reply-To: <0883dbc14bab78eb14cbed171c59143f24769edf.1440661724.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 27 Aug 2015 10:11:37 +0200

> For classifiers getting invoked via tc_classify(), we always need an
> extra function call into tc_classify_compat(), as both are being
> exported as symbols and tc_classify() itself doesn't do much except
> handling of reclassifications when tp->classify() returned with
> TC_ACT_RECLASSIFY.
> 
> CBQ and ATM are the only qdiscs that directly call into tc_classify_compat(),
> all others use tc_classify(). When tc actions are being configured
> out in the kernel, tc_classify() effectively does nothing besides
> delegating.
> 
> We could spare this layer and consolidate both functions. Artificial
> pktgen micro benchmark on single CPU constantly pushing skbs directly
> into the netif_receive_skb() path with a dummy classifier on ingress
> qdisc attached, improves slightly from 22.3Mpps to 23.1Mpps.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  v1 -> v2:
>   - Addressed minor style nits found by Alexei.

Sorry, I applied v1 before seeing this :-/

If you could post a relative patch fixing the style issues, I'd
appreciate it.

Thanks.
