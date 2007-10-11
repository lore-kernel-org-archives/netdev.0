From: Dave Jones <davej@redhat.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Wed, 10 Oct 2007 20:36:38 -0400
Message-ID: <20071011003638.GA27174@redhat.com>
References: <46FAA083.9020604@intel.com> <E1IanKN-0003ju-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	esandeen@redhat.com, dmack@juniper.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55290 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756659AbXJKAgz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 20:36:55 -0400
Content-Disposition: inline
In-Reply-To: <E1IanKN-0003ju-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 27, 2007 at 02:58:27PM +0800, Herbert Xu wrote:
 > Kok, Auke <auke-jan.h.kok@intel.com> wrote:
 > > Dave Jones wrote:
 > >> Last night, I hit this bug during boot up..
 > >> http://www.codemonkey.org.uk/junk/e100-2.jpg
 > >> 
 > >> This morning, I got a mail from a Fedora user of the same
 > >> .23-rc8 based kernel that has seen a different trace
 > >> also implicating e100..
 > >> 
 > >> http://www.codemonkey.org.uk/junk/e100.jpg
 > >> 
 > >> It may be that the two problems are unrelated, and it's
 > >> just coincidence that both reports happen to be on an e100,
 > >> but the timing is odd.  Have there been other reports
 > >> of similar problems recently ?
 > > 
 > > there hasn't been a change to e100 in two months now - perhaps something slipped
 > > into the stack that broke it? If this reproduces, could you bisect?

So I looked into this some more, after it reared its head again.
The problem with bisecting it is that it doesn't happen on every
boot, so it's difficult to determine the good/bad state.
I've never managed to reproduce it on 2.6.22 however.

 > Well this looks exactly like the e1000 race that we fixed around
 > the time of the last kernel release.  That fix never made it into
 > e100 so it's no surprise that we get a similar crash here.

We're starting to see more reports of this from Fedora users
now that 2.6.23 is final.  Once we push that as an update
for Fedora 7 users, it's likely we'll see even more.
(likewise for the soon-to-be released F8, based on 2.6.23)

The e1000 changes you reference above, is this the changeset you mean?

commit 416b5d10afdc797c21c457ade3714e8f2f75edd9
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Fri Jun 1 10:22:39 2007 -0700

    e1000: disable polling before registering netdevice


 > The problem is that if a spurious interrupt comes in between
 > request_irq and netif_poll_enable then you'll get a crash at
 > the next netif_rx_complete.
 > 
 > It'd be good if this were reproducible as it would allow us
 > to identify the source of the spurious interrupt, which may
 > well be caused by an unrelated bug somewhere else.
 > 
 > In any case, e100 should be prepared to deal with spurious
 > interrupts as e1000 has been fixed to do.

Adding some of the other reporters of this bug to Cc,
in case they've found this more reproducable than myself
(maybe they'll have more luck bisecting).

	Dave

-- 
http://www.codemonkey.org.uk
