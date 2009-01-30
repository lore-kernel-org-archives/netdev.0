From: David Miller <davem@davemloft.net>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Thu, 29 Jan 2009 16:13:13 -0800 (PST)
Message-ID: <20090129.161313.249939766.davem@davemloft.net>
References: <497EA5B5.5090806@cs.wisc.edu>
	<46A00B48CC54E4468EF6911F877AC4CA01EF2BC9@blrx3m10.blr.amer.dell.com>
	<20090128212526.GA22141@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Shyam_Iyer@Dell.com, michaelc@cs.wisc.edu,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	olaf.kirch@oracle.com, tgraf@suug.ch, kkeil@suse.de
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60669
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753310AbZA3ANQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 19:13:16 -0500
In-Reply-To: <20090128212526.GA22141@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 29 Jan 2009 08:25:26 +1100

> On Wed, Jan 28, 2009 at 05:47:57PM +0530, Shyam_Iyer@Dell.com wrote:
> > 
> > --- skbuff.c.orig	2009-01-29 01:12:03.000000000 +0530
> > +++ skbuff.c	2009-01-29 01:34:57.000000000 +0530
> > @@ -2039,15 +2039,15 @@
> >  		st->frag_data = NULL;
> >  	}
> >  
> > -	if (st->cur_skb->next) {
> > -		st->cur_skb = st->cur_skb->next;
> > -		st->frag_idx = 0;
> > -		goto next_skb;
> > -	} else if (st->root_skb == st->cur_skb &&
> > +	if (st->root_skb == st->cur_skb &&
> >  		   skb_shinfo(st->root_skb)->frag_list) {
> >  		st->cur_skb = skb_shinfo(st->root_skb)->frag_list;
> >  		st->frag_idx=0;
> >  		goto next_skb;
> > +	} else if (st->cur_skb->next) {
> > +		st->cur_skb = st->cur_skb->next;
> > +		st->frag_idx = 0;
> > +		goto next_skb;
> >  	}
> >  
> >  	return 0;
> 
> Good catch!
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Excellent work everyone.  I applied both Herbert's and
Shyam's patches, and will queue them up for -stable as well.

Thanks again.
