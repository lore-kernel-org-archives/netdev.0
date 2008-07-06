From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net/core: Allow receive on active slaves.
Date: Sat, 05 Jul 2008 21:12:56 -0700 (PDT)
Message-ID: <20080705.211256.121382294.davem@davemloft.net>
References: <1215048127619-git-send-email-fubar@us.ibm.com>
	<1215048128335-git-send-email-fubar@us.ibm.com>
	<486E1B80.7060900@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, jre@nuovasystems.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53333
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750710AbYGFEM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 00:12:56 -0400
In-Reply-To: <486E1B80.7060900@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jgarzik@pobox.com>
Date: Fri, 04 Jul 2008 08:45:52 -0400

> Jay Vosburgh wrote:
> > @@ -2104,7 +2104,8 @@ int netif_receive_skb(struct sk_buff *skb)
> >  #endif
> >  
> >  	list_for_each_entry_rcu(ptype, &ptype_all, list) {
> > -		if (ptype->dev == null_or_orig || ptype->dev == skb->dev) {
> > +		if (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
> > +		    ptype->dev == orig_dev) {
> >  			if (pt_prev)
> >  				ret = deliver_skb(skb, pt_prev, orig_dev);
> >  			pt_prev = ptype;
> > @@ -2129,7 +2130,8 @@ ncls:
> >  	list_for_each_entry_rcu(ptype,
> >  			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
> >  		if (ptype->type == type &&
> > -		    (ptype->dev == null_or_orig || ptype->dev == skb->dev)) {
> > +		    (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
> > +		     ptype->dev == orig_dev)) {
> >  			if (pt_prev)
> 
> This needs a review&ack from David, then OK...

I fear this bit of the changes will break AF_PACKET device binding.
So for example, if a tap registers it wants to hear eth0, it will now
hear bond0 as well as eth0 if eth0 is a part of bond0.
