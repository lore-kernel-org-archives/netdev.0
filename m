From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/5 v3] Tsi108_eth: remove not needed code
Date: Mon, 11 Feb 2008 14:50:26 -0500
Message-ID: <47B0A702.70601@pobox.com>
References: <d5f62df20802111135q36e47070w611291b2cea2253e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Alex Bounine <alex.bou9@gmail.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <d5f62df20802111135q36e47070w611291b2cea2253e@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Alex Bounine wrote:
> Code clean-up for tsi108_eth network driver.
> This patch removes not needed dummy read and the corresponding comment.
> The PHY logic requires two reads from the status register to get
> current link status. This is done correctly inside mii_check_media().
> 
> Signed-off-by: Alexandre Bounine <alexandreb@tundra.com>
> ---
> 
> diff -pNur linux-2.6.24/drivers/net/tsi108_eth.c
> linux-2.6.24-fix/drivers/net/tsi108_eth.c
> --- linux-2.6.24/drivers/net/tsi108_eth.c	2008-02-06 15:47:35.000000000 -0500
> +++ linux-2.6.24-fix/drivers/net/tsi108_eth.c	2008-02-06
> 15:54:14.000000000 -0500
> @@ -297,18 +297,11 @@ static void tsi108_check_phy(struct net_
>  	u32 speed;
>  	unsigned long flags;
> 
> -	/* Do a dummy read, as for some reason the first read
> -	 * after a link becomes up returns link down, even if
> -	 * it's been a while since the link came up.
> -	 */
> -
>  	spin_lock_irqsave(&phy_lock, flags);
> 
>  	if (!data->phy_ok)
>  		goto out;
> 
> -	tsi108_read_mii(data, MII_BMSR);
> -
>  	duplex = mii_check_media(&data->mii_if, netif_msg_link(data),
> data->init_media);

applied all five, but each one was still corrupted according to git-am. 
  I was able to apply four via patch(1), which is more forgiving, but 
there are still email problems.

As as you can see from the above quoted (last) line, your email client 
is still word-wrapping patches.
