From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: NETIF_F_FRAGLIST and NETIF_F_SG difference
Date: Mon, 01 Mar 2010 12:58:41 +0000
Message-ID: <1267448321.2819.15.camel@localhost>
References: <de0a9dcb1003010302p2f81aa17ubdbb29bb007d50cf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raj ravi <mekaviraj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:22216 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235Ab0CAM6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 07:58:48 -0500
In-Reply-To: <de0a9dcb1003010302p2f81aa17ubdbb29bb007d50cf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-03-01 at 16:32 +0530, raj ravi wrote:
> Hi,
> http://lxr.linux.no/#linux+v2.6.33/include/linux/netdevice.h
> In include/linux/netdevice.h I can see two definiton for "Scatter
> Gather IO" namely NETIF_F_FRAGLIST  and NETIF_F_SG
> 
> Please let me know the difference between the two.... if there is no
> difference why two Macros ??
> 
> 
> #define NETIF_F_SG 1 /* Scatter/gather IO. */

This means the device can transmit an skb with extra data attached
through skb_shinfo(skb)->frags.

> #define NETIF_F_IP_CSUM 2 /* Can checksum TCP/UDP over IPv4. */
> #define NETIF_F_NO_CSUM 4 /* Does not require checksum. F.e. loopack. */
> #define NETIF_F_HW_CSUM 8 /* Can checksum all the packets. */
> #define NETIF_F_IPV6_CSUM 16 /* Can checksum TCP/UDP over IPV6 */
> #define NETIF_F_HIGHDMA 32 /* Can DMA to high memory. */
> #define NETIF_F_FRAGLIST 64 /* Scatter/gather IO. */

This means the device can transmit an skb with extra data attached
through skb->frags.

(I don't know why there are two ways of adding extra data.  The latter
does not seem to be used often.)

Note that these flags really refer only to DMA gather.  There is no need
for a feature flag for DMA scatter, since the driver controls RX buffer
allocation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

