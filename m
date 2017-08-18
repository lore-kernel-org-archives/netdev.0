From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 4/5] tc/tc_filter: Make sure filter name is
 not empty
Date: Fri, 18 Aug 2017 18:57:05 +0200
Message-ID: <20170818165705.GF16375@orbyte.nwl.cc>
References: <20170817170931.24545-1-phil@nwl.cc>
 <20170817170931.24545-5-phil@nwl.cc>
 <063D6719AE5E284EB5DD2968C1650D6DD005A7E9@AcuExch.aculab.com>
 <20170818111613.GH10864@orbyte.nwl.cc>
 <063D6719AE5E284EB5DD2968C1650D6DD005AE0E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36373 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750812AbdHRQ5G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 12:57:06 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD005AE0E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 18, 2017 at 04:34:44PM +0000, David Laight wrote:
> From: Phil Sutter
> > Sent: 18 August 2017 12:16
> > On Fri, Aug 18, 2017 at 09:30:35AM +0000, David Laight wrote:
> > > From: Phil Sutter
> > > > Sent: 17 August 2017 18:10
> > > > The later check for 'k[0] != 0' requires a non-empty filter name,
> > > > otherwise NULL pointer dereference in 'q' might happen.
> > > >
> > > > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > > > ---
> > > >  tc/tc_filter.c | 3 +++
> > > >  1 file changed, 3 insertions(+)
> > > >
> > > > diff --git a/tc/tc_filter.c b/tc/tc_filter.c
> > > > index b13fb9185d4fd..a799edb35886d 100644
> > > > --- a/tc/tc_filter.c
> > > > +++ b/tc/tc_filter.c
> > > > @@ -412,6 +412,9 @@ static int tc_filter_get(int cmd, unsigned int flags, int argc, char **argv)
> > > >  			usage();
> > > >  			return 0;
> > > >  		} else {
> > > > +			if (!strlen(*argv))
> > > > +				invarg("invalid filter name", *argv);
> > >
> > > That is nearly as bad as:
> > > 	p[strlen(p)] = 0;
> > 
> > Hey, it's not impossible! I could call tc like so:
> > 
> > | # tc filter get protocol ip prio 1 ""
> 
> You missed the point. Just check **argv there is no need to
> determine the length just to check it is non-zero.

Oh, hehe. Thanks for the short-cut!

Thanks, PHil
