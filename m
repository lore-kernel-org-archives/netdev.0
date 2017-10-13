From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ravb: Consolidate clock handling
Date: Fri, 13 Oct 2017 10:05:34 +0200
Message-ID: <20171013080533.sar3wradzyxorlgs@verge.net.au>
References: <1507796693-14268-1-git-send-email-geert+renesas@glider.be>
 <20171012095508.vjpqvq37474qp2cb@verge.net.au>
 <CAMuHMdUpvrWpyiAo2qT=5JWHU+jpbDgV8LuvF0-+pC825XQMeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Niklas =?utf-8?Q?S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48212 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751655AbdJMIFx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 04:05:53 -0400
Content-Disposition: inline
In-Reply-To: <CAMuHMdUpvrWpyiAo2qT=5JWHU+jpbDgV8LuvF0-+pC825XQMeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 12, 2017 at 02:20:45PM +0200, Geert Uytterhoeven wrote:
> Hi Simon,
> 
> On Thu, Oct 12, 2017 at 11:55 AM, Simon Horman <horms@verge.net.au> wrote:
> > On Thu, Oct 12, 2017 at 10:24:53AM +0200, Geert Uytterhoeven wrote:
> >> The module clock is used for two purposes:
> >>   - Wake-on-LAN (WoL), which is optional,
> >>   - gPTP Timer Increment (GTI) configuration, which is mandatory.
> >>
> >> As the clock is needed for GTI configuration anyway, WoL is always
> >> available.  Hence remove duplication and repeated obtaining of the clock
> >> by making GTI use the stored clock for WoL use.
> >
> > Hi Geert,
> >
> > I understand from the statements above that the clock must be present,
> > but I'm most sure that I understand why that means that WoL is always
> > available.
> 
> That refers to the part below: WoL was considered available iff the clock
> is available.
> 
> @@ -2073,10 +2058,11 @@ static int ravb_probe(struct platform_device *pdev)
> 
>         priv->chip_id = chip_id;
> 
> -       /* Get clock, if not found that's OK but Wake-On-Lan is unavailable */
>         priv->clk = devm_clk_get(&pdev->dev, NULL);
> -       if (IS_ERR(priv->clk))
> -               priv->clk = NULL;
> +       if (IS_ERR(priv->clk)) {
> +               error = PTR_ERR(priv->clk);
> +               goto out_release;
> +       }
> 
> But the clock must always be available, else GTI configuration
> would fail, and ravb initialization would return with an error.

Thanks, that was the information I had missed.

Belated:

Reviewed-by: Simon Horman <horms+renesas@verge.net.au>
