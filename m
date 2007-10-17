From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] pcnet32: fix non-napi packet reception
Date: Wed, 17 Oct 2007 19:55:22 -0400
Message-ID: <4716A0EA.4050906@pobox.com>
References: <1192661962.474.10.camel@Linux.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52773 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755911AbXJQXzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 19:55:25 -0400
In-Reply-To: <1192661962.474.10.camel@Linux.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> Recent changes to the driver for the new napi API broke the reception of packets when in
> non-napi mode.  The initialization of napi.weight was removed for the non-napi case
> leaving the value zero.
> 
> Tested NAPI and non-NAPI on x86_64.
> 
> Signed-off-by: Don Fry <pcnet32@verizon.net>
> ---
> --- linux-2.6.23-git7/drivers/net/orig.pcnet32.c	2007-10-15 11:19:17.000000000 -0700
> +++ linux-2.6.23-git7/drivers/net/pcnet32.c	2007-10-17 15:56:15.000000000 -0700
> @@ -1849,6 +1849,9 @@ pcnet32_probe1(unsigned long ioaddr, int
>  	lp->mii_if.mdio_read = mdio_read;
>  	lp->mii_if.mdio_write = mdio_write;
>  
> +	/* napi.weight is used in both the napi and non-napi cases */
> +	lp->napi.weight = lp->rx_ring_size / 2;
> +
>  #ifdef CONFIG_PCNET32_NAPI
>  	netif_napi_add(dev, &lp->napi, pcnet32_poll, lp->rx_ring_size / 2);
>  #endif

In general, we're hoping to remove as many CONFIG_FOO_NAPI as possible, 
pushing everybody towards using NAPI.

Any objection to heading in this direction with pcnet32?

	Jeff



