From: Christoph Fritz <chf.fritz@googlemail.com>
Subject: Re: [PATCH v2] can: sja1000: fix endian on arm
Date: Thu, 11 Apr 2013 20:53:33 +0200
Message-ID: <1365706413.4136.15.camel@mars>
References: <1365428932.5760.52.camel@lovely>
	 <5162CCB5.3000605@pengutronix.de> <1365705884.4136.5.camel@mars>
	 <51670532.5060101@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Rob Herring <rob.herring@calxeda.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	linux-can@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andreas Larsson <andreas@gaisler.com>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Daniel Mack <daniel@zonque.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f52.google.com ([209.85.214.52]:45080 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915Ab3DKSxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 14:53:48 -0400
In-Reply-To: <51670532.5060101@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-11 at 20:47 +0200, Marc Kleine-Budde wrote:
> On 04/11/2013 08:44 PM, Christoph Fritz wrote:
> > To get correct endian on arm cpus while reading device tree properties,
> > this patch replaces of_get_property() with of_property_read_u32().
> > 
> > Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
> 
> looks good, one nitpick inline
> 
> > ---
> >  drivers/net/can/sja1000/sja1000_of_platform.c |   32 ++++++++++++-------------
> >  1 file changed, 16 insertions(+), 16 deletions(-)
> > 
> > diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c

> > @@ -168,8 +168,8 @@ static int sja1000_ofp_probe(struct platform_device *ofdev)
> >  		priv->cdr |= CDR_CLK_OFF; /* default */
> >  	}
> >  
> > -	prop = of_get_property(np, "nxp,no-comparator-bypass", NULL);
> > -	if (!prop)
> > +	err = of_property_read_u32(np, "nxp,no-comparator-bypass", &prop);
> 
> What about using of_property_read_bool instead?

 Yeah, that would be better, thanks - let me re-roll this.
