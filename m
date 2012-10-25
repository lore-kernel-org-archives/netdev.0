From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH 1/2] net: Add support for hardware-offloaded
 encapsulation
Date: Thu, 25 Oct 2012 14:16:56 -0700
Message-ID: <20121025141656.5383dabe@nehalam.linuxnetplumber.net>
References: <1351189753-5912-1-git-send-email-joseph.gasparakis@intel.com>
	<1351189753-5912-2-git-send-email-joseph.gasparakis@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, chrisw@sous-sol.org, netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34623 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806Ab2JYVRp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 17:17:45 -0400
In-Reply-To: <1351189753-5912-2-git-send-email-joseph.gasparakis@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Oct 2012 11:29:12 -0700
Joseph Gasparakis <joseph.gasparakis@intel.com> wrote:

> @@ -19,6 +19,7 @@ enum {
>  	NETIF_F_IP_CSUM_BIT,		/* Can checksum TCP/UDP over IPv4. */
>  	__UNUSED_NETIF_F_1,
>  	NETIF_F_HW_CSUM_BIT,		/* Can checksum all the packets. */
> +	NETIF_F_HW_CSUM_ENC_BIT,	/* Can checksum all inner headers */
>  	NETIF_F_IPV6_CSUM_BIT,		/* Can checksum TCP/UDP over IPV6 */
>  	NETIF_F_HIGHDMA_BIT,		/* Can DMA to high memory. */
>  	NETIF_F_FRAGLIST_BIT,		/* Scatter/gather IO. */
> @@ -52,6 +53,8 @@ enum {
>  	NETIF_F_NTUPLE_BIT,		/* N-tuple filters supported */
>  	NETIF_F_RXHASH_BIT,		/* Receive hashing offload */
>  	NETIF_F_RXCSUM_BIT,		/* Receive checksumming offload */
> +	NETIF_F_RXCSUM_ENC_BIT,		/* Receive checksuming offload */
> +					/* for encapsulation */
>  	NETIF_F_NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
>  	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
>  	NETIF_F_RXFCS_BIT,		/* Append FCS to skb pkt data */

Add new features at the end, or reuse __UNUSED_ bits to avoid any
issues with binary compatibility. I don't think these bits are in any
userspace API, maybe ethtool?
