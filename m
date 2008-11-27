From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 02/39] wimax: declarations for the in-kernel WiMAX API
Date: Thu, 27 Nov 2008 10:32:03 +0100
Message-ID: <1227778323.3809.19.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <68881c1af06f352dc457485c208662a8db62f3fe.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ULbUdR3hUcL3Eo6KDbGZ"
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:38515 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbYK0Jcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 04:32:50 -0500
In-Reply-To: <68881c1af06f352dc457485c208662a8db62f3fe.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ULbUdR3hUcL3Eo6KDbGZ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:

> + * NOTE: this versioning is a last resort to avoid hard
> + *    incompatibilities. It is the intention of the design of this
> + *    stack not to introduce backward incompatible changes.
> + *
> + * The version code has to fit in one byte (restrictions imposed by
> + * generic netlink); we use `version / 10` for the major version and
> + * `version % 10` for the minor. This gives 9 minors for each major
> + * and 25 majors.
> + *
> + * The version change protocol is as follow:
> + *
> + * - Major versions: needs to be increased if an existing message/API
> + *   call is changed or removed. Doesn't need to be changed if a new
> + *   message is added.
> + *
> + * - Minor verion: needs to be increased if new messages/API calls are

small typo there

> + *   being added or some other consideration that doesn't impact the
> + *   user-kernel interface too much (like some kind of bug fix) and
> + *   that is kind of left up in the air to common sense.
> + *
> + * User space code should not try to work if the major version it was
> + * compiled for differs from what the kernel offers. As well, if the
> + * minor version of the kernel interface is lower than the one user
> + * space is expecting (the one it was compiled for), the kernel
> + * might be missing API calls; user space shall be ready to handle
> + * said condition.
> + *
> + * libwimax:wimax_open() takes care of checking versions.

Why bother versioning the API? Since this is generic netlink, and things
are looked up by the family name, a completely new version would just
use a new family name and be done with it, old userspace won't even
_find_ that new "version" of the API. The "minor version" seems also
useless, either you can do the change in a backward compatible way or
you cannot and need to provide compat code.

I'd just remove this.

johannes

--=-ULbUdR3hUcL3Eo6KDbGZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLmkPAAoJEKVg1VMiehFYdRUP+wb4bxx4FCwxvk1odAjUbOfQ
6baQ48op99kN7ysbGLJ6mUg+vKWgCkb6aIdTFhFBkgeco9fjzTYCJjVwD2ZH5+pn
keh48bpri8ziFSpYJ7fjLhZNozGTnMtz722evtf9DI2+Z2/g7i6UMDeEbPMGo3aZ
+gQluUGHjYQp6+LgznfyMupR4uLbVU2M74Z9ZbzrJjZ3kAiTqyHZ73EAszF+4g8b
cbjPEOJiavR78VHVxP2Dol40hrxNNhCQWsbCQMWsxAeLf35ndksRGotutKyyMHRY
MepIKnXQURKCduZbvumh54e1bzK21quIk9okNEv+nMG21V8IuGQ//MGMaUkmRHxd
iOJj1hdtxiMg/AOtO2u2G772RzP2V6mGgJBdxZyZHikY7gCTMhBmo3LFi/KJ40kK
/GsrfHlWTlqxPTAL9MijF1+fGJb+Zm2YNuadjYFzEcdzj2UHuJwOMJqJC8BxId5o
8jBk2DvyIpsMd6d3FDTsJ7OpK0qqKzfHxit0bw1Rrzk0WBQdUjdyAExMVqixHOym
lKdkMz7taLg6X6BB3Xz+xhv6az1L49Li8Id/l0jQf2yLr2nyz8tTgzCk36aECxuG
iG7i+a/Y3a0vbciC4xC84CEvDQ4T1HzAcbpBIyUlTqmS2LFC4X+Es1MmT/+Bj348
Wkzoxh25jEuaXlquDX/6
=1366
-----END PGP SIGNATURE-----

--=-ULbUdR3hUcL3Eo6KDbGZ--

