From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 3/6] net: davinci_emac: Free clock after checking the
 frequency
Date: Tue, 13 Jan 2015 12:15:30 -0800
Message-ID: <20150113201529.GI2419@atomide.com>
References: <1421177368-19756-1-git-send-email-tony@atomide.com>
 <1421177368-19756-4-git-send-email-tony@atomide.com>
 <54B57688.6000908@amd.com>
 <20150113195035.GS16533@saruman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Lendacky <thomas.lendacky@amd.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org, Brian Hutchinson <b.hutchman@gmail.com>
To: Felipe Balbi <balbi@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150113195035.GS16533@saruman>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Felipe Balbi <balbi@ti.com> [150113 11:54]:
> On Tue, Jan 13, 2015 at 01:48:24PM -0600, Tom Lendacky wrote:
> > On 01/13/2015 01:29 PM, Tony Lindgren wrote:
> > >We only use clk_get() to get the frequency, the rest is done by
> > >the runtime PM calls. Let's free the clock too.
> > >
> > >Cc: Brian Hutchinson <b.hutchman@gmail.com>
> > >Cc: Felipe Balbi <balbi@ti.com>
> > >Signed-off-by: Tony Lindgren <tony@atomide.com>
> > >---
> > >  drivers/net/ethernet/ti/davinci_emac.c | 1 +
> > >  1 file changed, 1 insertion(+)
> > >
> > >diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> > >index deb43b3..e9efc74 100644
> > >--- a/drivers/net/ethernet/ti/davinci_emac.c
> > >+++ b/drivers/net/ethernet/ti/davinci_emac.c
> > >@@ -1881,6 +1881,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
> > >  		return -EBUSY;
> > >  	}
> > >  	emac_bus_frequency = clk_get_rate(emac_clk);
> > >+	clk_put(emac_clk);
> > 
> > The devm_clk_get call is used to get the clock so either a devm_clk_put
> > needs to be used here or just let the devm_ call do its thing and
> > automatically do the put when the module is unloaded.
> 
> instead, if you really don't need the clock for anything other than
> getting its rate, why don't you just remove devm_ prefix from clk_get()?

That would make the fix two lines instead of one :) I guess up to David
to figure out which he prefers, I don't really have a preference here.

Regards,

Tony
