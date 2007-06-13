From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 12/15] spidernet: increase the NAPI weight
Date: Wed, 13 Jun 2007 16:14:36 -0400
Message-ID: <4670502C.5000506@garzik.org>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com> <20070611190236.GL13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39302 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754368AbXFMUOj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 16:14:39 -0400
In-Reply-To: <20070611190236.GL13741@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> Another way of minimizing the likelyhood of RX ram from overflowing
> is to empty out the entire rx ring every chance we get. Change
> the crazy watchdog timeout from 50 seconds to 3 seconds, while
> we're here.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> 
> ----
>  drivers/net/spider_net.h |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.22-rc1/drivers/net/spider_net.h
> ===================================================================
> --- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-06-11 11:50:03.000000000 -0500
> +++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-06-11 11:53:26.000000000 -0500
> @@ -56,8 +56,13 @@ extern char spider_net_driver_name[];
>  
>  #define SPIDER_NET_RX_CSUM_DEFAULT		1
>  
> -#define SPIDER_NET_WATCHDOG_TIMEOUT		50*HZ
> -#define SPIDER_NET_NAPI_WEIGHT			64
> +#define SPIDER_NET_WATCHDOG_TIMEOUT		3*HZ
> +
> +/* We really really want to empty the ring buffer every time,
> + * so as to avoid the RX ram full bug. So set te napi wieght
> + * to the ring size.
> + */
> +#define SPIDER_NET_NAPI_WEIGHT	SPIDER_NET_RX_DESCRIPTORS_DEFAULT

I don't see why spider_net should have a different NAPI weight from 
other drivers


