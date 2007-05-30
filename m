From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] IPV6 checksum offloading in network devices
Date: Wed, 30 May 2007 18:13:24 +0200
Message-ID: <465DA2A4.2060608@trash.net>
References: <20070529135813.63303693@freepuppy>	<20070529213618.GA9360@gondor.apana.org.au> <20070530085320.0c35bd71@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert.xu@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42892 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbXE3QN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 12:13:28 -0400
In-Reply-To: <20070530085320.0c35bd71@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Here is a proposed change to address hardware that can do IPV6 checksum
> offload, but doesn't truly do generic hw checksumming.  The bnx2 and tg3
> are like this for some revisions, and upcoming Marvell 88e8071 is similar.
> 
> 
> --- a/include/linux/netdevice.h	2007-05-30 08:26:18.000000000 -0700
> +++ b/include/linux/netdevice.h	2007-05-30 08:30:20.000000000 -0700
> @@ -314,9 +314,10 @@ struct net_device
>  	/* Net device features */
>  	unsigned long		features;
>  #define NETIF_F_SG		1	/* Scatter/gather IO. */
> -#define NETIF_F_IP_CSUM		2	/* Can checksum only TCP/UDP over IPv4. */
> +#define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
>  #define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack. */
>  #define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
> +#define NETIF_F_IPV6_CSUM	16	/* Can checksum TCP/UDP over IPV6 */
>  #define NETIF_F_HIGHDMA		32	/* Can DMA to high memory. */
>  #define NETIF_F_FRAGLIST	64	/* Scatter/gather IO. */
>  #define NETIF_F_HW_VLAN_TX	128	/* Transmit VLAN hw acceleration */
> @@ -339,7 +340,8 @@ struct net_device
>  #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6)
>  
>  #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
> -#define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSUM | NETIF_F_GEN_CSUM)
> +#define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM \
> +				 | NETIF_F_GEN_CSUM)


This might confuse some of the existing IPv4 code that
checks for NETIF_F_ALL_CSUM if we ever get a device that
has NETIF_F_IPV6_CSUM but not NETIF_F_IP_CSUM.

