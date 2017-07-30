From: Niklas =?iso-8859-1?Q?S=F6derlund?=
        <niklas.soderlund@ragnatech.se>
Subject: Re: [PATCH v2] ravb: add wake-on-lan support via magic packet
Date: Sun, 30 Jul 2017 22:19:29 +0200
Message-ID: <20170730201929.GF1382@bigcity.dyn.berto.se>
References: <20170730140646.11781-1-niklas.soderlund+renesas@ragnatech.se>
 <20170730170738.GA29373@lunn.ch>
 <20170730195154.GE1382@bigcity.dyn.berto.se>
 <20170730200731.GA20421@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:36809 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754232AbdG3UTc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 16:19:32 -0400
Received: by mail-lf0-f43.google.com with SMTP id o85so47368828lff.3
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 13:19:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170730200731.GA20421@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 2017-07-30 22:07:31 +0200, Andrew Lunn wrote:
> On Sun, Jul 30, 2017 at 09:51:54PM +0200, Niklas Söderlund wrote:
> > Hi Andrew,
> > 
> > On 2017-07-30 19:07:38 +0200, Andrew Lunn wrote:
> > > Hi Niklas
> > > 
> > > > @@ -2041,6 +2073,11 @@ static int ravb_probe(struct platform_device *pdev)
> > > >  
> > > >  	priv->chip_id = chip_id;
> > > >  
> > > > +	/* Get clock, if not found that's OK but Wake-On-Lan is unavailable */
> > > > +	priv->clk = devm_clk_get(&pdev->dev, NULL);
> > > > +	if (IS_ERR(priv->clk))
> > > > +		priv->clk = NULL;
> > > 
> > > Can you get EPROBE_DEFER returned?
> > 
> > I don't think so, but I'm not sure :-)
> > 
> > The clock I'm trying to get is the module clock of the ravb itself, so 
> > if that clock is not available (and enabled) no register writes to the 
> > ravb would be possible in the first place, so i guess it's safe to 
> > assume -EPROBE_DEFER can not happen here?
> > 
> > I'm just trying to play it safe here since the clock is only needed to 
> > support WoL, I though it best to not change behavior here. Try to get 
> > the clock, if we can great we can do WoL if not then user-space will be 
> > prevented from enabling WoL and nothing in the current behavior changes.
> 
> Hi Nikls
> 
> Well, if it can return -EPROBE_DEFER, it means sometimes WoL will be
> avalable and other times not, depending on when the clock driver

Ahh I see yes that would be indeed be bad.

> probes. However, it sounds like this is the SoCs core clock driver. If
> so, it gets loaded very early, so you are safe.

Yes this is renesas-cpg-mssr which if I understand things is a core 
clock driver. It is register in drivers/clk/renesas/renesas-cpg-mssr.c 
using:

 subsys_initcall(cpg_mssr_init);

So I take it I'm safe. Thanks however for bringing this to my attention 
I learnt something new today :-)

> 
>        Andrew

-- 
Regards,
Niklas Söderlund
