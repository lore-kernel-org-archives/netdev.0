From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH net-next] net: am79c961a: Omit check for multicast bit
	in netdev_for_each_mc_addr
Date: Thu, 30 Jun 2011 10:23:49 +0100
Message-ID: <20110630092349.GR21898@n2100.arm.linux.org.uk>
References: <1309349686-1506-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:47003 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322Ab1F3JYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 05:24:02 -0400
Content-Disposition: inline
In-Reply-To: <1309349686-1506-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2011 at 02:14:46PM +0200, Tobias Klauser wrote:
> There is no need to check for the address being a multicast address in
> the netdev_for_each_mc_addr loop, so remove it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Thanks.

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

> ---
>  drivers/net/arm/am79c961a.c |   14 ++++++--------
>  1 files changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
> index 7b3e23f..52fe21e 100644
> --- a/drivers/net/arm/am79c961a.c
> +++ b/drivers/net/arm/am79c961a.c
> @@ -199,17 +199,15 @@ am79c961_ramtest(struct net_device *dev, unsigned int val)
>  
>  static void am79c961_mc_hash(char *addr, u16 *hash)
>  {
> -	if (addr[0] & 0x01) {
> -		int idx, bit;
> -		u32 crc;
> +	int idx, bit;
> +	u32 crc;
>  
> -		crc = ether_crc_le(ETH_ALEN, addr);
> +	crc = ether_crc_le(ETH_ALEN, addr);
>  
> -		idx = crc >> 30;
> -		bit = (crc >> 26) & 15;
> +	idx = crc >> 30;
> +	bit = (crc >> 26) & 15;
>  
> -		hash[idx] |= 1 << bit;
> -	}
> +	hash[idx] |= 1 << bit;
>  }
>  
>  static unsigned int am79c961_get_rx_mode(struct net_device *dev, u16 *hash)
> -- 
> 1.7.5.4
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
