From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [mISDN PATCH v2 09/19] Fix TEI and SAPI handling
Date: Sun, 24 May 2009 01:10:22 +0200
Message-ID: <20090523231022.GA13203@uranus.ravnborg.org>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de> <cbbb2723784ecf04bcec253c547a9464a2e722c7.1243024967.git.kkeil@pingi.linux-pingi.de> <20090522215314.GA4592@uranus.ravnborg.org> <200905231500.38092.keil@b1-systems.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: Karsten Keil <keil@b1-systems.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepa.post.tele.dk ([195.41.46.235]:42463 "EHLO
	pfepa.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732AbZEWXIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2009 19:08:09 -0400
Content-Disposition: inline
In-Reply-To: <200905231500.38092.keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >
> > Unrealted to this specific patch...
> > Are there any specific reason why mISDN prefer bsd style (u_int)
> > rather then linux style (u32)?
> 
> No, this was some historic process with the ISDN code.
> I think, if we want change this we should make a separate  patch to change 
> this in all mISDN code later, I usually prefer shorter type names as well :-).
> So as rule of dumb:
> - Use   uN/sN for all values with constant width N ?
yes

> What should be used on functions which are usually defined as int and
> only return 0 or some negative ERROR code, I think int should be OK here ?
yes - use int here.

> > >  static struct layer2 *
> > > -create_new_tei(struct manager *mgr, int tei)
> > > +create_new_tei(struct manager *mgr, int tei, int sapi)
> > >  {
> >
> > Here tei and sapi are passed as signed.
> > But valid sapi range is [0..63] and tei [0..127].
> > And create_l2 above uses unsigned.
> >
> > This looks confusing.
> 
> I think the signed was selected for error handling, but you are correct then 
> it should be the same in all functions.
The correct values are the range [0..127] so as you also imply
reserving all negative values for error codes seems like the best choice.

So as a matter of consistency you should use int for tei/sapi all over.
> >
> > So get_free_tei() may return a negative value indicating no free tei.
> > So that make my comment above void - but is this really the best way
> > to return an error. Possibly it is..
> >
> We could define 255 as the error value, I will think about this, but in 
> general I prefer negative values for error cases.

Addressed above - agree.

> > >  	if (!(skb->data[1] & 1)) /* invalid EA1 */
> > >  		return -EINVAL;
> > > -	tei = skb->data[1] >> 0;
> > > +	tei = skb->data[1] >> 1;
> >
> > This looks like a bug-fix...
> >
> 
> Yes,  I think fixed TEI was never tested with P2MP,  I know
> no device which really use it with SAPI 0, only in P2P we use a
> fixed TEI  of 0.  Also the test suite used by certifications did
> not check for correct fixed TEI handling, it only checks that a
> fixed TEI is rejected in a dynamic TEI assignment.
> With SAPI != 0 fixed TEIs are more common, so the bug was
> detected now.
Yep - I know we used fixed tei in ptmp configuration
for sapi=16 (packet handling aka X.25 over ISDN).

	Sam
