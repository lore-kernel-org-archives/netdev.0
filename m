From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Thu, 08 Jan 2009 22:20:43 -0500
Message-ID: <4966C28B.6060304@pobox.com>
References: <200901080203.SAA19103@tardy.cup.hp.com> <1231384446.2677.32.camel@hashbaz.i.decadent.org.uk> <49656F01.3090603@pobox.com> <20090109025244.GA11336@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Rick Jones <rick.jones2@hp.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43556 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753096AbZAIDU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 22:20:56 -0500
In-Reply-To: <20090109025244.GA11336@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jan 08, 2009 at 03:12:01AM +0000, Jeff Garzik wrote:
>> The next release of ethtool is coming in about 4 weeks, and we can  
>> definitely get something like this in there.
> 
> Jeff, any chance you can stick this patch in there to add the GRO
> toggle?
> 
> ethtool: Add GRO toggle
> 
> This patch adds the -k toggles to query and set GRO on a device.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/ethtool-copy.h b/ethtool-copy.h
> index eadba25..3ca4e2c 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -336,6 +336,8 @@ struct ethtool_rxnfc {
>  
>  #define	ETHTOOL_GRXFH		0x00000029 /* Get RX flow hash configuration */
>  #define	ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
> +#define	ETHTOOL_GGRO		0x0000002b /* Get GRO enable (ethtool_value) */
> +#define	ETHTOOL_SGRO		0x0000002c /* Set GRO enable (ethtool_value) */

Ugh...  is it too late to change this interface?

The person who added this should have used the new flags interface, and 
added ETH_FLAG_GRO right next to the pre-existing ETH_FLAG_LRO.

It is incorrect to add new ioctls just to toggle a boolean value.

	Jeff




