From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 11:07:14 +0200
Message-ID: <200706231107.14649.mb@bu3sch.de>
References: <c6d9bea0706221626h434d17d0l6dc3a6a513601546@mail.gmail.com> <200706230139.50064.mb@bu3sch.de> <c6d9bea0706221709h72dfa5bao7f51d4a611950094@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "C. Scott Ananian" <cscott@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49103
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987AbXFWJII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 05:08:08 -0400
In-Reply-To: <c6d9bea0706221709h72dfa5bao7f51d4a611950094@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 23 June 2007 02:09:18 C. Scott Ananian wrote:
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

Yeah, it might work. But I think the compiler doesn't guarantee
you anything about it.

-- 
Greetings Michael.
