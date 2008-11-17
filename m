From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] softirq: Use local_irq_save() in local_bh_enable()
Date: Mon, 17 Nov 2008 15:18:28 +0100
Message-ID: <1226931509.3902.16.camel@johannes.berg>
References: <20081117133548.GC6345@ff.dom.local>
	 (sfid-20081117_143601_411488_D8071C4B)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sXfwD+X/n5h6zbR1vndj"
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Ferenc Wagner <wferi@niif.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59659 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbYKQOSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 09:18:51 -0500
In-Reply-To: <20081117133548.GC6345@ff.dom.local> (sfid-20081117_143601_411488_D8071C4B)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-sXfwD+X/n5h6zbR1vndj
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-11-17 at 13:35 +0000, Jarek Poplawski wrote:
> This report: http://marc.info/?l=3Dlinux-netdev&m=3D122599341430090&w=3D2
> shows local_bh_enable() is used in the wrong context (irqs disabled).
> It happens when a usual network receive path is called by netconsole,
> which simply turns off irqs around this all. Probably this is wrong,
> but it worked like this long time, and it's not trivial to fix this.

Unfortunately my brain lacks the magic to decrypt x86 stack traces, so
I'm unable to read much from that report other than that it hit the
WARN_ON. That looks more like the TX path to me? Anyway, my patch made
that trigger for everybody rather than just on NOPREEMPT/UP (or
something like that) and made the code easier to understand by removing
the flags that are pointless anyway if the API is used correctly.

You can find discussion around the patch at
http://lkml.org/lkml/2008/6/17/259

> Anyway, a commit 0f476b6d91a1395bda6464e653ce66ea9bea7167 "softirq:
> remove irqs_disabled warning from local_bh_enable" can break things
> after changing from local_irq_save() to local_irq_disable(). Before
> this commit there was only a warning, now a lockup is possible, so
> it could be treated as a regression. This patch reverts the change
> in irqs.

Do we have evidence of this actually hitting often? This is the first
report of anything going wrong that I've seen ever since a single one
right after this commit went into testing five months ago.

IFF we want to add this back (and I'm not in favour) then please add a
big comment that this is only to accomodate broken users.

johannes

--=-sXfwD+X/n5h6zbR1vndj
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJIX0uAAoJEKVg1VMiehFYciwQAIxSVCvhKJ6Qz/X30F0smssr
eG0YeihZlN3Ap/+uxqeeXHj5aNP7A2R/oc6l31O/UTPvxz313Fui0RwjN8NfTUvQ
9yRB3BbPoDCCEYEGsEl5or1Ik5EhtW6GO3rDjuSHQYeF5aWxNqXlk69NIgcbg6sg
+JO2fnzYWyM4zkxwdyIo9D3M2wbUM3y72HTXb+ZEcLWfpDmGoxzMPgx3pq+NX8o9
1VdWV2Pz8P3XXeaNC1dx0an8lm2eItur43UXumJWiaTPe6RLmQu03i6RlM0/rAOe
gYM7L+pDFa8W/Zloz5TXxYVO3FDASh7hBB7ZzLC3aE4KB9UNL9I1rqoBmCcEwaHS
POnJ/sAvHJeURziOJBPz/BM2QblWdR24tgYUCyoYpggdDDeLCisVLJjQVXkwpU5W
wag44HG6gc8MXsd2+WXMnTDTR9dqs91E8kV4hor2ir5hdIZ3n15L10vPYU4q8wT1
jNg6Ua1RonbmIQKz9+20d0rSk2MzMwDmGtjUgQ/yCdkqplm3zt4FamprwiQR8OjI
ZCJeGjn4sZcMYT4Kz1PRBuug0yuaHv9/nBuS4k9MbnaWSo/O/TqhHH24d9kTlF41
w03YMLk0ySXiyQJJkU7FF3Dz3//lWN+8yx+VLEcM7/IIOboGSCD1lq6PZXPijzn3
hDYp7bv/6OcW3LXqZZYw
=xUvE
-----END PGP SIGNATURE-----

--=-sXfwD+X/n5h6zbR1vndj--

