From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH v2] stmmac: Add device-tree support
Date: Tue, 13 Mar 2012 11:29:34 +0100
Message-ID: <201203131129.34449.sr@denx.de>
References: <1331623394-14600-1-git-send-email-sr@denx.de> <4F5F0AF2.1070508@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@ozlabs.org" <devicetree-discuss@ozlabs.org>,
	"spear-devel" <spear-devel@list.st.com>,
	Peppe CAVALLARO <peppe.cavallaro@st.com>
To: Viresh Kumar <viresh.kumar@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.180]:54300 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965046Ab2CMKaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 06:30:03 -0400
In-Reply-To: <4F5F0AF2.1070508@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 13 March 2012 09:53:06 Viresh Kumar wrote:
> On 3/13/2012 12:53 PM, Stefan Roese wrote:
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > 
> > +#ifdef CONFIG_OF
> > +static int __devinit stmmac_probe_config_dt(struct platform_device
> > *pdev, +					    struct 
plat_stmmacenet_data *plat,
> > +					    const char **mac)
> > +{
> 
> <snip...>
> 
> > +}
> > +#else
> > +static int __devinit stmmac_probe_config_dt(struct platform_device
> > *pdev, +					    struct 
plat_stmmacenet_data *plat,
> > +					    const char **mac)
> > +{
> > +	return ERR_PTR(-ENOSYS);
> 
> why ERR_PTR()?

Thanks for spotting. Will fix in next version.
 
> > +}
> > +#endif /* CONFIG_OF */
> > +
> > 
> >  /**
> >  
> >   * stmmac_pltfr_probe
> >   * @pdev: platform device pointer
> > 
> > @@ -58,7 +101,25 @@ static int stmmac_pltfr_probe(struct platform_device
> > *pdev)
> > 
> >  		ret = -ENOMEM;
> >  		goto out_release_region;
> >  	
> >  	}
> > 
> > -	plat_dat = pdev->dev.platform_data;
> > +
> > +	if (pdev->dev.of_node) {
> > +		plat_dat = devm_kzalloc(&pdev->dev,
> > +					sizeof(struct 
plat_stmmacenet_data),
> > +					GFP_KERNEL);
> > +		if (!plat_dat) {
> > +			pr_err("%s: ERROR: no memory", __func__);
> 
> why don't we use dev_err here?

Consistency. pr_err is used in this driver. So I'm sticking to it with this 
patch as well.
 
Thanks,
Stefan
