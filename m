From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: wireless netns work
Date: Thu, 18 Jun 2009 14:35:43 +0200
Message-ID: <1245328543.13790.31.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-HlqO3EB7v0BqmDxVqv5A"
Cc: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-HlqO3EB7v0BqmDxVqv5A
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

You've all seen the netns patches fly by -- time to explain what I'm
doing maybe?

First, I've not copied all patches to both lists, please look at
http://johannes.sipsolutions.net/patches/kernel/all/LATEST/ for all the
patches with netns in their name, as there are:

## netns work [sent]
006-wext-netns.patch
007-netns-rcu.patch
008-genl-netns.patch
009-mac80211-netns.patch
010-netns-export-get-by-pid.patch

## netns work [rfc]
011-cfg80211-netns.patch

## play together
012-mac80211-allow-netns.patch

## HACK HACK HACK
013-mac80211-no-netdev-dev.patch


Also, to play with it you will need the netns branch of iw, which has
this simple commit:
http://git.sipsolutions.net/gitweb.cgi?p=3Diw.git;a=3Dcommitdiff;h=3D518d40=
92312a8b02bdb49163ae403de7abc9bdee

Also grab ns_exec and compile it:
http://johannes.sipsolutions.net/files/ns_exec.c.txt

Now compile your kernel with all the above patches (including the HACK
one) and let's play:

# modprobe mac80211_hsim

open a new terminal, and in it do
# ns_exec -c -n /bin/bash
and note the PID. In the new shell, also do
# ip link set lo up

Then in the old terminal, do
# iw phy#0 set netns PID-from-above

You'll get a sysfs complaint. Now, in the old terminal:
# ip addr add 192.168.12.1/24 dev wlan1
and in the new netns terminal:
# ip addr add 192.168.12.2/24 dev wlan0

Now you can run hostapd on one of them and connect to the other. This
bit works fine. Once the link is established, you _should_ also be able
to ping between the two, but that doesn't work.

Oddly, the link works unidirectionally in both directions, if I ping
from either side tcpdump shows the echo requests on the other side, but
no echo reply is being generated. Still investigating why this is, since
it works fine with veth. Ideas why this is broken would be
appreciated :)

(and to play with veth, do
# ip link add type veth
# ip link set veth0 netns <PID>
# ip addr add ...
)

johannes

--=-HlqO3EB7v0BqmDxVqv5A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKOjScAAoJEODzc/N7+QmaC/gQAKsC9/uHH6KxCJ1nsCYuzcUD
E137VKmbtHcGPxTLsUOp/GxiV3Oz9HrYUX3cKCwm3BdrTHjR8I/tOfdL+hdcETVe
MDmBIndpo4Oy9v9S1ndlfGt77rek8cIq/1XruvAWldbFOJ7JqBUWKPOG9N15JYoh
gFBo78MC9h/9W0O/MVpyWiTX4W3w41ncvVbSypqbMr5lRhOLt7jXRY9kKRohGr31
BS4zi9KKoed3CEwcZ5ksqV1BaTP8HJyhhMEjp14E6YeTNNl82eUa1wBeWFIAGE/4
wknx6bi3YI2SlaOII5/6nuY0iJHyvIkVC7pzuLZVjzinAYG2JKJzVSLKU6ZRBd6G
tQmBFBeCxyweNWIuVZODBzYc+8im5K+FM6+gx7RpMv6f/oIec7ajSTzXpQs6+q+G
Zza2VFbSrOvuyzK1nANxLdqYKZygXkCXhx5qe2L6LI03S5gy5okjJaSXZpuQMH18
TkZC5HQIhkhjEr9+RXYjdvVPciobVzJd7lH/7ZXQlAJ0ZWrhTPYxphUD5rGUft+v
887zwbVhCycR1b2rjPXZ/cwyLIWgRU/JTXvfRV21EWswn9pCl5ejl0C8pGK8l2h1
vKXLS71HdbxIghfpO3ryzB0nL4Xi275+RZ1WhvLhIdqTjWcajj6Aw4wqSqVJ7Rql
lcMOJNayZzOQRAT75JWy
=dS6j
-----END PGP SIGNATURE-----

--=-HlqO3EB7v0BqmDxVqv5A--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
