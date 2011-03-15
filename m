From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv2 1/9] at91: provide macb clks with "pclk" and "hclk" name
Date: Tue, 15 Mar 2011 12:44:16 +0000
Message-ID: <20110315124416.GG2914@pulham.picochip.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
 <1300184096-13937-2-git-send-email-jamie@jamieiles.com>
 <20110315123539.GD14548@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, nicolas.ferre@atmel.com
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58827 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757280Ab1COMoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 08:44:20 -0400
Received: by bwz15 with SMTP id 15so491417bwz.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 05:44:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110315123539.GD14548@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 15, 2011 at 01:35:39PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> On 10:14 Tue 15 Mar     , Jamie Iles wrote:
> > The macb driver expects clocks with the names "pclk" and "hclk".  We
> > currently provide "macb_clk" but to fit in line with other
> > architectures (namely AVR32), provide "pclk" and a fake "hclk".
> > 
> > Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> > Signed-off-by: Jamie Iles <jamie@jamieiles.com>
> > ---
> >  arch/arm/mach-at91/at572d940hf.c |    8 +++++++-
> >  arch/arm/mach-at91/at91cap9.c    |    8 +++++++-
> >  arch/arm/mach-at91/at91sam9260.c |    8 +++++++-
> >  arch/arm/mach-at91/at91sam9263.c |    8 +++++++-
> >  arch/arm/mach-at91/at91sam9g45.c |    8 +++++++-
> >  5 files changed, 35 insertions(+), 5 deletions(-)
> > 
> > diff --git a/arch/arm/mach-at91/at572d940hf.c b/arch/arm/mach-at91/at572d940hf.c
> > index a6b9c68..9b3a37e 100644
> > --- a/arch/arm/mach-at91/at572d940hf.c
> > +++ b/arch/arm/mach-at91/at572d940hf.c
> > @@ -71,10 +71,15 @@ static struct clk pioC_clk = {
> >  	.type		= CLK_TYPE_PERIPHERAL,
> >  };
> >  static struct clk macb_clk = {
> > -	.name		= "macb_clk",
> > +	.name		= "pclk",
> >  	.pmc_mask	= 1 << AT572D940HF_ID_EMAC,
> >  	.type		= CLK_TYPE_PERIPHERAL,
> >  };
> > +static struct clk macb_hclk = {
> > +	.name		= "hclk",
> > +	.pmc_mask	= 0,
> > +	.type		= CLK_TYPE_PERIPHERAL,
> > +};
> for the fake clock you must specify the parent as macb_clk
> 
> take a look on the tcb1_clk for the 9g45

Ok, will do.  Thanks for the pointer!

Jamie
