From: "Hennerich, Michael" <Michael.Hennerich@analog.com>
Subject: RE: [PATCH] netdev: enc28j60: use IRQF_TRIGGER_FALLING for IRQ by default
Date: Tue, 26 May 2009 13:24:57 +0100
Message-ID: <8A42379416420646B9BFAC9682273B6D0B2B671E@limkexm3.ad.analog.com>
References: <1243333007-25645-1-git-send-email-vapier@gentoo.org> <20090526110614.GA1987@jasper.tkos.co.il> <200905260424.17654.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Mike Frysinger" <vapier@gentoo.org>, <netdev@vger.kernel.org>,
	"Bryan Wu" <cooloney@kernel.org>
To: "David Brownell" <david-b@pacbell.net>,
	"Baruch Siach" <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:28482 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754947AbZEZMhv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 08:37:51 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <200905260424.17654.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>From: David Brownell [mailto:david-b@pacbell.net]
>Sent: Tuesday, May 26, 2009 1:24 PM
>On Tuesday 26 May 2009, Baruch Siach wrote:
>> Hi Michael,
>>
>> On Tue, May 26, 2009 at 06:16:47AM -0400, Mike Frysinger wrote:
>> > From: Michael Hennerich <michael.hennerich@analog.com>
>> >
>> > Rather than have the default IRQ flags not be usable, use the
logical
>> > settings which match the hardware.  Since the part is /INT, it
makes sense
>> > to have it default to a falling trigger.  If a board truly needs
something
>> > different, it still can tweak the defaults in its own board file.
>>
>> You revert David Brownell's commit here
>> (c7b7b042068cd12b8b155722d24686f70b88ced1). Added to CC.
>
>Right ... the appended patch will *undo* the setting
>established in the board init code via set_irq_type().
>
>Moreover, it completely prevents working on systems which
>only support "both edges" triggering.
>
>So I'd NAK this, on the grounds that it causes severe
>breakage.

David,

The comment block above request_irq states:

>> >  	 * level triggers won't currently work.

And I guess it's because IRQ handling is deferred to a work queue.
I wonder how IRQF_TRIGGER_FALLING | IRQF_TRIGGER_RISING will work in
such a case.
Since the ENC28J60 /INT will de-assert during the work handler executes,
thus causing a second spurious interrupt.

-Michael 


>
>
>
>> > Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
>> > Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>> > Signed-off-by: Bryan Wu <cooloney@kernel.org>
>> > CC: Baruch Siach <baruch@tkos.co.il>
>> > ---
>> >  drivers/net/enc28j60.c |    2 +-
>> >  1 files changed, 1 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
>> > index 36cb6e9..fbe2012 100644
>> > --- a/drivers/net/enc28j60.c
>> > +++ b/drivers/net/enc28j60.c
>> > @@ -1562,7 +1562,7 @@ static int __devinit enc28j60_probe(struct
spi_device *spi)
>> >  	/* Board setup must set the relevant edge trigger type;
>> >  	 * level triggers won't currently work.
>> >  	 */
>> > -	ret = request_irq(spi->irq, enc28j60_irq, 0, DRV_NAME, priv);
>> > +	ret = request_irq(spi->irq, enc28j60_irq, IRQF_TRIGGER_FALLING,
DRV_NAME, priv);
>> >  	if (ret < 0) {
>> >  		if (netif_msg_probe(priv))
>> >  			dev_err(&spi->dev, DRV_NAME ": request irq %d
failed "
>>
>> baruch
>>
>> --
>>                                                      ~. .~   Tk Open
Systems
>>
=}------------------------------------------------ooO--U--Ooo-----------
-{=
>>    - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il
-
>>
>>
>
>
