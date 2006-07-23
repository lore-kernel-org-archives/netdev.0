From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] d80211: Make MACSTR/MAC2STR macro available to drivers
Date: Sun, 23 Jul 2006 01:43:25 -0700
Message-ID: <200607230143.31375.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1775693.Wek1S1itu7";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:28836 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751155AbWGWInn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 04:43:43 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1775693.Wek1S1itu7
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

d80211: Make MACSTR/MAC2STR macro available to drivers

This patch moves the MACSTR/MAC2STR macros to d80211.h
so that they are available to drivers. It also converts the adm8211
and bcm43xx drivers to use this macro.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/d80211/adm8211/adm8211.c      |    7 ++-----
 drivers/net/wireless/d80211/bcm43xx/bcm43xx.h      |    6 ------
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    8 ++++----
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c |    4 ++--
 include/net/d80211.h                               |    4 ++++
 net/d80211/ieee80211_i.h                           |    5 -----
 6 files changed, 12 insertions(+), 22 deletions(-)

diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c b/drivers/net/wi=
reless/d80211/adm8211/adm8211.c
index be4a058..0a762d7 100644
=2D-- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -74,9 +74,6 @@ #define PLCP_SIGNAL_2M		0x14
 #define PLCP_SIGNAL_5M5		0x37
 #define PLCP_SIGNAL_11M		0x6e
=20
=2D#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
=2D#define MAC_ARG(x) ((u8*)(x))[0],((u8*)(x))[1],((u8*)(x))[2],((u8*)(x))[=
3],((u8*)(x))[4],((u8*)(x))[5]
=2D
 struct adm8211_tx_hdr {
 	u8 da[6];
 	u8 signal; /* PLCP signal / TX rate in 100 Kbps */
@@ -2085,8 +2082,8 @@ #endif
 		goto err_free_desc;
 	}
=20
=2D	printk("%s: hwaddr " MAC_FMT ", Rev 0x%02x\n",
=2D	       dev->name, MAC_ARG(dev->dev_addr), priv->revid);
+	printk("%s: hwaddr " MACSTR ", Rev 0x%02x\n",
+	       dev->name, MAC2STR(dev->dev_addr), priv->revid);
=20
 	return 0;
=20
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h b/drivers/net/wi=
reless/d80211/bcm43xx/bcm43xx.h
index af4bb46..91a98a9 100644
=2D-- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
@@ -991,10 +991,4 @@ #define limit_value(value, min, max)  \
 	 	__value;				\
 	})
=20
=2D/** Helpers to print MAC addresses. */
=2D#define BCM43xx_MACFMT		"%02x:%02x:%02x:%02x:%02x:%02x"
=2D#define BCM43xx_MACARG(x)	((u8*)(x))[0], ((u8*)(x))[1], \
=2D				((u8*)(x))[2], ((u8*)(x))[3], \
=2D				((u8*)(x))[4], ((u8*)(x))[5]
=2D
 #endif /* BCM43xx_H_ */
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/n=
et/wireless/d80211/bcm43xx/bcm43xx_main.c
index b6425e3..82985f2 100644
=2D-- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -4561,9 +4561,9 @@ static int bcm43xx_add_interface(struct=20
=20
 	dprintk(KERN_INFO PFX "Virtual interface added "
 			      "(type: 0x%08X, ID: %d, MAC: "
=2D			      BCM43xx_MACFMT ")\n",
+			      MACSTR ")\n",
 		conf->type, conf->if_id,
=2D		BCM43xx_MACARG(conf->mac_addr));
+		MAC2STR(conf->mac_addr));
=20
 out_unlock:
 	bcm43xx_unlock_irqsafe(bcm, flags);
@@ -4589,9 +4589,9 @@ static void bcm43xx_remove_interface(str
=20
 	dprintk(KERN_INFO PFX "Virtual interface removed "
 			      "(type: 0x%08X, ID: %d, MAC: "
=2D			      BCM43xx_MACFMT ")\n",
+			      MACSTR ")\n",
 		conf->type, conf->if_id,
=2D		BCM43xx_MACARG(conf->mac_addr));
+		MAC2STR(conf->mac_addr));
 }
=20
 static int bcm43xx_config_interface(struct net_device *net_dev,
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c b/drivers/n=
et/wireless/d80211/bcm43xx/bcm43xx_xmit.c
index 562c6a1..6ebe9fa 100644
=2D-- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
@@ -259,8 +259,8 @@ assert(dur);
=20
 	txhdr->rts_cts_frame_control =3D cpu_to_le16(fctl);
 	txhdr->rts_cts_dur =3D cpu_to_le16(dur);
=2D//printk(BCM43xx_MACFMT "  " BCM43xx_MACFMT "  " BCM43xx_MACFMT "\n", BC=
M43xx_MACARG(wlhdr->addr1), BCM43xx_MACARG(wlhdr->addr2), BCM43xx_MACARG(wl=
hdr->addr3));
=2D//printk(BCM43xx_MACFMT "  " BCM43xx_MACFMT "\n", BCM43xx_MACARG(sa), BC=
M43xx_MACARG(da));
+//printk(MACSTR "  " MACSTR "  " MACSTR "\n", MAC2STR(wlhdr->addr1), MAC2S=
TR(wlhdr->addr2), MAC2STR(wlhdr->addr3));
+//printk(MACSTR "  " MACSTR "\n", MAC2STR(sa), MAC2STR(da));
 	memcpy(txhdr->rts_cts_mac1, wlhdr->addr1, ETH_ALEN);//FIXME!
 	memcpy(txhdr->rts_cts_mac2, sa, ETH_ALEN);
=20
diff --git a/include/net/d80211.h b/include/net/d80211.h
index e6dcb0e..b9d4b24 100644
=2D-- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -999,4 +999,8 @@ static inline int ieee80211_get_morefrag
 	return (le16_to_cpu(hdr->frame_control) & WLAN_FC_MOREFRAG) !=3D 0;
 }
=20
+#define MAC2STR(a) ((a)[0] & 0xff), ((a)[1] & 0xff), ((a)[2] & 0xff), \
+		   ((a)[3] & 0xff), ((a)[4] & 0xff), ((a)[5] & 0xff)
+#define MACSTR "%02x:%02x:%02x:%02x:%02x:%02x"
+
 #endif /* D80211_H */
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 691edd0..df8a43e 100644
=2D-- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -46,11 +46,6 @@ #define AP_MAX_BC_BUFFER 128
 #define TOTAL_MAX_TX_BUFFER 512
=20
=20
=2D#define MAC2STR(a) ((a)[0] & 0xff), ((a)[1] & 0xff), ((a)[2] & 0xff), \
=2D		   ((a)[3] & 0xff), ((a)[4] & 0xff), ((a)[5] & 0xff)
=2D#define MACSTR "%02x:%02x:%02x:%02x:%02x:%02x"
=2D
=2D
 /* IEEE 802.11 (Ch. 9.5 Defragmentation) requires support for concurrent
  * reception of at least three fragmented frames. This limit can be increa=
sed
  * by changing this define, at the cost of slower frame reassembly and

--nextPart1775693.Wek1S1itu7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEwzazT3Oqt9AH4aERAlO0AJ91NzhugHx2ZHXj8EozU2igpt+RrwCbBhoc
BtVCfJbJyTC3EWAaCJfl/Hc=
=da3M
-----END PGP SIGNATURE-----

--nextPart1775693.Wek1S1itu7--
