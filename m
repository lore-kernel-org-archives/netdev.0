From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Wed, 21 May 2008 23:49:35 +0800
Message-ID: <E1JyqZL-0005qz-00@gondolin.me.apana.org.au>
References: <4832E223.7020206@trash.net>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net (Patrick McHardy)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45053 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934990AbYEUPtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 11:49:41 -0400
In-Reply-To: <4832E223.7020206@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> wrote:
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index b11e6e1..3be4559 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -514,10 +514,11 @@ struct net_device
> #define NETIF_F_NETNS_LOCAL    8192    /* Does not change network namespaces */
> #define NETIF_F_MULTI_QUEUE    16384   /* Has multiple TX/RX queues */
> #define NETIF_F_LRO            32768   /* large receive offload */
> +#define NETIF_F_VLAN_TSO       65536   /* Supports TSO for VLANs */

This has the potential to get pretty messy.  How about making a
driver call back that the VLAN layer can invoke to get the supported
feature bits for the VLAN device?

You have to modify the driver to set the bit anyway so could as well
add a function instead of a bit.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
