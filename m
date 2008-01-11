From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: handing cloned frames to netif_rx()?
Date: Fri, 11 Jan 2008 02:17:26 +0100
Message-ID: <1200014246.3861.148.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-otqGlbx99hSwJc/dvnvo"
Cc: Ron Rindjunsky <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-otqGlbx99hSwJc/dvnvo
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

In 802.11n, there is a case where multiple data frames are received
aggregated into a single frame (A-MSDU).

Currently, we copy each of these frames out into their own skb, but
because of the alignment with that etc. I started to think that we could
simply pass up a clone of the original skb with start/length adjusted
properly so that it windows only the contained packet.

The buffer would be shared but the data within the original window
(starting with the 802.3 header) could even be written to, it won't be
needed again by mac80211 once it's handed off to netif_rx(). The skb
will obviously have lots of head- and tailroom but that space would be
part of other packets.

Is it ok to do this? Will something freak out if we pass a cloned skb to
netif_rx()?

johannes

--=-otqGlbx99hSwJc/dvnvo
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR4bDpKVg1VMiehFYAQLI7g/+PrcQAuCq/4RbYeU1yfqLEzHnbCtNjpMQ
+5qBaZLcAi5AzpHqaR/7z3Ea39ciwSxhT3v3WCEPMZyPjP78efLFNKoZ5TCvVvFs
eOsgQHzq+POAvZ2fCjINXKFab35O4W2RejHMLlBDG62adh2LL8XRUnIvItQrqLc8
oXYSGahleuSIC4mBg4mGAOKPHZbJkrPmDLGQEqywAgPziMGIyv/uLkiCsOjr43yk
nFjLFzkPz1wQMrpbYcVKfu0JYaVVtVcUYS9RqPKMAKgmyTuh5mrt3j0kV7zjKZsO
MnewOAa9EX98wXvhx0Se6ofz7rtFlSI3bTLWDo55CzczhUX9EayGohLZtypatEs0
xG1j+lKRiW48n6KkSvmOLQJxZ+7bTlOBebSuqjDOBrjye3zBU0oiQ7xjL2I5Q0Nu
LB3W/+EybkSnC4DG9CGoCzW/4L+wontSmny1l75MyCPTf3Yxi151nJf4E/e/JhAa
bu86f0MFdXEDX8sTc3Lm+46MQJnUj4yKvBqoG6ob1VTWV7Ce4MJazRqymRBiZPUa
8KdCbq5XkDaphqkEiJ85/BlRr86Wa13DvP6jxJ8A3+NNGthg3acB+Nizmku+L1Hd
sEIpREIjHVwCbCX0BR1+anKZoog6ncahsUTIq92KH8A0tv1AObyhJTX2DVDuhu5v
VtAMrnTa9o8=
=9bzi
-----END PGP SIGNATURE-----

--=-otqGlbx99hSwJc/dvnvo--
