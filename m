From: David Miller <davem@davemloft.net>
Subject: Re: [2/4] [IPV4]: Convert IPv4 devconf to an array
Date: Mon, 04 Jun 2007 23:17:54 -0700 (PDT)
Message-ID: <20070604.231754.74747974.davem@davemloft.net>
References: <20070602100132.GA9129@gondor.apana.org.au>
	<20070602100252.GB9247@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45796
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759985AbXFEGRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 02:17:40 -0400
In-Reply-To: <20070602100252.GB9247@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 2 Jun 2007 20:02:52 +1000

> @@ -64,20 +64,26 @@
>  #include <net/rtnetlink.h>
>  
>  struct ipv4_devconf ipv4_devconf = {
> -	.accept_redirects = 1,
> -	.send_redirects =  1,
> -	.secure_redirects = 1,
> -	.shared_media =	  1,
> +	.data = {
> +		[NET_IPV4_CONF_ACCEPT_REDIRECTS] = 1,
> +		[NET_IPV4_CONF_SEND_REDIRECTS] = 1,
> +		[NET_IPV4_CONF_SECURE_REDIRECTS] = 1,
> +		[NET_IPV4_CONF_SHARED_MEDIA] = 1,
> +	},
>  };

These array indexes are off by one.

This is the danger in using this "x-1" indexing style.
Such a mistake is way too easy to make.
