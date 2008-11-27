From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 05/39] wimax: debug macros and debug settings for the
	WiMAX stack
Date: Thu, 27 Nov 2008 10:28:08 +0100
Message-ID: <1227778088.3809.13.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <ff25717bf78b6831db361b925f7081d5d6faf876.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-I9W3BrEdU3HZJoS/GdnI"
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59540 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbYK0J24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 04:28:56 -0500
In-Reply-To: <ff25717bf78b6831db361b925f7081d5d6faf876.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-I9W3BrEdU3HZJoS/GdnI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:
> This file contains a simple debug framework that is used in the stack;
                       ^^^^^ ??

> it allows the debug level to be controlled at compile-time (so the
> debug code is optimized out) and at run-time (for what wasn't compiled
> out).

Recently we got new stuff for dynamic printk
(include/linux/dynamic_printk.h) and pr_debug with a start format
(include/linux/kernel.h, pr_fmt); can you use any of that to make this
smaller? If not, I think you ought to argue why not, and possibly
improve the generic facility.

Personally, I'm tired of seeing every Intel driver come with a new huge
set of debugging macros that are barely understandable.

> +#define _d_printf(l, tag, dev, f, a...)					\
> +do {									\
> +	char head[64];							\
> +	if (!d_test(l))							\
> +		break;							\
> +	__d_head(head, sizeof(head), dev);				\
> +	printk(KERN_ERR "%s%s%s: " f, head, __func__, tag, ##a);	\
> +} while (0 && dev)

That && dev is wrong.

johannes

--=-I9W3BrEdU3HZJoS/GdnI
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLmglAAoJEKVg1VMiehFYnOYQAJuhxEFSPuDL816n/LDEgo7t
gnGIPenQI6iE9dsa0ATExBWVxWPT+ydD5rnFSy5FdDfWRwiB11OzD4LzHA4pjnyI
O8RDIjs1/bfGsL+FJyWALtD0nNtuCIpOqoDyWm+bygt+RwoQlqzPdwZzIzQ5yml5
Z1n9BreplLl9G+5Bakd/UcsbNV5wkPNxN2Pz4QznfyQ+ARo7t26PbH+OanR47YtY
MiW7m4JujfrDClCaOLWfGQoai2UH9qU28JL3gaRGxCFaGmxk3vjwGwvjq/K09Bg5
lRtsYSqUICJFgk00XMMACDQwiqzWkY+rbqA4z6QEOS+5/vCXTJDm4A6YUECoW6Dq
2EfpQtFaYHuL27ToS2KVJC6Kt1HGPrTXE9uVzkgKkCvHJnJp6EYYHlW8/5oLLzTF
7cZJLtSQaXX1ifWBSG+R74pjS7YMueA+BXjn4LzkK2BE42Mh3FcIPggEYWlWaOiy
6ZumFLhBtw8tZRJCKSpmK8F/2VVxz3waUCFGaCGMzdoFwEBTjpXE8UTHqo+p2u1X
ZFGUHwjvTun4w4q3MFgAaiuynlvw97rhMUs2MtZKKZW0mscNP5g7OmqqNicYcvTJ
nhHRfzZynNUt94uDNVD40n9cIhVBn95tQ9PyQ/U/TEV+y0o7hgyNwVwK8x9DFyiv
7AQzSTZLJfwtrLVX9lEh
=ABhT
-----END PGP SIGNATURE-----

--=-I9W3BrEdU3HZJoS/GdnI--

