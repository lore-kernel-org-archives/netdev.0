From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 1/2] r8169: allow rtl_hw_phy_config() and
 rtl8169_init_phy() to return error codes
Date: Sun, 01 Nov 2009 22:51:04 +0000
Message-ID: <1257115864.3136.338.camel@localhost>
References: <1257115687.3136.337.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-MuhdnboDxArAfefoeou+"
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50399 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753656AbZKAWvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2009 17:51:03 -0500
In-Reply-To: <1257115687.3136.337.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MuhdnboDxArAfefoeou+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This is preparation for loading PHY firmware, which may fail.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
This one belongs before the other.  Sorry about sending them in the
wrong order.

Ben.

 drivers/net/r8169.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f98ef52..8ceecd0 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2607,7 +2607,7 @@ static void rtl8102e_hw_phy_config(void __iomem *ioad=
dr)
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
=20
-static void rtl_hw_phy_config(struct net_device *dev)
+static int rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
 	void __iomem *ioaddr =3D tp->mmio_addr;
@@ -2676,6 +2676,8 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	default:
 		break;
 	}
+
+	return 0;
 }
=20
 static void rtl8169_phy_timer(unsigned long __opaque)
@@ -2780,11 +2782,14 @@ static void rtl8169_phy_reset(struct net_device *de=
v,
 		printk(KERN_ERR "%s: PHY reset failed.\n", dev->name);
 }
=20
-static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_privat=
e *tp)
+static int rtl8169_init_phy(struct net_device *dev, struct rtl8169_private=
 *tp)
 {
 	void __iomem *ioaddr =3D tp->mmio_addr;
+	int rc;
=20
-	rtl_hw_phy_config(dev);
+	rc =3D rtl_hw_phy_config(dev);
+	if (rc)
+		return rc;
=20
 	if (tp->mac_version <=3D RTL_GIGA_MAC_VER_06) {
 		dprintk("Set MAC Reg C+CR Offset 0x82h =3D 0x01h\n");
@@ -2813,6 +2818,8 @@ static void rtl8169_init_phy(struct net_device *dev, =
struct rtl8169_private *tp)
=20
 	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
 		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
+
+	return 0;
 }
=20
 static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
@@ -3199,7 +3206,9 @@ rtl8169_init_one(struct pci_dev *pdev, const struct p=
ci_device_id *ent)
 		       dev->dev_addr[4], dev->dev_addr[5], xid, dev->irq);
 	}
=20
-	rtl8169_init_phy(dev, tp);
+	rc =3D rtl8169_init_phy(dev, tp);
+	if (rc)
+		goto err_out_msi_5;
=20
 	/*
 	 * Pretend we are using VLANs; This bypasses a nasty bug where
--=20
1.6.5.2




--=-MuhdnboDxArAfefoeou+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASu4Q1ue/yOyVhhEJAQKQVRAAgHAdSul+la0PyVOB3fXEAKiE6bRyINZn
aGEtWpDgti6lsG4KSXrw6ZAYlGWJWTKYWsG2sLceJgl3ivi2QGj/JgQ5vQ4uLjOE
cnJAEiB0syMxeXTPx7gBre4Vk5phL4kZmB+popQshe8JoJqKNzAKwh47s4Puid80
mBuoQV6KL8XOUCIEpgfLIW70h9tkSFYJDIIHLMugnkObUf88oEom++oLZUD2MguV
vmBWLB7XD/Mzls3ZzvU4M+MeZw2MHDvx7TlwmHP07Fcfu7Ex8xwbdY05XNB4LlyH
TwNSO0YdycX0mniq4a3PUOySwBK/9UB4tSMBIxpItT29rneQZpl2DN0aJI/gzJtZ
Ud5zgKP2ve7swj29/YalZCr0ej93DLHUbpDzhIAivk7Tmud+AJJPccN/2uMf82Fv
35knd0DCqQ9PqvHGbut6sHhx9ilOu/zafNHgkXjBBLs2OWf2TXLq8y96k16sGecN
xq5HnW4GCtwhMnAAReemY9czWOnR2bhSmhX8Ii+XeyNlfGrnmxzyOFaAGSq15acJ
mSf8a8sdptAq7ezKkfYfnPKaA1PZpWdatpzNL5oEjmTYyp4+cwmfkJKgxynDOZCb
DUiV4Oo7o20lpswLxtPz3+67AKtv19RSiyMaIzSJmdBqxwpkMrtX+9OdVjb+TNIW
8HO5FB/5lFA=
=UQgE
-----END PGP SIGNATURE-----

--=-MuhdnboDxArAfefoeou+--
