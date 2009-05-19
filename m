From: Johannes Berg <johannes@sipsolutions.net>
Subject: rfkill vs. interface up
Date: Tue, 19 May 2009 14:32:11 +0200
Message-ID: <1242736331.4797.22.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-DcT14V4cUFljtJ6g06FB"
Cc: Dan Williams <dcbw@redhat.com>, netdev <netdev@vger.kernel.org>
To: linux-wireless <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:53010 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753518AbZESNXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 09:23:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DcT14V4cUFljtJ6g06FB
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

More thoughts on rfkill ...

So we were thinking it would be sensible to just force interfaces down
on rfkill, which is of course possible, and then reject attempts to set
the interface UP while killed.

There's just one problem with that -- when you un-rfkill, does the
kernel set interfaces UP again?

If not -- how would we possibly handle 'iwconfig .. txpower off'? We're
mostly handling it like rfkill now afaict, but 'iwconfig .. txpower on'
wouldn't be able to do anything properly.

If yes -- how do we know which interfaces to set UP? However we turn it,
userspace can then not disable an interface regardless of rfkill state,
which gets really confusing.

Therefore, I don't think we can simply set interfaces down on rfkill
with the current scheme.

On the other hand, the interfaces really are dysfunctional in rfkill and
we really need more integration.


I'm happy to give up on 'iwconfig wlan0 txpower on/off' entirely, simply
refuse supporting it (return -EINVAL if txpower.disabled) and then use
the first scheme where rfkill forces the interface down but userspace is
responsible for enabling it again. This is asymmetric, but I don't see
what else to do.

Thoughts?

johannes


--=-DcT14V4cUFljtJ6g06FB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKEqbHAAoJEODzc/N7+QmaW34QAMSMsHgafIsRF4ighIgVkmID
Xk3YrnQe+yNbYTktqIi3zAIxDuE9pdXhZ5o4WSkjfS+eyxpLi4zbCH4ra8i1L4ZI
cPhyubJEEef/VP7y1msyj1FZPoV2M7apgrfVl5uH9/yc7lfstujIshSZx9iIDYJd
zAebXPqSY5G3C4xQbwFD5TJc4RUEsk7ILxOfW8Qe/E0hZ8jH1JD5rp+nc2gsUxEW
XoE/IiU7+L5UfP3SdHOUSmV/sWl2b3R4IIwVhzSbTCZVbvtE0twZ0bVNpyWmIRw4
6HWcJll6uUuTUHdJbPK3YFKbSI3w7lYUGbBnXTpTmhKAQjJxPva5lyd0xuNC7aE/
8fEeucvX4v6/105YaIYIkCsBTeujPz4BF+CzGgUO250K30Fm/fg7122hdGCdNu4b
+/T8R74D3rFN6lPEjt8+QkGCG7fSNnktNIamwNmQhxVpTsLIhjEdqqAfE+Bt5sDv
qJyt0A70VHVfATxC/TDTt9aZ8lmqKwGN63PT6ozzvEH5P0XaodOoUNjWrq4nwzOQ
gKhCWakfjJ3tKfbbJv+w+xrkrkiNtKMw9q1nb76e+Scw4yMgmIlu7dZ27AWhN+Em
yMy0Y1LVYwkkPKjefrKINkS7FLHcjkLKN6kNMP4eXNrznzBESDZ5JPIX65LEPVke
hNUfjFmh+PIsDUBpy5S7
=VkvC
-----END PGP SIGNATURE-----

--=-DcT14V4cUFljtJ6g06FB--

