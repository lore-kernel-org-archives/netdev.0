From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] ip-route: Pretty-print expired routes
Date: Thu, 11 Aug 2016 15:54:50 +0200
Message-ID: <20160811135450.GC10197@orbyte.nwl.cc>
References: <1470827690-5625-1-git-send-email-phil@nwl.cc>
 <9d2afc01-bb48-25f7-9cad-7c4926622a38@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:38556 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932162AbcHKNzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2016 09:55:04 -0400
Content-Disposition: inline
In-Reply-To: <9d2afc01-bb48-25f7-9cad-7c4926622a38@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 11, 2016 at 02:46:26PM +0100, Edward Cree wrote:
> On 10/08/16 12:14, Phil Sutter wrote:
> > Instead of printing 'expires -23sec' for expired (but not yet garbage
> > collected) routes, print 'expired 23sec' instead.
> >
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >  ip/iproute.c | 12 ++++++++++--
> >  1 file changed, 10 insertions(+), 2 deletions(-)
> >
> > diff --git a/ip/iproute.c b/ip/iproute.c
> > index c52294d298210..a89a26d68be0f 100644
> > --- a/ip/iproute.c
> > +++ b/ip/iproute.c
> > @@ -305,6 +305,14 @@ static void print_rtax_features(FILE *fp, unsigned int features)
> >               fprintf(fp, " 0x%x", of);
> >  }
> >
> > +static void print_expires(FILE *fp, __s32 expires, int hz)
> > +{
> > +     if (expires > 0)
> > +             fprintf(fp, " expires %dsec", expires/hz);
> > +     else
> > +             fprintf(fp, " expired %dsec", -expires/hz);
> > +}
> Perhaps something that differs by more than a single character, to
> make it stand out more?  I don't know what to suggest, though.

Yes, I thought about that, too. At first, I had "expired for %dsec" for
the second case, but decided that it was a bit too verbose given that
all route info goes into a single line and is still meant to be
human-readable. :)

Cheers, Phil
