From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: act_mirred: Fix bogus header when redirecting from VLAN
Date: Fri, 17 Apr 2015 10:15:01 +0800
Message-ID: <20150417021501.GB22835@gondor.apana.org.au>
References: <20150417010216.GA22415@gondor.apana.org.au>
 <20150417013401.GA4335@Alexeis-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:33385 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbbDQCPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 22:15:04 -0400
Content-Disposition: inline
In-Reply-To: <20150417013401.GA4335@Alexeis-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2015 at 06:34:02PM -0700, Alexei Starovoitov wrote:
> On Fri, Apr 17, 2015 at 09:02:16AM +0800, Herbert Xu wrote:
> > @@ -105,7 +105,7 @@ static void ri_tasklet(unsigned long dev)
> >  		if (from & AT_EGRESS) {
> >  			dev_queue_xmit(skb);
> >  		} else if (from & AT_INGRESS) {
> > -			skb_pull(skb, skb->dev->hard_header_len);
> > +			skb_pull(skb, _dev->hard_header_len);
> ...
> >  	if (!(at & AT_EGRESS)) {
> >  		if (m->tcfm_ok_push)
> > -			skb_push(skb2, skb2->dev->hard_header_len);
> > +			skb_push(skb2, dev->hard_header_len);
> 
> seems the cleaner fix will be to push skb->mac_len instead?

No skb->mac_len is the same as skb2->dev->hard_header_len.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
