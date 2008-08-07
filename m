From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] ethtool: Expand ethtool_cmd.speed to 32 bits
Date: Thu, 07 Aug 2008 02:24:18 -0400
Message-ID: <489A9512.5090805@pobox.com>
References: <20080715091841.GA6553@potty.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Brandon Philips <brandon@ifup.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53833 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754154AbYHGGYW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:24:22 -0400
In-Reply-To: <20080715091841.GA6553@potty.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandon Philips wrote:
> Introduce the speed_hi field to ethtool_cmd, using the reserved space,
> to expand the speed field to 2^32 Megabits/second.
> 
> Making this field expansion now gives us plenty of time to fix up the
> user-space pieces that use SIOCETHTOOL before hardware faster than 64
> Gb/s is available.
> 
> Signed-off-by: Brandon Philips <bphilips@suse.de>
> 
> ---
>  include/linux/ethtool.h |   17 ++++++++++++++++-
>  1 file changed, 16 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/include/linux/ethtool.h
> ===================================================================
> --- linux-2.6.orig/include/linux/ethtool.h
> +++ linux-2.6/include/linux/ethtool.h
> @@ -27,9 +27,24 @@ struct ethtool_cmd {
>  	__u8	autoneg;	/* Enable or disable autonegotiation */
>  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
>  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
> -	__u32	reserved[4];
> +	__u16	speed_hi;
> +	__u16	reserved2;
> +	__u32	reserved[3];
>  };
>  
> +static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
> +						__u32 speed)
> +{
> +
> +	ep->speed = (__u16)speed;
> +	ep->speed_hi = (__u16)(speed >> 16);
> +}
> +
> +static inline __u32 ethtool_cmd_speed(struct ethtool_cmd *ep)
> +{
> +	return (ep->speed_hi << 16) | ep->speed;
> +}
> +

applied


