From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 01:39:49 +0200
Message-ID: <200706230139.50064.mb@bu3sch.de>
References: <c6d9bea0706221626h434d17d0l6dc3a6a513601546@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "C. Scott Ananian" <cscott@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:53091
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545AbXFVXkr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 19:40:47 -0400
In-Reply-To: <c6d9bea0706221626h434d17d0l6dc3a6a513601546@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 23 June 2007 01:26:19 C. Scott Ananian wrote:
> Attached is my first draft of a patch to implement RDNSS-in-Router
> Advertisements support for IPv6 (
> http://tools.ietf.org/html/draft-jeong-dnsop-ipv6-dns-discovery-12 )
> as implemented in radvd ( http://www.litech.org/radvd/ ).  It
> currently exports the autoconfigured DNS list as /proc/net/ipv6_dns -=
-
> ultimately it ought to (a) implement inotify on this file, so that
> glibc could use it like /etc/resolv.conf and get notifications when
> the DNS list changes, and (b) export the DNS list via netlink as well=
=2E
>=20
> Comments & discussion, please!
>  --scott

> diff -ruHpN -X dontdiff linux-2.6.22-rc5-orig/include/net/ip6_rdnss.h
> linux-2.6.22-rc5/include/net/ip6_rdnss.h
> --- linux-2.6.22-rc5-orig/include/net/ip6_rdnss.h=A0=A0=A0=A0=A0=A0=A0=
1969-12-31
> 19:00:00.000000000 -0500
> +++ linux-2.6.22-rc5/include/net/ip6_rdnss.h=A0=A0=A0=A02007-06-21
> 18:16:33.000000000 -0400 @@ -0,0 +1,58 @@
> +#ifndef _NET_IP6_RDNSS_H
> +#define _NET_IP6_RDNSS_H
> +
> +#ifdef __KERNEL__
> +
> +#include <linux/in6.h>
> +
> +struct nd_opt_rdnss {
> +=A0=A0=A0=A0=A0=A0=A0__u8=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0type;
> +=A0=A0=A0=A0=A0=A0=A0__u8=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0length;
> +#if defined(__BIG_ENDIAN_BITFIELD)
> +=A0=A0=A0=A0=A0=A0=A0__u8=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0priority:4,
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0open:1,
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0reserved1:3;
> +#elif defined(__LITTLE_ENDIAN_BITFIELD)
> +=A0=A0=A0=A0=A0=A0=A0__u8=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0reserved1:3,
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0open:1,
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0priority:4;
> +#else
> +# error not little or big endian
> +#endif

That is not endianess-safe. Don't use foo:x at all
for stuff where a specific endianess is needed. The
compiler doesn't make any guarantee about it.

Please do
__u8 flags;
#define FOOBAR_RESERVED	0x07
#define FOOBAR_OPEN	0x08
#define FOOBAR_PRIORITY	0xF0
=2E...
and use them in the code.

In general I try to avoid the foo:x stuff, as it
has little or no gain. It just generates worse code.

--=20
Greetings Michael.
