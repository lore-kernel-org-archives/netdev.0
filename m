From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] be2net: memory barrier fixes on IBM p7
 platform
Date: Wed, 30 Jun 2010 13:27:49 -0700 (PDT)
Message-ID: <20100630.132749.218066997.davem@davemloft.net>
References: <20100629101117.GA2338@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44767
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754842Ab0F3U1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 16:27:35 -0400
In-Reply-To: <20100629101117.GA2338@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Tue, 29 Jun 2010 15:41:17 +0530

> The ibm p7 architecure seems to reorder memory accesses more
> aggressively than previous ppc64 architectures. This requires memory
> barriers to ensure that rx/tx doorbells are pressed only after
> memory to be DMAed is written.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied, but I had to fix something:

> @@ -972,7 +976,8 @@ static struct be_eth_rx_compl *be_rx_compl_get(struct be_adapter *adapter)
>  
>  	if (rxcp->dw[offsetof(struct amap_eth_rx_compl, valid) / 32] == 0)
>  		return NULL;
> -
> +	
> +	rmb();

That first addition does nothing but add erroneous trailing
whitespace.

You can physically see that something must be wrong here just by look
at this patch chunk, please review things more thoroughly before
submitting in the future.

Thanks.
