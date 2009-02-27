From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH] net: more timeouts that reach -1
Date: Fri, 27 Feb 2009 19:43:44 +0800
Message-ID: <20090227114015.M80857@cooldavid.org>
References: <49A5286D.80304@gmail.com>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:34184 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754706AbZB0Lxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 06:53:55 -0500
In-Reply-To: <49A5286D.80304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Feb 2009 12:15:57 +0100, Roel Kluin wrote
> These were not previously reported by me.
> ------------------------------>8-------------8<---------------------------------
> with while (timeout-- > 0); timeout reaches -1 after the loop, so the tests
> below are off by one.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
>  drivers/net/arm/ks8695net.c |    2 +-
>  drivers/net/jme.c           |    3 ++-
>  drivers/net/ucc_geth_mii.c  |    2 +-
>  3 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
> index 1cf2f94..f3a1274 100644
> --- a/drivers/net/arm/ks8695net.c
> +++ b/drivers/net/arm/ks8695net.c
> @@ -560,7 +560,7 @@ ks8695_reset(struct ks8695_priv *ksp)
>  		msleep(1);
>  	}
> 
> -	if (reset_timeout == 0) {
> +	if (reset_timeout < 0) {
>  		dev_crit(ksp->dev,
>  			 "Timeout waiting for DMA engines to reset\n");
>  		/* And blithely carry on */
> diff --git a/drivers/net/jme.c b/drivers/net/jme.c
> index 08b3405..0173ed0 100644
> --- a/drivers/net/jme.c
> +++ b/drivers/net/jme.c
> @@ -957,7 +957,8 @@ jme_process_receive(struct jme_adapter *jme, int limit)
>  		goto out_inc;
> 
>  	i = atomic_read(&rxring->next_to_clean);
> -	while (limit-- > 0) {
> +	while (limit > 0) {
> +		limit--;
>  		rxdesc = rxring->desc;
>  		rxdesc += i;
> 
There should be no difference after this modification.
The return value of this function is: "limit > 0 ? limit : 0;"
> diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
> index 5463591..7b1b46c 100644
> --- a/drivers/net/ucc_geth_mii.c
> +++ b/drivers/net/ucc_geth_mii.c
> @@ -123,7 +123,7 @@ static int uec_mdio_reset(struct mii_bus *bus)
> 
>  	mutex_unlock(&bus->mdio_lock);
> 
> -	if (timeout <= 0) {
> +	if (timeout < 0) {
>  		printk(KERN_ERR "%s: The MII Bus is stuck!\n", bus->name);
>  		return -EBUSY;
>  	}
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Guo-Fu Tseng

