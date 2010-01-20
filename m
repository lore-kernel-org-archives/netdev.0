From: Anatolij Gustschin <agust@denx.de>
Subject: Re: [PATCH 01/11] fs_enet: Add support for MPC512x to fs_enet
 driver
Date: Wed, 20 Jan 2010 12:20:58 +0100
Message-ID: <20100120122058.1539412b@wker>
References: <1263932653-3634-1-git-send-email-agust@denx.de>
	<1263932653-3634-2-git-send-email-agust@denx.de>
	<4B561AA3.7040506@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, wd@denx.de,
	John Rigby <jrigby@freescale.com>, netdev@vger.kernel.org,
	dzu@denx.de, Piotr Ziecik <kosmo@semihalf.com>
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:45289 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588Ab0ATLVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 06:21:08 -0500
In-Reply-To: <4B561AA3.7040506@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood <scottwood@freescale.com> wrote:

> > +	void __iomem *fec_fun_code;
> > +	void __iomem *fec_r_hash;
> > +	void __iomem *fec_x_cntrl;
> > +	void __iomem *fec_dma_control;
> > +};
> 
> Why void and not the specific type?

Ok, I will fix it for using u32 __iomem *.

> >  static void set_promiscuous_mode(struct net_device *dev)
> >  {
> >  	struct fs_enet_private *fep = netdev_priv(dev);
> > -	fec_t __iomem *fecp = fep->fec.fecp;
> > +	struct reg_tbl *fecp = fep->fec.rtbl;
> 
> Hmm, having something called "fecp" that is a different type than other 
> "fecp"s could be confusing.

Ok, I will use 'regp' instead of 'fecp' then.

> > @@ -134,6 +143,20 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
> >  	if (!fec->fecp)
> >  		goto out_fec;
> >  
> > +	if (of_device_is_compatible(ofdev->node, "fsl,mpc5121-fec-mdio")) {
> 
> You can put a data pointer in the of_platform match struct, instead of 
> re-checking the compatible.

.data pointer in 'fs_enet_mdio_fec_match' is already used for
mpc5xxx_get_bus_frequency(). Setting .data to some sort of FEC ID in
match struct for "fsl,pq1-fec-mdio" would be confusing to.
Would a simple

if (!strncmp(match->compatible, "fsl,mpc5121-fec-mdio",
             sizeof(match->compatible))) {

suffice here?

Thanks!

Anatolij
