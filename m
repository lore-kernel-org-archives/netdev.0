From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch 09/11] b44: fix eeprom endianess issue
Date: Tue, 26 Sep 2006 17:47:25 +0200
Message-ID: <200609261747.25575.mb@bu3sch.de>
References: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net> <45186D66.1000508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mb@bu3sch.de,
	Gary Zambrano <zambrano@broadcom.com>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:30681
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751265AbWIZPrl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 11:47:41 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45186D66.1000508@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 26 September 2006 01:59, Jeff Garzik wrote:
> akpm@osdl.org wrote:
> > From: Michael Buesch <mb@bu3sch.de>
> > 
> > This fixes eeprom read on big-endian architectures.
> > 
> > Signed-off-by: Michael Buesch <mb@bu3sch.de>
> > Cc: Jeff Garzik <jeff@garzik.org>
> > Signed-off-by: Andrew Morton <akpm@osdl.org>
> > ---
> > 
> >  drivers/net/b44.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff -puN drivers/net/b44.c~b44-fix-eeprom-endianess-issue drivers/net/b44.c
> > --- a/drivers/net/b44.c~b44-fix-eeprom-endianess-issue
> > +++ a/drivers/net/b44.c
> > @@ -2055,7 +2055,7 @@ static int b44_read_eeprom(struct b44 *b
> >  	u16 *ptr = (u16 *) data;
> >  
> >  	for (i = 0; i < 128; i += 2)
> > -		ptr[i / 2] = readw(bp->regs + 4096 + i);
> > +		ptr[i / 2] = cpu_to_le16(readw(bp->regs + 4096 + i));
> 
> Seems highly silly to me:  readw() already swaps on big endian, so 
> you're just swapping again.  And then...  read the call of 
> b44_read_eeprom():  bp->dev->dev_addr[] assignment is such that it swaps 
> YET AGAIN.
> 
> Seems like a better solution would be to remove the manual swap from the 
> caller of b44_read_eeprom().

I already explained this to you, but I will repeat me.
readw returns the data in CPU order.
With cpu_to_le16 we convert it to little endian, because
"ptr" is a pointer to a _byte_ arrray. See the cast above.
A byte array is little endian.
Should I go into deeper detail, or did you get it? ;)

The dev_addr assignment _intentionally_ swaps yet again, because
the values are stored in bigendian format in the SPROM.

Removing the swap for dev_addr would definately the worse and wrong
solution.

-- 
Greetings Michael.
