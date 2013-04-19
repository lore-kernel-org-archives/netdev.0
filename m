From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 5/6] net: vlan: add 802.1ad support
Date: Fri, 19 Apr 2013 21:03:03 +0100
Message-ID: <1366401783.2716.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <1366373072-19621-1-git-send-email-kaber@trash.net>
	 <1366373072-19621-6-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41714 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962Ab3DSUDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:03:08 -0400
In-Reply-To: <1366373072-19621-6-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 14:04 +0200, Patrick McHardy wrote:
> Add support for 802.1ad VLAN devices. This mainly consists of checking for
> ETH_P_8021AD in addition to ETH_P_8021Q in a couple of places and check
> offloading capabilities based on the used protocol.
> 
> Configuration is done using "ip link":
> 
> # ip link add link eth0 eth0.1000 \
> 	type vlan proto 802.1ad id 1000
> # ip link add link eth0.1000 eth0.1000.1000 \
> 	type vlan proto 802.1q id 1000
> 
> 52:54:00:12:34:56 > 92:b1:54:28:e4:8c, ethertype 802.1Q (0x8100), length 106: vlan 1000, p 0, ethertype 802.1Q, vlan 1000, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto ICMP (1), length 84)
>     20.1.0.2 > 20.1.0.1: ICMP echo request, id 3003, seq 8, length 64
> 92:b1:54:28:e4:8c > 52:54:00:12:34:56, ethertype 802.1Q-QinQ (0x88a8), length 106: vlan 1000, p 0, ethertype 802.1Q, vlan 1000, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 47944, offset 0, flags [none], proto ICMP (1), length 84)
>     20.1.0.1 > 20.1.0.2: ICMP echo reply, id 3003, seq 8, length 64
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
[...]
> --- a/include/linux/netdev_features.h
> +++ b/include/linux/netdev_features.h
> @@ -25,6 +25,9 @@ enum {
>  	NETIF_F_HW_VLAN_CTAG_TX_BIT,	/* Transmit VLAN CTAG HW acceleration */
>  	NETIF_F_HW_VLAN_CTAG_RX_BIT,	/* Receive VLAN CTAG HW acceleration */
>  	NETIF_F_HW_VLAN_CTAG_FILTER_BIT,/* Receive filtering on VLAN CTAGs */
> +	NETIF_F_HW_VLAN_STAG_TX_BIT,	/* Transmit VLAN STAG HW acceleration */
> +	NETIF_F_HW_VLAN_STAG_RX_BIT,	/* Receive VLAN STAG HW acceleration */
> +	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
>  	NETIF_F_VLAN_CHALLENGED_BIT,	/* Device cannot handle VLAN packets */
>  	NETIF_F_GSO_BIT,		/* Enable software GSO. */
>  	NETIF_F_LLTX_BIT,		/* LockLess TX - deprecated. Please */
> @@ -83,6 +86,9 @@ enum {
>  #define NETIF_F_HW_VLAN_CTAG_FILTER __NETIF_F(HW_VLAN_CTAG_FILTER)
>  #define NETIF_F_HW_VLAN_CTAG_RX	__NETIF_F(HW_VLAN_CTAG_RX)
>  #define NETIF_F_HW_VLAN_CTAG_TX	__NETIF_F(HW_VLAN_CTAG_TX)
> +#define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
> +#define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
> +#define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
>  #define NETIF_F_IP_CSUM		__NETIF_F(IP_CSUM)
>  #define NETIF_F_IPV6_CSUM	__NETIF_F(IPV6_CSUM)
>  #define NETIF_F_LLTX		__NETIF_F(LLTX)
[...]

These need to be given names in the netdev_features_strings array in
net/core/ethtool.c

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
