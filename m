From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [PATCH] pcnet32: fix user visible typo
Date: Tue, 29 Aug 2006 08:37:44 -0700
Message-ID: <20060829153744.GA9881@us.ibm.com>
References: <20060828233248.GA5193@martell.zuzino.mipt.ru> <20060828235142.GA6633@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tsbogend@alpha.franken.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:4061 "EHLO e33.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S965030AbWH2PhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 11:37:08 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7TFb81Z024331
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 11:37:08 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7TFb3oC161368
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 09:37:04 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7TFb3SU029337
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 09:37:03 -0600
To: Alexey Dobriyan <adobriyan@gmail.com>
Content-Disposition: inline
In-Reply-To: <20060828235142.GA6633@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey,

Your patch is fine.  I had not looked at the if which would prevent zero
cards from even printing.

On Mon, Aug 28, 2006 at 04:51:42PM -0700, Don Fry wrote:
> The cause of #6428 has already been fixed in v1.32 of the pcnet32
> driver.  To be correct, the printk should be:
> 
> 		printk(KERN_INFO PFX "%d card%s found\n",
> 			cards_found, cards_found != 1 ? "s" : "");
> 
> So that zero cards also says 'pcnet32: 0 cards found.'
> Why delete the period from the end of the sentence?
> 
> On Tue, Aug 29, 2006 at 03:32:49AM +0400, Alexey Dobriyan wrote:
> > Also, final dot removed and single form fixed. The cause of #6428 is
> > still to be found.
> > 
> > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> > ---
> > 
> >  drivers/net/pcnet32.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > --- a/drivers/net/pcnet32.c
> > +++ b/drivers/net/pcnet32.c
> > @@ -2986,7 +2986,8 @@ static int __init pcnet32_init_module(vo
> >  		pcnet32_probe_vlbus(pcnet32_portlist);
> >  
> >  	if (cards_found && (pcnet32_debug & NETIF_MSG_PROBE))
> > -		printk(KERN_INFO PFX "%d cards_found.\n", cards_found);
> > +		printk(KERN_INFO PFX "%d card%s found\n",
> > +			cards_found, cards_found > 1 ? "s" : "");
> >  
> >  	return (pcnet32_have_pci + cards_found) ? 0 : -ENODEV;
> >  }
> > 
> > -
-- 
Don Fry
brazilnut@us.ibm.com
