From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] stmmac: Add device-tree support
Date: Mon, 12 Mar 2012 16:25:50 +0100
Message-ID: <201203121625.50283.sr@denx.de>
References: <1331561157-3820-1-git-send-email-sr@denx.de> <20120312143825.GB13869@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@ozlabs.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Viresh Kumar <viresh.kumar@st.com>
To: "Jean-Christophe PLAGNIOL-VILLARD" <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.181]:43592 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755944Ab2CLP0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 11:26:16 -0400
In-Reply-To: <20120312143825.GB13869@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 12 March 2012 15:38:25 Jean-Christophe PLAGNIOL-VILLARD wrote:
> > @@ -58,6 +94,22 @@ static int stmmac_pltfr_probe(struct platform_device
> > *pdev)
> > 
> >  		ret = -ENOMEM;
> >  		goto out_release_region;
> >  	
> >  	}
> > 
> > +
> > +#ifdef CONFIG_OF
> > +	plat_dat = devm_kzalloc(&pdev->dev, sizeof(struct
> > plat_stmmacenet_data), +				GFP_KERNEL);
> > +	if (!plat_dat) {
> > +		pr_err("%s: ERROR: no memory", __func__);
> > +		ret = -ENOMEM;
> > +		goto out_unmap;
> > +	}
> > +
> > +	ret = stmmac_probe_config_dt(pdev, plat_dat, &mac);
> > +	if (ret) {
> > +		pr_err("%s: main dt probe failed", __func__);
> > +		goto out_unmap;
> > +	}
> > +#else
> 
> This must be check at runtime, we can boot a kernel with or without DT.

Are you referring to using "if (pdev->dev.of_node)" to distinguish between DT 
and non-DT version instead of this #ifdef?

Thanks,
Stefan
