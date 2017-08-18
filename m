From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 1/7] ipntable: Make sure filter.name is
 NULL-terminated
Date: Fri, 18 Aug 2017 12:52:24 +0200
Message-ID: <20170818105224.GG10864@orbyte.nwl.cc>
References: <20170817170932.24659-1-phil@nwl.cc>
 <20170817170932.24659-2-phil@nwl.cc>
 <063D6719AE5E284EB5DD2968C1650D6DD005A7B4@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:55683 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750923AbdHRKwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 06:52:25 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD005A7B4@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Fri, Aug 18, 2017 at 09:19:16AM +0000, David Laight wrote:
> From: Phil Sutter
> > Sent: 17 August 2017 18:09
> > To: Stephen Hemminger
> > Cc: netdev@vger.kernel.org
> > Subject: [iproute PATCH v2 1/7] ipntable: Make sure filter.name is NULL-terminated
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >  ip/ipntable.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/ip/ipntable.c b/ip/ipntable.c
> > index 879626ee4f491..7be1f04d33d90 100644
> > --- a/ip/ipntable.c
> > +++ b/ip/ipntable.c
> > @@ -633,7 +633,8 @@ static int ipntable_show(int argc, char **argv)
> >  		} else if (strcmp(*argv, "name") == 0) {
> >  			NEXT_ARG();
> > 
> > -			strncpy(filter.name, *argv, sizeof(filter.name));
> > +			strncpy(filter.name, *argv, sizeof(filter.name) - 1);
> > +			filter.name[sizeof(filter.name) - 1] = '\0';
> 
> Why not check for overflow instead?
> 			if (filter.name[sizeof(filter.name) - 1])
> 				usage("filer name too long");

sizeof(filter.name) is 1024, which is maybe a bit over the top for
something a user would input. So I found a better way avoiding all this
at once: I made filter.name a const char *, then just assigned *argv to
it. This should be safe since rtnl_dump_filter() and therefore
print_ntable() callback is called from inside ipntable_show() so *argv
is not accessed outside of it's scope.

What do you think?

Thanks, Phil
