From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 08/18] ss: Turn generic_proc_open() wrappers
 into macros
Date: Mon, 5 Dec 2016 18:24:32 +0100
Message-ID: <20161205172432.GO21576@orbyte.nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
 <20161202104002.17310-9-phil@nwl.cc>
 <063D6719AE5E284EB5DD2968C1650D6DB0235052@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48658 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751100AbcLERYe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 12:24:34 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0235052@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 05, 2016 at 05:02:20PM +0000, David Laight wrote:
> From: Phil Sutter
> > Sent: 02 December 2016 10:40
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >  misc/ss.c | 89 ++++++++++++++-------------------------------------------------
> >  1 file changed, 19 insertions(+), 70 deletions(-)
> > 
> > diff --git a/misc/ss.c b/misc/ss.c
> > index ad38eb97b0055..71040a82ca6b1 100644
> > --- a/misc/ss.c
> > +++ b/misc/ss.c
> > @@ -327,76 +327,25 @@ static FILE *generic_proc_open(const char *env, const char *name)
> > 
> >  	return fopen(p, "r");
> >  }
> > -
> > -static FILE *net_tcp_open(void)
> > -{
> > -	return generic_proc_open("PROC_NET_TCP", "net/tcp");
> > -}
> ...
> > +#define net_tcp_open()		generic_proc_open("PROC_NET_TCP", "net/tcp")
> ...
> 
> Does that make any difference at all?
> The compiler should inline the static functions.

Probably, yes. My motivation behind it was merely the reduced LoC (and
maybe the improved clarity how these are really just wrappers, but
that's personal preference I guess).

Cheers, Phil
