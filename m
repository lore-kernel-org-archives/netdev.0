From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH v4.2] FEC - fast ethernet controller for mpc52xx
Date: Fri, 26 Oct 2007 07:18:28 -0700
Message-ID: <20071026141828.GA14900@xyzzy.farnsworth.org>
References: <20071014075511.GC3000@nd47.coderock.org> <4713BA1C.2050604@pobox.com> <fa686aa40710180715u23d81adfy83ff65837725fb80@mail.gmail.com> <4717B09B.3060800@pobox.com> <20071019112700.GD27403@nd47.coderock.org> <47206209.8080109@pobox.com> <20071025185706.29496.qmail@farnsworth.org> <20071025194114.GH3369@nd47.coderock.org> <20071025202908.GA2102@xyzzy.farnsworth.org> <20071026115909.GI3369@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Domen Puncer <domen.puncer@telargo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:50478 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751014AbXJZOS3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 10:18:29 -0400
Content-Disposition: inline
In-Reply-To: <20071026115909.GI3369@nd47.coderock.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 26, 2007 at 01:59:09PM +0200, Domen Puncer wrote:
> +static irqreturn_t mpc52xx_fec_tx_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *dev = dev_id;
> +	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> +
> +	spin_lock(&priv->lock);
> +
> +	while (bcom_buffer_done(priv->tx_dmatsk)) {
> +		struct sk_buff *skb;
> +		struct bcom_fec_bd *bd;
> +		skb = bcom_retrieve_buffer(priv->tx_dmatsk, NULL,
> +				(struct bcom_bd **)&bd);
> +		/* Here (and in rx routines) would be a good place for
> +		 * dma_unmap_single(), but bcom doesn't return bcom_bd of the
> +		 * finished transfer, and _unmap is empty on this platfrom.
> +		 */

Oops, you forgot to remove the above comment.  :)

Otherwise,
Acked-by: Dale Farnsworth <dale@farnsworth.org>

Domen, thanks for all your work on this.  It's good to see it finally go in.

-Dale
