From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH 1/7] net: mv643xx_eth: Simplify mv643xx_eth_adjust_link()
Date: Sun, 04 May 2014 23:23:05 +0200
Message-ID: <5366AFB9.3010603@gmail.com>
References: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com> <1399141622-30654-2-git-send-email-ezequiel.garcia@free-electrons.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:57817 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbaEDVXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 17:23:10 -0400
Received: by mail-ee0-f53.google.com with SMTP id b15so3642882eek.40
        for <netdev@vger.kernel.org>; Sun, 04 May 2014 14:23:09 -0700 (PDT)
In-Reply-To: <1399141622-30654-2-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2014 08:26 PM, Ezequiel Garcia wrote:
> Currently, mv643xx_eth_adjust_link() is only used to call mv643xx_adjust_pscr().
> This commit renames the latter to the former, and therefore removes the extra
> and useless function.
> 
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>

Acked-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

Thanks!

> ---
>  drivers/net/ethernet/marvell/mv643xx_eth.c | 15 +++++----------
>  1 file changed, 5 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
> index b7b8d74..1e63c63 100644
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> @@ -1010,8 +1010,10 @@ static void txq_set_fixed_prio_mode(struct tx_queue *txq)
>  
>  
>  /* mii management interface *************************************************/
> -static void mv643xx_adjust_pscr(struct mv643xx_eth_private *mp)
> +static void mv643xx_eth_adjust_link(struct net_device *dev)
>  {
> +	struct mv643xx_eth_private *mp = netdev_priv(dev);
> +
>  	u32 pscr = rdlp(mp, PORT_SERIAL_CONTROL);
>  	u32 autoneg_disable = FORCE_LINK_PASS |
>  	             DISABLE_AUTO_NEG_SPEED_GMII |
> @@ -1387,7 +1389,7 @@ mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  
>  	ret = phy_ethtool_sset(mp->phy, cmd);
>  	if (!ret)
> -		mv643xx_adjust_pscr(mp);
> +		mv643xx_eth_adjust_link(dev);
>  	return ret;
>  }
>  
> @@ -2303,7 +2305,7 @@ static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>  
>  	ret = phy_mii_ioctl(mp->phy, ifr, cmd);
>  	if (!ret)
> -		mv643xx_adjust_pscr(mp);
> +		mv643xx_eth_adjust_link(dev);
>  	return ret;
>  }
>  
> @@ -2701,13 +2703,6 @@ static void set_params(struct mv643xx_eth_private *mp,
>  	mp->txq_count = pd->tx_queue_count ? : 1;
>  }
>  
> -static void mv643xx_eth_adjust_link(struct net_device *dev)
> -{
> -	struct mv643xx_eth_private *mp = netdev_priv(dev);
> -
> -	mv643xx_adjust_pscr(mp);
> -}
> -
>  static struct phy_device *phy_scan(struct mv643xx_eth_private *mp,
>  				   int phy_addr)
>  {
> 
