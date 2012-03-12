From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH] stmmac: Add device-tree support
Date: Mon, 12 Mar 2012 16:17:02 +0100
Message-ID: <20120312151702.GD13869@game.jcrosoft.org>
References: <1331561157-3820-1-git-send-email-sr@denx.de>
 <20120312143825.GB13869@game.jcrosoft.org>
 <201203121625.50283.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@ozlabs.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Viresh Kumar <viresh.kumar@st.com>
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 7.mo2.mail-out.ovh.net ([188.165.48.182]:59254 "EHLO
	mo2.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755862Ab2CLP2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 11:28:39 -0400
Received: from mail621.ha.ovh.net (b6.ovh.net [213.186.33.56])
	by mo2.mail-out.ovh.net (Postfix) with SMTP id B4F3CDC6B0A
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 16:31:52 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <201203121625.50283.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16:25 Mon 12 Mar     , Stefan Roese wrote:
> On Monday 12 March 2012 15:38:25 Jean-Christophe PLAGNIOL-VILLARD wrote:
> > > @@ -58,6 +94,22 @@ static int stmmac_pltfr_probe(struct platform_device
> > > *pdev)
> > > 
> > >  		ret = -ENOMEM;
> > >  		goto out_release_region;
> > >  	
> > >  	}
> > > 
> > > +
> > > +#ifdef CONFIG_OF
> > > +	plat_dat = devm_kzalloc(&pdev->dev, sizeof(struct
> > > plat_stmmacenet_data), +				GFP_KERNEL);
> > > +	if (!plat_dat) {
> > > +		pr_err("%s: ERROR: no memory", __func__);
> > > +		ret = -ENOMEM;
> > > +		goto out_unmap;
> > > +	}
> > > +
> > > +	ret = stmmac_probe_config_dt(pdev, plat_dat, &mac);
> > > +	if (ret) {
> > > +		pr_err("%s: main dt probe failed", __func__);
> > > +		goto out_unmap;
> > > +	}
> > > +#else
> > 
> > This must be check at runtime, we can boot a kernel with or without DT.
> 
> Are you referring to using "if (pdev->dev.of_node)" to distinguish between DT 
> and non-DT version instead of this #ifdef?
yes

Best Regards,
J.
