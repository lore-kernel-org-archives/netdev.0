From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: remove tag_protocol from dsa_switch
Date: Wed, 20 Apr 2016 16:39:23 +0200
Message-ID: <20160420143923.GG13247@lunn.ch>
References: <1461018244-5371-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41707 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933095AbcDTOj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 10:39:26 -0400
Content-Disposition: inline
In-Reply-To: <1461018244-5371-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2016 at 06:24:04PM -0400, Vivien Didelot wrote:
> Having the tag protocol in dsa_switch_driver for setup time and in
> dsa_switch_tree for runtime is enough. Remove dsa_switch's one.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

I had to think about this one for a minute. At the moment it is good,
however, sometime in the future, we might want to revert it. Some
Marvell switches support two tagging schemes. At the moment, we have
no way to express that, so the switch driver only offers one. If we
were to extend the API to express a list of supported tagging schemes,
we would then want dsa_switch to contain the scheme actually chosen.
However, until we actually implement something like this, lets remove
it.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

	     Andrew

> ---
>  include/net/dsa.h | 5 -----
>  net/dsa/dsa.c     | 5 ++---
>  2 files changed, 2 insertions(+), 8 deletions(-)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index c4bc42b..2d280ab 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -136,11 +136,6 @@ struct dsa_switch {
>  	void *priv;
>  
>  	/*
> -	 * Tagging protocol understood by this switch
> -	 */
> -	enum dsa_tag_protocol	tag_protocol;
> -
> -	/*
>  	 * Configuration data for this switch.
>  	 */
>  	struct dsa_chip_data	*pd;
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index efa612f..d61ceed 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -267,7 +267,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
>  	 * switch.
>  	 */
>  	if (dst->cpu_switch == index) {
> -		switch (ds->tag_protocol) {
> +		switch (drv->tag_protocol) {
>  #ifdef CONFIG_NET_DSA_TAG_DSA
>  		case DSA_TAG_PROTO_DSA:
>  			dst->rcv = dsa_netdev_ops.rcv;
> @@ -295,7 +295,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
>  			goto out;
>  		}
>  
> -		dst->tag_protocol = ds->tag_protocol;
> +		dst->tag_protocol = drv->tag_protocol;
>  	}
>  
>  	/*
> @@ -411,7 +411,6 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
>  	ds->pd = pd;
>  	ds->drv = drv;
>  	ds->priv = priv;
> -	ds->tag_protocol = drv->tag_protocol;
>  	ds->master_dev = host_dev;
>  
>  	ret = dsa_switch_setup_one(ds, parent);
> -- 
> 2.8.0
> 
