From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: Re: [PATCH 2/7] fs_enet: Whitespace cleanup.
Date: Thu, 23 Aug 2007 01:04:37 +0400
Message-ID: <20070823010437.39a25b69@localhost.localdomain>
References: <20070817175320.GA8259@ld0162-tx32.am.freescale.net>
	<20070817175359.GB9218@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57079 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932318AbXHVVFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 17:05:05 -0400
In-Reply-To: <20070817175359.GB9218@ld0162-tx32.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Aug 2007 12:53:59 -0500
Scott Wood wrote:

> Signed-off-by: Scott Wood <scottwood@freescale.com>

Acked-by: Vitaly Bordug <vitb@kernel.crashing.org>


> ---
>  drivers/net/fs_enet/fs_enet-main.c |   85
> ++++++++++++++++-------------------
> drivers/net/fs_enet/fs_enet.h      |    4 +-
> drivers/net/fs_enet/mac-fcc.c      |    1 -
> drivers/net/fs_enet/mii-fec.c      |    1 - 4 files changed, 41
> insertions(+), 50 deletions(-)
> 
> diff --git a/drivers/net/fs_enet/fs_enet-main.c
> b/drivers/net/fs_enet/fs_enet-main.c index a4a2a0e..f261b90 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -353,7 +353,6 @@ static void fs_enet_tx(struct net_device *dev)
>  
>  	do_wake = do_restart = 0;
>  	while (((sc = CBDR_SC(bdp)) & BD_ENET_TX_READY) == 0) {
> -
>  		dirtyidx = bdp - fep->tx_bd_base;
>  
>  		if (fep->tx_free == fep->tx_ring)
> @@ -454,7 +453,6 @@ fs_enet_interrupt(int irq, void *dev_id)
>  
>  	nr = 0;
>  	while ((int_events = (*fep->ops->get_int_events)(dev)) != 0)
> { -
>  		nr++;
>  
>  		int_clr_events = int_events;
> @@ -710,45 +708,43 @@ static void fs_timeout(struct net_device *dev)
>   *-----------------------------------------------------------------------------*/
>  static void generic_adjust_link(struct  net_device *dev)
>  {
> -       struct fs_enet_private *fep = netdev_priv(dev);
> -       struct phy_device *phydev = fep->phydev;
> -       int new_state = 0;
> -
> -       if (phydev->link) {
> -
> -               /* adjust to duplex mode */
> -               if (phydev->duplex != fep->oldduplex){
> -                       new_state = 1;
> -                       fep->oldduplex = phydev->duplex;
> -               }
> -
> -               if (phydev->speed != fep->oldspeed) {
> -                       new_state = 1;
> -                       fep->oldspeed = phydev->speed;
> -               }
> -
> -               if (!fep->oldlink) {
> -                       new_state = 1;
> -                       fep->oldlink = 1;
> -                       netif_schedule(dev);
> -                       netif_carrier_on(dev);
> -                       netif_start_queue(dev);
> -               }
> -
> -               if (new_state)
> -                       fep->ops->restart(dev);
> -
> -       } else if (fep->oldlink) {
> -               new_state = 1;
> -               fep->oldlink = 0;
> -               fep->oldspeed = 0;
> -               fep->oldduplex = -1;
> -               netif_carrier_off(dev);
> -               netif_stop_queue(dev);
> -       }
> -
> -       if (new_state && netif_msg_link(fep))
> -               phy_print_status(phydev);
> +	struct fs_enet_private *fep = netdev_priv(dev);
> +	struct phy_device *phydev = fep->phydev;
> +	int new_state = 0;
> +
> +	if (phydev->link) {
> +		/* adjust to duplex mode */
> +		if (phydev->duplex != fep->oldduplex) {
> +			new_state = 1;
> +			fep->oldduplex = phydev->duplex;
> +		}
> +
> +		if (phydev->speed != fep->oldspeed) {
> +			new_state = 1;
> +			fep->oldspeed = phydev->speed;
> +		}
> +
> +		if (!fep->oldlink) {
> +			new_state = 1;
> +			fep->oldlink = 1;
> +			netif_schedule(dev);
> +			netif_carrier_on(dev);
> +			netif_start_queue(dev);
> +		}
> +
> +		if (new_state)
> +			fep->ops->restart(dev);
> +	} else if (fep->oldlink) {
> +		new_state = 1;
> +		fep->oldlink = 0;
> +		fep->oldspeed = 0;
> +		fep->oldduplex = -1;
> +		netif_carrier_off(dev);
> +		netif_stop_queue(dev);
> +	}
> +
> +	if (new_state && netif_msg_link(fep))
> +		phy_print_status(phydev);
>  }
>  
>  
> @@ -792,7 +788,6 @@ static int fs_init_phy(struct net_device *dev)
>  	return 0;
>  }
>  
> -
>  static int fs_enet_open(struct net_device *dev)
>  {
>  	struct fs_enet_private *fep = netdev_priv(dev);
> @@ -978,7 +973,7 @@ static struct net_device *fs_init_instance(struct
> device *dev, #endif
>  
>  #ifdef CONFIG_FS_ENET_HAS_SCC
> -	if (fs_get_scc_index(fpi->fs_no) >=0 )
> +	if (fs_get_scc_index(fpi->fs_no) >= 0)
>  		fep->ops = &fs_scc_ops;
>  #endif
>  
> @@ -1069,9 +1064,8 @@ static struct net_device
> *fs_init_instance(struct device *dev, 
>  	return ndev;
>  
> -      err:
> +err:
>  	if (ndev != NULL) {
> -
>  		if (registered)
>  			unregister_netdev(ndev);
>  
> @@ -1262,7 +1256,6 @@ static int __init fs_init(void)
>  err:
>  	cleanup_immap();
>  	return r;
> -	
>  }
>  
>  static void __exit fs_cleanup(void)
> diff --git a/drivers/net/fs_enet/fs_enet.h
> b/drivers/net/fs_enet/fs_enet.h index 569be22..72a61e9 100644
> --- a/drivers/net/fs_enet/fs_enet.h
> +++ b/drivers/net/fs_enet/fs_enet.h
> @@ -15,8 +15,8 @@
>  #include <asm/commproc.h>
>  
>  struct fec_info {
> -        fec_t*  fecp;
> -	u32     mii_speed;
> +	fec_t *fecp;
> +	u32 mii_speed;
>  };
>  #endif
>  
> diff --git a/drivers/net/fs_enet/mac-fcc.c
> b/drivers/net/fs_enet/mac-fcc.c index 5603121..ad3c5fa 100644
> --- a/drivers/net/fs_enet/mac-fcc.c
> +++ b/drivers/net/fs_enet/mac-fcc.c
> @@ -86,7 +86,6 @@
>  static inline int fcc_cr_cmd(struct fs_enet_private *fep, u32 mcn,
> u32 op) {
>  	const struct fs_platform_info *fpi = fep->fpi;
> -
>  	cpm2_map_t *immap = fs_enet_immap;
>  	cpm_cpm2_t *cpmp = &immap->im_cpm;
>  	u32 v;
> diff --git a/drivers/net/fs_enet/mii-fec.c
> b/drivers/net/fs_enet/mii-fec.c index 0a563a8..53db696 100644
> --- a/drivers/net/fs_enet/mii-fec.c
> +++ b/drivers/net/fs_enet/mii-fec.c
> @@ -113,7 +113,6 @@ static int fs_enet_fec_mii_read(struct mii_bus
> *bus , int phy_id, int location) }
>  
>  	return ret;
> -
>  }
>  
>  static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id,
> int location, u16 val)


-- 
Sincerely, Vitaly
