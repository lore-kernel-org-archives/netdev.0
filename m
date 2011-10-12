From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the wireless tree
Date: Wed, 12 Oct 2011 13:36:00 +1100
Message-ID: <20111012133600.256fea364b17e6bf96ee1081@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__12_Oct_2011_13_36_00_+1100_qpLE67rUHAYjb+5o"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Arend van Spriel <arend@broadcom.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__12_Oct_2011_13_36_00_+1100_qpLE67rUHAYjb+5o
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

After merging the wireless tree, today's linux-next build (x86_64
allmodconfig) failed like this:

drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c:1131:2: error: unknown =
field 'ndo_set_multicast_list' specified in initializer
drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c:1132:1: warning: initia=
lization from incompatible pointer type [enabled by default]
drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c:1132:1: warning: (near =
initialization for 'brcmf_netdev_ops_pri.ndo_validate_addr') [enabled by de=
fault]

Caused by commit 5b435de0d786 ("net: wireless: add brcm80211 drivers")
interacting with commit b81693d9149c ("net: remove ndo_set_multicast_list
callback") from the net-next tree.

I have applied the following merge fixup patch for today.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 12 Oct 2011 13:33:10 +1100
Subject: [PATCH] net: wireless: brcm80211: replace ndo_set_multicast_list  =
with ndo_set_rx_mode

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/=
net/wireless/brcm80211/brcmfmac/dhd_linux.c
index 99ba5e3..03607ca 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -1128,7 +1128,7 @@ static struct net_device_ops brcmf_netdev_ops_pri =3D=
 {
 	.ndo_do_ioctl =3D brcmf_netdev_ioctl_entry,
 	.ndo_start_xmit =3D brcmf_netdev_start_xmit,
 	.ndo_set_mac_address =3D brcmf_netdev_set_mac_address,
-	.ndo_set_multicast_list =3D brcmf_netdev_set_multicast_list
+	.ndo_set_rx_mode =3D brcmf_netdev_set_multicast_list
 };
=20
 int brcmf_net_attach(struct brcmf_pub *drvr, int ifidx)
--=20
1.7.6.3

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__12_Oct_2011_13_36_00_+1100_qpLE67rUHAYjb+5o
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOlP0QAAoJEECxmPOUX5FEl2kQAJwjZtVfV425wQdg+0+R7rf0
BdjfSf0LZnC64bPRx9Fnlh4AKjFf7T641Tr6yZrLMNbJh4pYeEojwzIg7v5jn6UO
E/pVdZV3ra7wtvxusg0vQlOECw9/XV+XiSa2vgRIcpSKEO71ifqW5/9UJ0LhtgKN
lc9MnkcZqPRQZwpXRvU71M2y2JvWBQnP0Aa23gBH3aaFyz//2x4bUTw+VpLlpNo9
JX3xmYtZHhiPcrjbGRWlEJXmHfp9DVJXPSSpuu+ZIrKbBFGfNIsmmGiMgCVNGwh7
UGKA8inAbpIzIm5vWgFJiejYUJSLm1fDB9le4rhEnNG4bQ3P7jOejK+0Af2Km6Ka
6qht0FwBqVUx/aVbbAi81kV1kQRHe/Mm0C0u2UfIrW1BkSlTzjg2ZEerJ4h0zjj/
5ay0/154olSQgqvdSBpvBQu7TFy6k0VpkCNSrkgl7C86sEJMSoSGZR1HChic7u74
CV+IH4KosQcJeCoYesNzdtC+Tosw0Z2cge+WKuuQDT3fDwoYqjkNldHkjgtuIYto
ZqRDVNH9c/G8+jnPoXlMdQG1eoVI1p7APpsjLlimWbdlBf9+m+ZXYRIe/pSyt0A1
PXiPdoTEIDZg56GrBa3SKCuvrY3GouGol7PSFxjhl4EJleD54dq0I9N71gJf9FQc
NaZ4wv7b9j5Wz9eXzREu
=b85/
-----END PGP SIGNATURE-----

--Signature=_Wed__12_Oct_2011_13_36_00_+1100_qpLE67rUHAYjb+5o--
