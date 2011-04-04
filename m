From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next 1/7] tg3: Add 5720 ASIC rev
Date: Mon, 4 Apr 2011 16:05:06 -0700
Message-ID: <20110404230506.GA8250@mcarlson.broadcom.com>
References: <1301941495-8069-2-git-send-email-mcarlson@broadcom.com>
 <1301942262.1941.60.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1372 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920Ab1DDW7K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 18:59:10 -0400
In-Reply-To: <1301942262.1941.60.camel@Joe-Laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 04, 2011 at 11:37:42AM -0700, Joe Perches wrote:
> On Mon, 2011-04-04 at 11:24 -0700, Matt Carlson wrote:
> > This patch adds support for the 5720 ASIC rev.
> > 
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Reviewed-by: Michael Chan <mchan@broadcom.com>
> > ---
> >  drivers/net/tg3.c |   67 +++++++++++++++++++++++++++++++++++++---------------
> >  drivers/net/tg3.h |    5 ++++
> >  2 files changed, 52 insertions(+), 20 deletions(-)
> > 
> > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> > index b7e03a6..b105cdd 100644
> > --- a/drivers/net/tg3.c
> > +++ b/drivers/net/tg3.c
> > @@ -98,12 +98,14 @@
> >   */
> >  #define TG3_RX_STD_RING_SIZE(tp) \
> >  	((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 || \
> > -	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) ? \
> > +	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 || \
> > +	  GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) ? \
> 
> Maybe it'd be better to convert all of these:
> 
> 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
> 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
> 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
> 
> tests to a common functions something like:
> 
> static bool can_asic_<foo>(struct tg3 *tp)
> {
> 	int rev = GET_ASIC_REV(tp->pci_chip_rev_id);
> 	return (rev == ASIC_REV_5717) ||
> 	       (rev == ASIC_REV_5719) ||
> 	       (rev == ASIC_REV_5720);
> }

In general, we do try to do this.  We already have a TG3_FLG3_5717_PLUS
flag, but it includes the 57765 ASIC rev.  I thought :

	if ((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_57765)

didn't look much cleaner.  Demoting the 57765 from that flag also
uglifies the code too much.

Let me think about this a little more.

