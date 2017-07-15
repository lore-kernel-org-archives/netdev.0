From: Sean Wang <sean.wang@mediatek.com>
Subject: Re: [PATCH net-next 2/4] net-next: mediatek: add platform data to
 adapt into various hardware
Date: Sat, 15 Jul 2017 09:47:41 +0800
Message-ID: <1500083261.16278.40.camel@mtkswgap22>
References: <cover.1499829241.git.sean.wang@mediatek.com>
         <401e9fa04ea4759c936fa5af11bb2b5c97ef14f0.1499829241.git.sean.wang@mediatek.com>
         <20170712145050.GD2557@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <john@phrozen.org>, <davem@davemloft.net>, <nbd@openwrt.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170712145050.GD2557@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-07-12 at 16:50 +0200, Andrew Lunn wrote:
> > +static int mtk_clk_enable(struct mtk_eth *eth)
> > +{
> > +	int clk, ret;
> > +
> > +	for (clk = 0; clk < MTK_CLK_MAX ; clk++) {
> > +		if (eth->clks[clk]) {
> > +			ret = clk_prepare_enable(eth->clks[clk]);
> > +			if (ret)
> > +				goto err_disable_clks;
> > +		}
> > +	}
> > +
> > +	return 0;
> > +
> > +err_disable_clks:
> > +	while (--clk >= 0) {
> > +		if (eth->clks[clk])
> > +			clk_disable_unprepare(eth->clks[clk]);
> > +	}
> > +
> > +	return ret;
> > +}
> 
> > +
> >  static int mtk_hw_init(struct mtk_eth *eth)
> >  {
> >  	int i, val;
> > @@ -1847,10 +1881,8 @@ static int mtk_hw_init(struct mtk_eth *eth)
> >  	pm_runtime_enable(eth->dev);
> >  	pm_runtime_get_sync(eth->dev);
> >  
> > -	clk_prepare_enable(eth->clks[MTK_CLK_ETHIF]);
> > -	clk_prepare_enable(eth->clks[MTK_CLK_ESW]);
> > -	clk_prepare_enable(eth->clks[MTK_CLK_GP1]);
> > -	clk_prepare_enable(eth->clks[MTK_CLK_GP2]);
> > +	mtk_clk_enable(eth);
> > +
> 
> mtk_clk_enable() returns an error code. It is probably a good idea to
> use it, especially if it could be EPRODE_DEFER.

okay, I will improve those clocks handling better along with Florian's
suggestion in the next version

	Sean












> 
>     Andrew
