From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC net] ravb: do not use zero-length alighment DMA
 request
Date: Thu, 12 Jan 2017 11:04:02 -0500 (EST)
Message-ID: <20170112.110402.1123747824643306383.davem@davemloft.net>
References: <1484229217-25585-1-git-send-email-horms+renesas@verge.net.au>
        <20170112.102102.2249793963798495642.davem@davemloft.net>
        <20170112154647.GA2329@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, magnus.damm@gmail.com,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51444 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdALQEE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 11:04:04 -0500
In-Reply-To: <20170112154647.GA2329@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Thu, 12 Jan 2017 16:46:47 +0100

> What I now see is that a few lines further up there is:
> 
> 	 if (skb_put_padto(skb, ETH_ZLEN))
> 		goto drop;
> 
> 	where ETH_ZLEN is 60.
> 
> So I don't think we need to worry about skb->len being less than 60 and
> this patch can be simplified to:
> 
> 	if (len == 0)
> 		len = 4;

I'd say this might deserve a comment...
