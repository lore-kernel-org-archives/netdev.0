From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/3] mlx4_en: moderate frequency of TX
 completions
Date: Thu, 23 Feb 2012 21:13:56 +0000
Message-ID: <1330031636.2511.13.camel@bwh-desktop>
References: <4F464063.1010001@mellanox.co.il>
	 <20120223.144437.32389814881687535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <yevgenyp@mellanox.co.il>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:43312 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753424Ab2BWVOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 16:14:00 -0500
In-Reply-To: <20120223.144437.32389814881687535.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-23 at 14:44 -0500, David Miller wrote:
> From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> Date: Thu, 23 Feb 2012 15:34:27 +0200
> 
> > No need to ask for completion for every packet being sent.
> > So the method is to ask for a completion every 16 packets,
> > or when the queue is about to be full.
> > 
> > Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> 
> You absolutely cannot do this, you must signal completion and free up
> TX queue packets in a finite amount of time.

Really, sfc has been doing this forever.

Ben.

> This means that if you suddenly stop getting new packets to send
> you must still free up all the pending TX SKBs even if no more
> packets are given to the driver.
> 
> Does your hardware unconditionally give a TX completion interrupt when
> the TX queue empties completely?  If not, then you cannot make the
> change contained in this patch.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
