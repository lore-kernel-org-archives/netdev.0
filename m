From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v3 4/5] tc/tc_filter: Make sure filter name is
 not empty
Date: Mon, 21 Aug 2017 19:15:47 +0200
Message-ID: <20170821171546.GA15994@orbyte.nwl.cc>
References: <20170821100308.24854-1-phil@nwl.cc>
 <20170821100308.24854-5-phil@nwl.cc>
 <063D6719AE5E284EB5DD2968C1650D6DD005CC54@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60681 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753446AbdHURPs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 13:15:48 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD005CC54@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 02:53:46PM +0000, David Laight wrote:
> From: Phil Sutter
> > Sent: 21 August 2017 11:03
> > To: Stephen Hemminger
> > Cc: netdev@vger.kernel.org
> > Subject: [iproute PATCH v3 4/5] tc/tc_filter: Make sure filter name is not empty
> > 
> > The later check for 'k[0] != 0' requires a non-empty filter name,
> > otherwise NULL pointer dereference in 'q' might happen.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> > Changes since v2:
> > - Instead of calling strlen(), just make sure **argv is not 0.
> > ---
> >  tc/tc_filter.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/tc/tc_filter.c b/tc/tc_filter.c
> > index b13fb9185d4fd..cf290ae8e252c 100644
> > --- a/tc/tc_filter.c
> > +++ b/tc/tc_filter.c
> > @@ -412,6 +412,9 @@ static int tc_filter_get(int cmd, unsigned int flags, int argc, char **argv)
> >  			usage();
> >  			return 0;
> >  		} else {
> > +			if (!**argv)
> > +				invarg("invalid filter name", *argv);
> > +
> 
> The error message won't make sense...

Hmm. It would print:

| Error: argument "" is wrong: invalid filter name

Since this parameter is not introduced by a previous one, I don't think
the error message could be made more precise. Do you have a better
suggestion?

Thanks, Phil
