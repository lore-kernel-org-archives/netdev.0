From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH net-next 1/2] pcnet32: fix reallocation error
Date: Tue, 18 Feb 2014 21:29:00 +0900
Message-ID: <201402182129.BDD57369.FVOQHFOFtJSLOM@I-love.SAKURA.ne.jp>
References: <1392699466.4020.27.camel@Linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: pcnet32@frontier.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:65042 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167AbaBRM3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 07:29:08 -0500
In-Reply-To: <1392699466.4020.27.camel@Linux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don Fry wrote:
> pcnet32_realloc_rx_ring() only worked on the first log2 number of
> entries in the receive ring instead of the all the entries.
> Replaced "1 << size" with more descriptive variable.

>  	/* first copy the current receive buffers */
> -	overlap = min(size, lp->rx_ring_size);
> +	overlap = min(entries, lp->rx_ring_size);

>  	/* now allocate any new buffers needed */
> -	for (; new < size; new++) {
> +	for (; new < entries; new++) {

Until this fix, lp->rx_skbuff[size...(1<<size)-1] were not allocated by
netdev_alloc_skb() and lp->rx_ring_dma_addr[size...(1<<size)-1] were not mapped
by pci_map_single(), right?

Since lp->rx_ring_size was set to (1<<size), wasn't there possibility that
something bad happens by accessing lp->rx_skbuff[] and lp->rx_ring_dma_addr[]
up to (1<<size)-1 ? (In other words, don't we want to backport this fix?)
