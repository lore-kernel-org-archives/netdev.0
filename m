From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS
	autoconfiguration
Date: Fri, 22 Jun 2007 22:11:39 -0400
Message-ID: <1182564699.23976.7.camel@xo-13-A4-25.localdomain>
References: <c6d9bea0706221626h434d17d0l6dc3a6a513601546@mail.gmail.com>
	 <200706230139.50064.mb@bu3sch.de>
	 <c6d9bea0706221709h72dfa5bao7f51d4a611950094@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org
To: "C. Scott Ananian" <cscott@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44513 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824AbXFWCHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 22:07:07 -0400
In-Reply-To: <c6d9bea0706221709h72dfa5bao7f51d4a611950094@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-06-22 at 20:09 -0400, C. Scott Ananian wrote:
> > > diff -ruHpN -X dontdiff linux-2.6.22-rc5-orig/include/net/ip6_rdnss.h
> > > linux-2.6.22-rc5/include/net/ip6_rdnss.h
> > > --- linux-2.6.22-rc5-orig/include/net/ip6_rdnss.h1969-12-31
> > > 19:00:00.000000000 -0500
> > > +++ linux-2.6.22-rc5/include/net/ip6_rdnss.h2007-06-21
> > > 18:16:33.000000000 -0400 @@ -0,0 +1,58 @@
> > > +#ifndef _NET_IP6_RDNSS_H
> > > +#define _NET_IP6_RDNSS_H
> > > +
> > > +#ifdef __KERNEL__
> > > +
> > > +#include <linux/in6.h>
> > > +
> > > +struct nd_opt_rdnss {
> > > +__u8type;
> > > +__u8length;
> > > +#if defined(__BIG_ENDIAN_BITFIELD)
> > > +__u8priority:4,
> > > +open:1,
> > > +reserved1:3;
> > > +#elif defined(__LITTLE_ENDIAN_BITFIELD)
> > > +__u8reserved1:3,
> > > +open:1,
> > > +priority:4;
> > > +#else
> > > +# error not little or big endian
> > > +#endif
> >
> > That is not endianess-safe. Don't use foo:x at all
> > for stuff where a specific endianess is needed. The
> > compiler doesn't make any guarantee about it.
> 
> This was copied directly from include/net/ip6_route.h.  I believe that
> it does in fact work, and I (for one) find this much more readable
> than the alternative.  If it is in fact broken, then
> include/net/ip6_route.h (and the 35 other files which use this #ifdef
> in this manner) should be fixed.

Though in general, we shouldn't be using bitfields, FYI.  They are known
to generate really crappy code on many architectures, and patches that
contain them have been smacked down quite hard by people we all know are
better hackers than us :)

Dan


