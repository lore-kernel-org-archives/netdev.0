From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 06/10] net: bcmgenet: add main driver file
Date: Thu, 13 Feb 2014 02:58:43 -0800
Message-ID: <1392289123.2214.36.camel@joe-AO722>
References: <1392269395-23513-1-git-send-email-f.fainelli@gmail.com>
	 <1392269395-23513-7-git-send-email-f.fainelli@gmail.com>
	 <20140213103506.GB14941@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, cernekee@gmail.com, devicetree@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0249.hostedemail.com ([216.40.44.249]:59212 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751440AbaBMK6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 05:58:49 -0500
In-Reply-To: <20140213103506.GB14941@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-13 at 11:35 +0100, Francois Romieu wrote:
> Florian Fainelli <f.fainelli@gmail.com> :
> [...]
> > diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
[]
> > +static int bcmgenet_set_rx_csum(struct net_device *dev,
> > +				netdev_features_t wanted)
> > +{
> > +	struct bcmgenet_priv *priv = netdev_priv(dev);
> > +	u32 rbuf_chk_ctrl;
> > +	int rx_csum_en;
> > +
> > +	rx_csum_en = !!(wanted & NETIF_F_RXCSUM);
> 
> It's a bool.

It could be a bool.

The struct definition has:

+	unsigned int desc_rxchk_en;

but perhaps a lot of these members could be bool.

It'd be nicer if the variable types were the same.

> > +	spin_lock_bh(&priv->bh_lock);
> > +	rbuf_chk_ctrl = bcmgenet_rbuf_readl(priv, RBUF_CHK_CTRL);
> > +
> > +	/* enable rx checksumming */
> > +	if (!rx_csum_en)
> > +		rbuf_chk_ctrl &= ~RBUF_RXCHK_EN;
> > +	else
> > +		rbuf_chk_ctrl |= RBUF_RXCHK_EN;

This is more normally written with a positive test like:

	if (rx_csum_en)
		rbuf_chk_ctrl |= RBUF_RXCHK_EN;
	else
		rbuf_chk_ctrl &= RBUF_RXCHK_EN;

> > +	priv->desc_rxchk_en = rx_csum_en;
