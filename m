From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] ravb: add wake-on-lan support via magic packet
Date: Sun, 30 Jul 2017 22:07:31 +0200
Message-ID: <20170730200731.GA20421@lunn.ch>
References: <20170730140646.11781-1-niklas.soderlund+renesas@ragnatech.se>
 <20170730170738.GA29373@lunn.ch>
 <20170730195154.GE1382@bigcity.dyn.berto.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Niklas =?iso-8859-1?Q?S=F6derlund?=
        <niklas.soderlund@ragnatech.se>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170730195154.GE1382@bigcity.dyn.berto.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 30, 2017 at 09:51:54PM +0200, Niklas Söderlund wrote:
> Hi Andrew,
> 
> On 2017-07-30 19:07:38 +0200, Andrew Lunn wrote:
> > Hi Niklas
> > 
> > > @@ -2041,6 +2073,11 @@ static int ravb_probe(struct platform_device *pdev)
> > >  
> > >  	priv->chip_id = chip_id;
> > >  
> > > +	/* Get clock, if not found that's OK but Wake-On-Lan is unavailable */
> > > +	priv->clk = devm_clk_get(&pdev->dev, NULL);
> > > +	if (IS_ERR(priv->clk))
> > > +		priv->clk = NULL;
> > 
> > Can you get EPROBE_DEFER returned?
> 
> I don't think so, but I'm not sure :-)
> 
> The clock I'm trying to get is the module clock of the ravb itself, so 
> if that clock is not available (and enabled) no register writes to the 
> ravb would be possible in the first place, so i guess it's safe to 
> assume -EPROBE_DEFER can not happen here?
> 
> I'm just trying to play it safe here since the clock is only needed to 
> support WoL, I though it best to not change behavior here. Try to get 
> the clock, if we can great we can do WoL if not then user-space will be 
> prevented from enabling WoL and nothing in the current behavior changes.

Hi Nikls

Well, if it can return -EPROBE_DEFER, it means sometimes WoL will be
avalable and other times not, depending on when the clock driver
probes. However, it sounds like this is the SoCs core clock driver. If
so, it gets loaded very early, so you are safe.

       Andrew
