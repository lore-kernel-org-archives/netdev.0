From: Johannes Berg <johannes@sipsolutions.net>
Subject: [patch 5] softmac: report when scanning has finished
Date: Thu, 13 Apr 2006 11:41:28 +0200
Message-ID: <1144921288.4187.54.camel@localhost>
References: <20060411085805.949313000@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-qy8P4gs7UoEK0GeSyv8E"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	softmac-dev@sipsolutions.net, Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:20106 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964865AbWDMJmk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:42:40 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060411085805.949313000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-qy8P4gs7UoEK0GeSyv8E
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Make softmac report a scan event when scanning has finished, that way
userspace can wait for the event to happen instead of polling for the
results.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
This patch depends on the previous patch 4. If you want, I can resend
the whole series with proper patch x/5 headers etc. I don't know if
these can still go in before .17, but it'd be very good if they could,
they're essentially bug fixes for things I either didn't know or just
plain bugs :)

Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_event.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_event.c	2006-0=
4-13 02:42:59.000000000 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_event.c	2006-04-13 =
11:30:59.896998787 +0200
@@ -152,6 +152,12 @@
 			wrqu.ap_addr.sa_family =3D ARPHRD_ETHER;
 			we_event =3D SIOCGIWAP;
 			break;
+		case IEEE80211SOFTMAC_EVENT_SCAN_FINISHED:
+			wrqu.data.length =3D 0;
+			wrqu.data.flags =3D 0;
+			memset(&wrqu, '\0', sizeof (union iwreq_data));
+			we_event =3D SIOCGIWSCAN;
+			break;
 		default:
 			msg =3D event_descriptions[event];
 			wrqu.data.length =3D strlen(msg);


--=-qy8P4gs7UoEK0GeSyv8E
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARD4cxqVg1VMiehFYAQJMxRAAibTGk5+FoqtddJPa9FpA4FRgS1IZTxLx
B39oYHRtcS7xzkrogL1FUMXXFVmYXs2jdjLBJew2sIDOgwaqQGzAbWcE6nqB1748
GgS2hSxveFEHvx7ynU16QDKPHchwOBrMEqza0x6XxB5XuuRRQa20vrcGPMRGut1P
cBAcAu57c0Zn/5sh+YXHynXyYSG04AAjbCga0EiUbIg4DAYzSWQlWTwMU9dWw2MU
n1/j4dgsB2QTRJGYV0FBpgQvQbSBFbFsbQVl3XiiEz4npL1qJH4bm2t0R7Xpt3Ia
hqH6TxSmyHgt2RSKLFgvv3gSnc6er6UWH3I51qki8znyG9QYViN9kql0UFYvE3YO
Bj4Xhp9f4Ygw6ksqNMmx+Z82hk3l8jPYdApMW1hvCkc/G1X1gSFGF43amX0SZL55
D6u9QDDdNh76DUC97UXOgn+kOWcYg9qRX4/uXc9DrOHjqNzXkzZ97FR9ewjfGvws
ekLiqj1CqIbNJZos/63qeGBLtg0+OQOPeUJPwBwFf09M08b6vp314ldxR64lvRvq
iviLU4Xg8SsktmbykTsWdfOig8D2/SpK2Qt2UVHoblAzgaDOrfVJuX48Zwpj/qUi
0/syxQ0P38QhaxSfKnyz+49k66LXXD8zKnKEdxxcGa6x56qF+YtSdL6Mopkllpaw
aWn2Q8/g3+I=
=wBO7
-----END PGP SIGNATURE-----

--=-qy8P4gs7UoEK0GeSyv8E--

