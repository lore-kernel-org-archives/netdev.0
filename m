From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 4/7] lib/inet_proto: Make sure destination
 buffers are NULL-terminated
Date: Fri, 18 Aug 2017 18:55:20 +0200
Message-ID: <20170818165520.GE16375@orbyte.nwl.cc>
References: <20170817170932.24659-1-phil@nwl.cc>
 <20170817170932.24659-5-phil@nwl.cc>
 <20170818093734.705f6742@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52251 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751052AbdHRQzV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 12:55:21 -0400
Content-Disposition: inline
In-Reply-To: <20170818093734.705f6742@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 18, 2017 at 09:37:33AM -0700, Stephen Hemminger wrote:
> On Thu, 17 Aug 2017 19:09:29 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >  lib/inet_proto.c | 9 ++++++---
> >  1 file changed, 6 insertions(+), 3 deletions(-)
> > 
> > diff --git a/lib/inet_proto.c b/lib/inet_proto.c
> > index ceda082b12a2e..87ed4769fc3da 100644
> > --- a/lib/inet_proto.c
> > +++ b/lib/inet_proto.c
> > @@ -35,8 +35,10 @@ const char *inet_proto_n2a(int proto, char *buf, int len)
> >  	pe = getprotobynumber(proto);
> >  	if (pe) {
> >  		icache = proto;
> > -		strncpy(ncache, pe->p_name, 16);
> > -		strncpy(buf, pe->p_name, len);
> > +		strncpy(ncache, pe->p_name, 15);
> > +		ncache[15] = '\0';
> > +		strncpy(buf, pe->p_name, len - 1);
> > +		buf[len] = '\0';
> >  		return buf;
> >  	}
> >  	snprintf(buf, len, "ipproto-%d", proto);
> > @@ -62,7 +64,8 @@ int inet_proto_a2n(const char *buf)
> >  	pe = getprotobyname(buf);
> >  	if (pe) {
> >  		icache = pe->p_proto;
> > -		strncpy(ncache, pe->p_name, 16);
> > +		strncpy(ncache, pe->p_name, 15);
> > +		ncache[15] = '\0';
> >  		return pe->p_proto;
> >  	}
> >  	return -1;
> 
> Depending on proto name to be 15 characters or less is a silly
> choice. Why not use strdup() and do it right?

Yes, I was puzzled by that as well. Luckily the longest proto name in my
/etc/protocols is rsvp-e2e-ignore which is 15 chars long. I'll change
the patch to use dynamic allocation.

Thanks, Phil
