From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 6/6] tg3: Make the RSS indir tbl admin
 configurable
Date: Thu, 15 Dec 2011 23:43:47 +0000
Message-ID: <1323992628.2773.22.camel@bwh-desktop>
References: <1323897002-17295-7-git-send-email-mcarlson@broadcom.com>
	 <1323899459.2753.19.camel@bwh-desktop>
	 <20111215210308.GA7025@mcarlson.broadcom.com>
	 <1323983627.2773.18.camel@bwh-desktop>
	 <20111215233712.GA7371@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25759 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759690Ab1LOXn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 18:43:56 -0500
In-Reply-To: <20111215233712.GA7371@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-12-15 at 15:37 -0800, Matt Carlson wrote:
> On Thu, Dec 15, 2011 at 01:13:47PM -0800, Ben Hutchings wrote:
> > On Thu, 2011-12-15 at 13:03 -0800, Matt Carlson wrote:
> > > On Wed, Dec 14, 2011 at 01:50:59PM -0800, Ben Hutchings wrote:
> > > > On Wed, 2011-12-14 at 13:10 -0800, Matt Carlson wrote:
> > [...]
> > > > > +	if (!indir->size) {
> > > > > +		indir->size = TG3_RSS_INDIR_TBL_SIZE;
> > > > > +		return 0;
> > > > > +	}
> > > > > +
> > > > > +	if (indir->size != TG3_RSS_INDIR_TBL_SIZE)
> > > > > +		return -EINVAL;
> > > > 
> > > > This is enough to make the ethtool command work, but you're really
> > > > supposed to copy min(indir->size, TG3_RSS_INDIR_TBL_SIZE) entries.
> > > 
> > > Could you elaborate on this?  I'm confused because I can't figure out
> > > how returning half of an indirection table could be useful.
> > 
> > It's a generalisation of the zero-length and full-length cases.  But no,
> > it isn't very useful, nor did I actually specify that anywhere!
> > 
> > Maybe there should be a driver operation to get the table size, and then
> > the core can make sure that drivers only ever deal with full-table
> > buffers.  Though that wouldn't cover your reset-to-default case.
> 
> That's how your current implementation of ethtool works, doesn't it?  It
> first makes a call to get_rxfh_indir() with a zero size parameter.  The
> driver interprets this as a query for the size of the driver's
> indirection table.  Subsequent calls to get_rxfh_indir() with a non-zero
> size are interpreted as a request for the indirection table data.

Yes, and I think it's fine if we restrict input that way.

> Right now, I coded get_rxfh_indir() and set_rxfh_indir() to be strict in
> what they accept.  The restrictions can be relaxed though if we can
> outline what the driver should do with partial tables.  (I wonder if
> these types of interpretations are better placed above the driver
> though.

I agree; stand by for patches.

> Then again, maybe not.  Tg3 devices can tune the size of the
> indirection table by powers of two if needed at the cost of a reset.)

You can achieve the same effect repeating the entries of the smaller
table multiple times.

> But IMO all these ideas make the reset-to-default case more desirable.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
