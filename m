From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] netdev: enc28j60: use IRQF_TRIGGER_FALLING for IRQ by default
Date: Tue, 26 May 2009 04:24:17 -0700
Message-ID: <200905260424.17654.david-b@pacbell.net>
References: <1243333007-25645-1-git-send-email-vapier@gentoo.org> <20090526110614.GA1987@jasper.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	Bryan Wu <cooloney@kernel.org>
To: Baruch Siach <baruch@tkos.co.il>,
	Michael Hennerich <michael.hennerich@analog.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n20.bullet.mail.mud.yahoo.com ([68.142.206.147]:38446 "HELO
	n20.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753331AbZEZLYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 07:24:17 -0400
In-Reply-To: <20090526110614.GA1987@jasper.tkos.co.il>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 26 May 2009, Baruch Siach wrote:
> Hi Michael,
> 
> On Tue, May 26, 2009 at 06:16:47AM -0400, Mike Frysinger wrote:
> > From: Michael Hennerich <michael.hennerich@analog.com>
> > 
> > Rather than have the default IRQ flags not be usable, use the logical
> > settings which match the hardware.  Since the part is /INT, it makes sense
> > to have it default to a falling trigger.  If a board truly needs something
> > different, it still can tweak the defaults in its own board file.
> 
> You revert David Brownell's commit here 
> (c7b7b042068cd12b8b155722d24686f70b88ced1). Added to CC.

Right ... the appended patch will *undo* the setting
established in the board init code via set_irq_type().

Moreover, it completely prevents working on systems which
only support "both edges" triggering.

So I'd NAK this, on the grounds that it causes severe
breakage.



> > Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
> > Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> > Signed-off-by: Bryan Wu <cooloney@kernel.org>
> > CC: Baruch Siach <baruch@tkos.co.il>
> > ---
> >  drivers/net/enc28j60.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
> > index 36cb6e9..fbe2012 100644
> > --- a/drivers/net/enc28j60.c
> > +++ b/drivers/net/enc28j60.c
> > @@ -1562,7 +1562,7 @@ static int __devinit enc28j60_probe(struct spi_device *spi)
> >  	/* Board setup must set the relevant edge trigger type;
> >  	 * level triggers won't currently work.
> >  	 */
> > -	ret = request_irq(spi->irq, enc28j60_irq, 0, DRV_NAME, priv);
> > +	ret = request_irq(spi->irq, enc28j60_irq, IRQF_TRIGGER_FALLING, DRV_NAME, priv);
> >  	if (ret < 0) {
> >  		if (netif_msg_probe(priv))
> >  			dev_err(&spi->dev, DRV_NAME ": request irq %d failed "
> 
> baruch
> 
> -- 
>                                                      ~. .~   Tk Open Systems
> =}------------------------------------------------ooO--U--Ooo------------{=
>    - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
> 
> 



