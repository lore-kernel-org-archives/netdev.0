From: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
Subject: [PATCH] prism54 tree sync update
Date: Wed, 17 Mar 2004 01:36:59 -0500
Sender: prism54-devel-admin@prism54.org
Message-ID: <20040317063659.GC24063@ruslug.rutgers.edu>
Reply-To: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+9faIjRurCDpBc7U"
Cc: prism54-devel@prism54.org
Return-path: <prism54-devel-admin@prism54.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org


--+9faIjRurCDpBc7U
Content-Type: multipart/mixed; boundary="kH8JNVvasRCCW1Oz"
Content-Disposition: inline


--kH8JNVvasRCCW1Oz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Attached patch has been well tested. It updates 2.6.5-rc1 prism54
sources to our latest work (which had also previously been tested).
Some additional new kernel updates were integrated as well.

Here is the ChangeLog:

	* wireless/Kconfig: fix typos, add SMC2835W-V2
	* islpci_hotplug.c: new version 1.1, authors list, and
	module description updated appropriately
	* isl_ioctl.c, islpci_dev.c,=20
	islpci_eth.c, islpci_hotplug.c, islpci_mgt.c:=20
	s/ndev->priv/netdev_priv(ndev)/g
	* islpci_hotplug.c: Add PCI ID values for SMC2835W-V2 cardbus card
	Patch by Manuel Lauss <manuel.lauss@fh-hagenberg.at>
	* isl_38xx.[ch]: include firmware.h in header, remove
	declaration of headers in c file. Fix compiler warnings.
	* islpci_dev.c (islpci_alloc_memory),
	* islpci_eth.c (islpci_eth_cleanup_transmit,=20
	islpci_eth_transmit, islpci_eth_receive): deal with skb stray=20
	pointer, declare NULL.
	* isl_38xx.c: remove unecessary __KERNEL_SYSCALLS__ and
	re-ordered headers per vger.kernel.org - liking.
	* isl_ioctl.c, islpci_mgt.c: move from MODULE_PARAM to the new
	module_param, which is type-safe. Includes the new=20
	<linux/moduleparam.h>.
	* isl_ioctl.c (prism54_[s|g]et_[maxframeburst|profile]): added.
	Not adding ioctls as ajfa is working on moving current private ioctls
	to subioctls.
	* isl_oid.h (dot11_[maxframeburst|preamblesettings|
	slotsettings|nonerpstatus|nonerpprotection]_t): added.
	Note: more ioctls can be added here, I believe problems
	with mixed modes can be pinpointed here, with these values.

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--kH8JNVvasRCCW1Oz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch-2.6.5-rc1-prism54.diff"
Content-Transfer-Encoding: quoted-printable

diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.6.5-rc1/drivers/net/wireles=
s/Kconfig linux-2.6.5-rc1-mcgrof/drivers/net/wireless/Kconfig
--- linux-2.6.5-rc1/drivers/net/wireless/Kconfig	Tue Mar 16 20:55:11 2004
+++ linux-2.6.5-rc1-mcgrof/drivers/net/wireless/Kconfig	Wed Mar 17 06:07:21=
 2004
@@ -307,18 +307,18 @@
 	 It has basic support for Linux wireless extensions and initial
 	 micro support for ethtool.
=20
-comment "Prism GT/Duette 802.11(a/b/g) PCI/PCMCIA support"
+comment "Prism GT/Duette 802.11(a/b/g) PCI/Cardbus support"
 	depends on NET_RADIO && PCI
 config PRISM54
-	tristate 'Intersil Prism GT/Duette/Indigo PCI/PCMCIA'=20
+	tristate 'Intersil Prism GT/Duette/Indigo PCI/Cardbus'=20
 	depends on PCI && NET_RADIO && EXPERIMENTAL && HOTPLUG
 	select FW_LOADER
 	---help---
 	  Enable PCI and Cardbus support for the following chipset based cards:
=20
-	  ISL3880 - Prism GT		802.11 b/g
-	  ISL3877 - Prism Indigo	802.11 a
-	  ISL3890 - Prism Duette	802.11 a/b/g
+	  ISL3880 - Prism GT            802.11 b/g
+	  ISL3877 - Prism Indigo        802.11 a
+	  ISL3890 - Prism Duette        802.11 a/b/g
 	 =20
 	  For a complete list of supported cards visit <http://prism54.org>.
 	  Here is the latest confirmed list of supported cards:
@@ -335,8 +335,9 @@
 	  Peabird WLG-PCI PCI Card
 	  Sitecom WL-100i Cardbus Card
 	  Sitecom WL-110i PCI Card
-	  SMC2802W - EZ Connect g 2.4GHz 54 Mbps Wireless PCI Card
-	  SMC2835W - EZ Connect g 2.4GHz 54 Mbps Wireless Cardbus Card
+	  SMC2802W -    EZ Connect g 2.4GHz 54 Mbps Wireless PCI Card
+	  SMC2835W -    EZ Connect g 2.4GHz 54 Mbps Wireless Cardbus Card
+	  SMC2835W-V2 - EZ Connect g 2.4GHz 54 Mbps Wireless Cardbus Card
 	  Z-Com XG-900 PCI Card
 	  Zyxel G-100 Cardbus Card
=20
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.6.5-rc1/drivers/net/wireles=
s/prism54/isl_ioctl.c linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/i=
sl_ioctl.c
--- linux-2.6.5-rc1/drivers/net/wireless/prism54/isl_ioctl.c	Tue Mar 16 20:=
55:11 2004
+++ linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/isl_ioctl.c	Wed Mar=
 17 01:00:42 2004
@@ -25,6 +25,7 @@
 #include <linux/kernel.h>
 #include <linux/if_arp.h>
 #include <linux/pci.h>
+#include <linux/moduleparam.h>
=20
 #include <asm/uaccess.h>
=20
@@ -44,26 +45,26 @@
 static int init_conformance =3D CARD_DEFAULT_CONFORMANCE;
 static int init_mlme =3D CARD_DEFAULT_MLME_MODE;
=20
-MODULE_PARM(init_mode, "i");
+module_param(init_mode, int, 0);
 MODULE_PARM_DESC(init_mode,
 		 "Set card mode:\n0: Auto\n1: Ad-Hoc\n2: Managed Client (Default)\n3: Ma=
ster / Access Point\n4: Repeater (Not supported yet)\n5: Secondary (Not sup=
ported yet)\n6: Monitor");
=20
-MODULE_PARM(init_channel, "i");
+module_param(init_channel, int, 0);
 MODULE_PARM_DESC(init_channel,
 		 "Check `iwpriv ethx channel` for available channels");
=20
-MODULE_PARM(init_wep, "i");
-MODULE_PARM(init_filter, "i");
+module_param(init_wep, int, 0);
+module_param(init_filter, int, 0);
=20
-MODULE_PARM(init_authen, "i");
+module_param(init_authen, int, 0);
 MODULE_PARM_DESC(init_authen,
 		 "Authentication method. Can be of seven types:\n0 0x0000: None\n1 0x000=
1: DOT11_AUTH_OS (Default)\n2 0x0002: DOT11_AUTH_SK\n3 0x0003: DOT11_AUTH_B=
OTH");
=20
-MODULE_PARM(init_dot1x, "i");
+module_param(init_dot1x, int, 0);
 MODULE_PARM_DESC(init_dot1x,
 		 "\n0: None/not set	(Default)\n1: DOT11_DOT1X_AUTHENABLED\n2: DOT11_DOT1=
X_KEYTXENABLED");
=20
-MODULE_PARM(init_mlme, "i");
+module_param(init_mlme, int, 0);
 MODULE_PARM_DESC(init_mlme,
 		 "Sets the MAC layer management entity (MLME) mode of operation,\n0: DOT=
11_MLME_AUTO (Default)\n1: DOT11_MLME_INTERMEDIATE\n2: DOT11_MLME_EXTENDED"=
);
=20
@@ -250,7 +251,7 @@
 struct iw_statistics *
 prism54_get_wireless_stats(struct net_device *ndev)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
=20
 	/* If the stats are being updated return old data */
 	if (down_trylock(&priv->stats_sem) =3D=3D 0) {
@@ -277,7 +278,7 @@
 prism54_commit(struct net_device *ndev, struct iw_request_info *info,
 	       char *cwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
=20
 	/* simply re-set the last set SSID, this should commit most stuff */
=20
@@ -293,7 +294,7 @@
 prism54_get_name(struct net_device *ndev, struct iw_request_info *info,
 		 char *cwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	char *capabilities;
 	union oid_res_t r;
 	int rvalue;
@@ -324,7 +325,7 @@
 prism54_set_freq(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_freq *fwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	int rvalue;
 	u32 c =3D 0;
=20
@@ -363,7 +364,7 @@
 prism54_get_freq(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_freq *fwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue;
=20
@@ -379,7 +380,7 @@
 prism54_set_mode(struct net_device *ndev, struct iw_request_info *info,
 		 __u32 * uwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	u32 mlmeautolevel =3D CARD_DEFAULT_MLME_MODE;
=20
 	/* Let's see if the user passed a valid Linux Wireless mode */
@@ -420,7 +421,7 @@
 prism54_get_mode(struct net_device *ndev, struct iw_request_info *info,
 		 __u32 * uwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
=20
 	BUG_ON((priv->iw_mode < IW_MODE_AUTO) || (priv->iw_mode >
 						  IW_MODE_MONITOR));
@@ -438,7 +439,7 @@
 prism54_set_sens(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	u32 sens;
=20
 	/* by default  the card sets this to 20. */
@@ -452,7 +453,7 @@
 prism54_get_sens(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue;
=20
@@ -470,7 +471,7 @@
 		  struct iw_point *dwrq, char *extra)
 {
 	struct iw_range *range =3D (struct iw_range *) extra;
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	char *data;
 	int i, m, rvalue;
 	struct obj_frequencies *freq;
@@ -576,7 +577,7 @@
 prism54_set_wap(struct net_device *ndev, struct iw_request_info *info,
 		struct sockaddr *awrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	char bssid[6];
 	int rvalue;
=20
@@ -598,7 +599,7 @@
 prism54_get_wap(struct net_device *ndev, struct iw_request_info *info,
 		struct sockaddr *awrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue;
=20
@@ -630,7 +631,7 @@
 {
 	struct iw_event iwe;	/* Temporary buffer */
 	short cap;
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
=20
 	/* The first entry must be the MAC address */
 	memcpy(iwe.u.ap_addr.sa_data, bss->address, 6);
@@ -721,7 +722,7 @@
 prism54_get_scan(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	int i, rvalue;
 	struct obj_bsslist *bsslist;
 	u32 noise =3D 0;
@@ -762,7 +763,7 @@
 prism54_set_essid(struct net_device *ndev, struct iw_request_info *info,
 		  struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	struct obj_ssid essid;
=20
 	memset(essid.octets, 0, 33);
@@ -789,7 +790,7 @@
 prism54_get_essid(struct net_device *ndev, struct iw_request_info *info,
 		  struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	struct obj_ssid *essid;
 	union oid_res_t r;
 	int rvalue;
@@ -819,7 +820,7 @@
 prism54_set_nick(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
=20
 	if (dwrq->length > IW_ESSID_MAX_SIZE)
 		return -E2BIG;
@@ -836,7 +837,7 @@
 prism54_get_nick(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
=20
 	dwrq->length =3D 0;
=20
@@ -856,7 +857,7 @@
 		 struct iw_param *vwrq, char *extra)
 {
=20
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	u32 rate, profile;
 	char *data;
 	int ret, i;
@@ -924,7 +925,7 @@
 		 struct iw_request_info *info,
 		 struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	int rvalue;
 	char *data;
 	union oid_res_t r;
@@ -948,7 +949,7 @@
 prism54_set_rts(struct net_device *ndev, struct iw_request_info *info,
 		struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
=20
 	return mgt_set_request(priv, DOT11_OID_RTSTHRESH, 0, &vwrq->value);
 }
@@ -957,7 +958,7 @@
 prism54_get_rts(struct net_device *ndev, struct iw_request_info *info,
 		struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue;
=20
@@ -972,7 +973,7 @@
 prism54_set_frag(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
=20
 	return mgt_set_request(priv, DOT11_OID_FRAGTHRESH, 0, &vwrq->value);
 }
@@ -981,7 +982,7 @@
 prism54_get_frag(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue;
=20
@@ -1004,7 +1005,7 @@
 prism54_set_retry(struct net_device *ndev, struct iw_request_info *info,
 		  struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	u32 slimit =3D 0, llimit =3D 0;	/* short and long limit */
 	u32 lifetime =3D 0;
 	int rvalue =3D 0;
@@ -1048,7 +1049,7 @@
 prism54_get_retry(struct net_device *ndev, struct iw_request_info *info,
 		  struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue =3D 0;
 	vwrq->disabled =3D 0;	/* It cannot be disabled */
@@ -1080,7 +1081,7 @@
 prism54_set_encode(struct net_device *ndev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	int rvalue =3D 0, force =3D 0;
 	int authen =3D DOT11_AUTH_OS, invoke =3D 0, exunencrypt =3D 0;
 	union oid_res_t r;
@@ -1170,7 +1171,7 @@
 prism54_get_encode(struct net_device *ndev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	struct obj_key *key;
 	u32 devindex, index =3D (dwrq->flags & IW_ENCODE_INDEX) - 1;
 	u32 authen =3D 0, invoke =3D 0, exunencrypt =3D 0;
@@ -1218,7 +1219,7 @@
 prism54_get_txpower(struct net_device *ndev, struct iw_request_info *info,
 		    struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue;
=20
@@ -1238,7 +1239,7 @@
 prism54_set_txpower(struct net_device *ndev, struct iw_request_info *info,
 		    struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	s32 u =3D vwrq->value;
=20
 	/* intersil firmware operates in 0.25 dBm (1/4) */
@@ -1264,7 +1265,7 @@
 prism54_reset(struct net_device *ndev, struct iw_request_info *info,
 	      __u32 * uwrq, char *extra)
 {
-	islpci_reset(ndev->priv, 0);
+	islpci_reset(netdev_priv(ndev), 0);
=20
 	return 0;
 }
@@ -1273,7 +1274,7 @@
 prism54_set_beacon(struct net_device *ndev, struct iw_request_info *info,
 		   __u32 * uwrq, char *extra)
 {
-	int rvalue =3D mgt_set_request((islpci_private *) ndev->priv,
+	int rvalue =3D mgt_set_request((islpci_private *) netdev_priv(ndev),
 				     DOT11_OID_BEACONPERIOD, 0, uwrq);
=20
 	return (rvalue ? rvalue : -EINPROGRESS);
@@ -1287,7 +1288,7 @@
 	int rvalue;
=20
 	rvalue =3D
-	    mgt_get_request((islpci_private *) ndev->priv,
+	    mgt_get_request((islpci_private *) netdev_priv(ndev),
 			    DOT11_OID_BEACONPERIOD, 0, NULL, &r);
 	*uwrq =3D r.u;
=20
@@ -1337,7 +1338,7 @@
 prism54_add_mac(struct net_device *ndev, struct iw_request_info *info,
 		struct sockaddr *awrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	struct islpci_acl *acl =3D &priv->acl;
 	struct mac_entry *entry;
 	struct sockaddr *addr =3D (struct sockaddr *) extra;
@@ -1366,7 +1367,7 @@
 prism54_del_mac(struct net_device *ndev, struct iw_request_info *info,
 		struct sockaddr *awrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	struct islpci_acl *acl =3D &priv->acl;
 	struct mac_entry *entry;
 	struct list_head *ptr;
@@ -1396,7 +1397,7 @@
 prism54_get_mac(struct net_device *ndev, struct iw_request_info *info,
 		struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	struct islpci_acl *acl =3D &priv->acl;
 	struct mac_entry *entry;
 	struct list_head *ptr;
@@ -1427,7 +1428,7 @@
 prism54_set_policy(struct net_device *ndev, struct iw_request_info *info,
 		   __u32 * uwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	struct islpci_acl *acl =3D &priv->acl;
 	u32 mlmeautolevel;
=20
@@ -1460,7 +1461,7 @@
 prism54_get_policy(struct net_device *ndev, struct iw_request_info *info,
 		   __u32 * uwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	struct islpci_acl *acl =3D &priv->acl;
=20
 	*uwrq =3D acl->policy;
@@ -1511,7 +1512,7 @@
=20
 	/* Tell the card to kick every client */
 	mlme->id =3D cpu_to_le16(0);
-	rvalue =3D mgt_set_request(ndev->priv, DOT11_OID_DISASSOCIATE, 0, mlme);
+	rvalue =3D mgt_set_request(netdev_priv(ndev), DOT11_OID_DISASSOCIATE, 0, =
mlme);
 	kfree(mlme);
=20
 	return rvalue;
@@ -1535,7 +1536,7 @@
 	/* Tell the card to only kick the corresponding bastard */
 	memcpy(mlme->address, addr->sa_data, ETH_ALEN);
 	mlme->id =3D cpu_to_le16(-1);
-	rvalue =3D mgt_set_request(ndev->priv, DOT11_OID_DISASSOCIATE, 0, mlme);
+	rvalue =3D mgt_set_request(netdev_priv(ndev), DOT11_OID_DISASSOCIATE, 0, =
mlme);
=20
 	kfree(mlme);
=20
@@ -1595,7 +1596,7 @@
 static void
 link_changed(struct net_device *ndev, u32 bitrate)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
=20
 	if (le32_to_cpu(bitrate)) {
 		if (priv->iw_mode =3D=3D IW_MODE_INFRA) {
@@ -1604,9 +1605,9 @@
 					NULL);
 			wireless_send_event(ndev, SIOCGIWAP, &uwrq, NULL);
 		} else
-			send_simple_event(ndev->priv, "Link established");
+			send_simple_event(netdev_priv(ndev), "Link established");
 	} else
-		send_simple_event(ndev->priv, "Link lost");
+		send_simple_event(netdev_priv(ndev), "Link lost");
 }
=20
 /* Beacon/ProbeResp payload header */
@@ -1889,16 +1890,17 @@
 prism54_process_trap(void *data)
 {
 	struct islpci_mgmtframe *frame =3D data;
+	struct net_device *ndev =3D frame->ndev;
 	enum oid_num_t n =3D mgt_oidtonum(frame->header->oid);
=20
-	prism54_process_trap_helper(frame->ndev->priv, n, frame->data);
+	prism54_process_trap_helper(netdev_priv(ndev), n, frame->data);
 	islpci_mgt_release(frame);
 }
=20
 int
 prism54_set_mac_address(struct net_device *ndev, void *addr)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	int ret;
=20
 	if (ndev->addr_len !=3D 6)
@@ -1923,7 +1925,7 @@
 prism54_set_wpa(struct net_device *ndev, struct iw_request_info *info,
 		__u32 * uwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
=20
 	down_write(&priv->mib_sem);
=20
@@ -1943,16 +1945,70 @@
 prism54_get_wpa(struct net_device *ndev, struct iw_request_info *info,
 		__u32 * uwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	*uwrq =3D priv->wpa;
 	return 0;
 }
=20
 int
+prism54_set_maxframeburst(struct net_device *ndev, struct iw_request_info =
*info,
+		__u32 *uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	u32 max_burst;
+
+	max_burst =3D (*uwrq) ? *uwrq : CARD_DEFAULT_MAXFRAMEBURST;
+	mgt_set_request(priv, DOT11_OID_MAXFRAMEBURST, 0, &max_burst);
+
+	return -EINPROGRESS; /* Call commit handler */
+}
+
+int
+prism54_get_maxframeburst(struct net_device *ndev, struct iw_request_info =
*info,
+		__u32 *uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	union oid_res_t r;
+	int rvalue;
+=09
+	rvalue =3D mgt_get_request(priv, DOT11_OID_MAXFRAMEBURST, 0, NULL, &r);
+	*uwrq =3D r.u;
+=09
+	return rvalue;
+}
+
+int
+prism54_set_profile(struct net_device *ndev, struct iw_request_info *info,
+		__u32 *uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	u32 profile;
+
+	profile =3D (*uwrq) ? *uwrq : CARD_DEFAULT_PROFILE;
+	mgt_set_request(priv, DOT11_OID_PROFILES, 0, &profile);
+=09
+	return -EINPROGRESS; /* Call commit handler */
+}
+
+int
+prism54_get_profile(struct net_device *ndev, struct iw_request_info *info,
+		__u32 *uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	union oid_res_t r;
+	int rvalue;
+
+	rvalue =3D mgt_get_request(priv, DOT11_OID_PROFILES, 0, NULL, &r);
+	*uwrq =3D r.u;
+
+	return rvalue;
+}
+
+int
 prism54_oid(struct net_device *ndev, struct iw_request_info *info,
 		__u32 *uwrq, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 =09
 	priv->priv_oid =3D *uwrq;
 	printk("%s: oid 0x%08X\n", ndev->name, *uwrq);
@@ -1964,7 +2020,7 @@
 prism54_get_oid(struct net_device *ndev, struct iw_request_info *info,
 		struct iw_point *data, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	struct islpci_mgmtframe *response =3D NULL;
 	int ret =3D -EIO, response_op =3D PIMFOR_OP_ERROR;
 =09
@@ -1998,7 +2054,7 @@
 prism54_set_oid(struct net_device *ndev, struct iw_request_info *info,
 		struct iw_point *data, char *extra)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	struct islpci_mgmtframe *response =3D NULL;
 	int ret =3D 0, response_op =3D PIMFOR_OP_ERROR;
 =09
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.6.5-rc1/drivers/net/wireles=
s/prism54/isl_oid.h linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/isl=
_oid.h
--- linux-2.6.5-rc1/drivers/net/wireless/prism54/isl_oid.h	Tue Mar 16 20:55=
:11 2004
+++ linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/isl_oid.h	Wed Mar 1=
7 01:00:42 2004
@@ -1,7 +1,8 @@
 /*
- *  $Id: isl_oid.h,v 1.2 2004/01/30 16:24:00 ajfa Exp $
+ *  $Id: isl_oid.h,v 1.3 2004/03/09 09:05:27 mcgrof Exp $
  * =20
  *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
+ *  Copyright (C) 2004 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
@@ -142,15 +143,131 @@
 	DOT11_PRIV_TKIP =3D 1
 };
=20
+/* Prism "Nitro" / Frameburst / "Packet Frame Grouping"
+ * Value is in microseconds. Represents the # microseconds
+ * the firmware will take to group frames before sending out then out=20
+ * together with a CSMA contention. Without this all frames are
+ * sent with a CSMA contention.=20
+ * Bibliography:=20
+ * http://www.hpl.hp.com/personal/Jean_Tourrilhes/Papers/Packet.Frame.Grou=
ping.html
+ */
+enum dot11_maxframeburst_t {=20
+	/* Values for DOT11_OID_MAXFRAMEBURST */
+	DOT11_MAXFRAMEBURST_OFF =3D 0, /* Card firmware default */
+	DOT11_MAXFRAMEBURST_MIXED_SAFE =3D 650, /* 802.11 a,b,g safe */
+	DOT11_MAXFRAMEBURST_IDEAL =3D 1300, /* Theoretical ideal level */
+	DOT11_MAXFRAMEBURST_MAX =3D 5000, /* Use this as max,
+		* Note: firmware allows for greater values. This is a
+		* recommended max. I'll update this as I find
+		* out what the real MAX is. Also note that you don't necessarily
+		* get better results with a greater value here.
+		*/
+};
+
+/* Support for 802.11 long and short frame preambles.
+ * Long	 preamble uses 128-bit sync field, 8-bit  CRC
+ * Short preamble uses 56-bit  sync field, 16-bit CRC
+ *=20
+ * 802.11a -- not sure, both optionally ?
+ * 802.11b supports long and optionally short=20
+ * 802.11g supports both */
+enum dot11_preamblesettings_t {
+	DOT11_PREAMBLESETTING_LONG =3D 0,
+		/* Allows *only* long 802.11 preambles */
+	DOT11_PREAMBLESETTING_SHORT =3D 1,
+		/* Allows *only* short 802.11 preambles */
+	DOT11_PREAMBLESETTING_DYNAMIC =3D 2
+		/* AutomatiGically set */
+};
+
+/* Support for 802.11 slot timing (time between packets).
+ *
+ * Long uses 802.11a slot timing  (9 usec ?)
+ * Short uses 802.11b slot timing (20 use ?) */
+enum dot11_slotsettings_t {
+	DOT11_SLOTSETTINGS_LONG =3D 0,=20
+		/* Allows *only* long 802.11b slot timing */
+	DOT11_SLOTSETTINGS_SHORT =3D 1,
+		/* Allows *only* long 802.11a slot timing */
+	DOT11_SLOTSETTINGS_DYNAMIC =3D 2
+		/* AutomatiGically set */
+};
+
+/* All you need to know, ERP is "Extended Rate PHY".
+ * An Extended Rate PHY (ERP) STA or AP shall support three different=20
+ * preamble and header formats:
+ * Long  preamble (refer to above)
+ * Short preamble (refer to above)
+ * OFDM  preamble ( ? )
+ *
+ * I'm assuming here Protection tells the AP
+ * to be careful, a STA which cannot handle the long pre-amble
+ * has joined.
+ */
+enum do11_nonerpstatus_t {
+	DOT11_ERPSTAT_NONEPRESENT =3D 0,
+	DOT11_ERPSTAT_USEPROTECTION =3D 1
+};
+
+/* (ERP is "Extended Rate PHY") Way to read NONERP is NON-ERP-*
+ * The key here is DOT11 NON ERP NEVER protects against
+ * NON ERP STA's. You *don't* want this unless
+ * you know what you are doing. It means you will only=20
+ * get Extended Rate capabilities */
+enum dot11_nonerpprotection_t {
+	DOT11_NONERP_NEVER =3D 0,
+	DOT11_NONERP_ALWAYS =3D 1,
+	DOT11_NONERP_DYNAMIC =3D 2
+};
+
+/* Preset OID configuration for 802.11 modes=20
+ * Note: DOT11_OID_CW[MIN|MAX] hold the values of the=20
+ * DCS MIN|MAX backoff used */
+enum dot11_profile_t { /* And set/allowed values */
+	/* Allowed values for DOT11_OID_PROFILES */
+	DOT11_PROFILE_B_ONLY =3D 0,
+		/* DOT11_OID_RATES: 1, 2, 5.5, 11Mbps=20
+		 * DOT11_OID_PREAMBLESETTINGS: DOT11_PREAMBLESETTING_DYNAMIC
+		 * DOT11_OID_CWMIN: 31
+		 * DOT11_OID_NONEPROTECTION: DOT11_NOERP_DYNAMIC
+		 * DOT11_OID_SLOTSETTINGS: DOT11_SLOTSETTINGS_LONG
+		 */
+	DOT11_PROFILE_MIXED_G_WIFI =3D 1,
+		/* DOT11_OID_RATES: 1, 2, 5.5, 11, 6, 9, 12, 18, 24, 36, 48, 54Mbs
+		 * DOT11_OID_PREAMBLESETTINGS: DOT11_PREAMBLESETTING_DYNAMIC
+		 * DOT11_OID_CWMIN: 15
+		 * DOT11_OID_NONEPROTECTION: DOT11_NOERP_DYNAMIC
+		 * DOT11_OID_SLOTSETTINGS: DOT11_SLOTSETTINGS_DYNAMIC
+		 */
+	DOT11_PROFILE_MIXED_LONG =3D 2, /* "Long range" */
+		/* Same as Profile MIXED_G_WIFI */
+	DOT11_PROFILE_G_ONLY =3D 3,
+		/* Same as Profile MIXED_G_WIFI */
+	DOT11_PROFILE_TEST =3D 4,
+		/* Same as Profile MIXED_G_WIFI except:
+		 * DOT11_OID_PREAMBLESETTINGS: DOT11_PREAMBLESETTING_SHORT
+		 * DOT11_OID_NONEPROTECTION: DOT11_NOERP_NEVER
+		 * DOT11_OID_SLOTSETTINGS: DOT11_SLOTSETTINGS_SHORT
+		 */
+	DOT11_PROFILE_B_WIFI =3D 5,
+		/* Same as Profile B_ONLY */
+	DOT11_PROFILE_A_ONLY =3D 6,
+		/* Same as Profile MIXED_G_WIFI except:
+		 * DOT11_OID_RATES: 6, 9, 12, 18, 24, 36, 48, 54Mbs
+		 */
+	DOT11_PROFILE_MIXED_SHORT =3D 7
+		/* Same as MIXED_G_WIFI */
+};
+
+
 /* The dot11d conformance level configures the 802.11d conformance levels.
  * The following conformance levels exist:*/
 enum oid_inl_conformance_t {
 	OID_INL_CONFORMANCE_NONE =3D 0,	/* Perform active scanning */
 	OID_INL_CONFORMANCE_STRICT =3D 1,	/* Strictly adhere to 802.11d */
 	OID_INL_CONFORMANCE_FLEXIBLE =3D 2,	/* Use passed 802.11d info to
-						 * determine channel AND/OR just make=20
-						 * assumption that active=20
-						 * channels are valid  channels */
+		* determine channel AND/OR just make assumption that active=20
+		* channels are valid  channels */
 };
=20
 enum oid_inl_mode_t {
@@ -176,6 +293,7 @@
 	INL_PHYCAP_FAA =3D 0x80000000,	/* Means card supports the FAA switch */
 };
=20
+
 enum oid_num_t {
 	GEN_OID_MACADDRESS =3D 0,
 	GEN_OID_LINKSTATE,
@@ -269,8 +387,8 @@
 	DOT11_OID_FRAMEABORTSPHY,
=20
 	DOT11_OID_SLOTTIME,
-	DOT11_OID_CWMIN,
-	DOT11_OID_CWMAX,
+	DOT11_OID_CWMIN, /* MIN DCS backoff */
+	DOT11_OID_CWMAX, /* MAX DCS backoff */
 	DOT11_OID_ACKWINDOW,
 	DOT11_OID_ANTENNARX,
 	DOT11_OID_ANTENNATX,
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.6.5-rc1/drivers/net/wireles=
s/prism54/islpci_dev.c linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/=
islpci_dev.c
--- linux-2.6.5-rc1/drivers/net/wireless/prism54/islpci_dev.c	Tue Mar 16 20=
:55:11 2004
+++ linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/islpci_dev.c	Wed Ma=
r 17 01:00:42 2004
@@ -245,7 +245,7 @@
 islpci_open(struct net_device *ndev)
 {
 	u32 rc;
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
=20
 	printk(KERN_DEBUG "%s: islpci_open()\n", ndev->name);
=20
@@ -265,7 +265,7 @@
 static int
 islpci_close(struct net_device *ndev)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
=20
 	printk(KERN_DEBUG "%s: islpci_close ()\n", ndev->name);
=20
@@ -491,7 +491,7 @@
 struct net_device_stats *
 islpci_statistics(struct net_device *ndev)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
=20
 #if VERBOSE > SHOW_ERROR_MESSAGES
 	DEBUG(SHOW_FUNCTION_CALLS, "islpci_statistics \n");
@@ -577,6 +577,7 @@
 		if (!(skb =3D dev_alloc_skb(MAX_FRAGMENT_SIZE_RX + 2))) {
 			/* error allocating an sk_buff structure elements */
 			printk(KERN_ERR "Error allocating skb.\n");
+			skb =3D NULL;
 			goto out_free;
 		}
 		/* add the new allocated sk_buff to the buffer array */
@@ -711,7 +712,7 @@
 #endif
=20
 	/* allocate a private device structure to the network device  */
-	priv =3D ndev->priv;
+	priv =3D netdev_priv(ndev);
 	priv->ndev =3D ndev;
 	priv->pdev =3D pdev;
=20
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.6.5-rc1/drivers/net/wireles=
s/prism54/islpci_eth.c linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/=
islpci_eth.c
--- linux-2.6.5-rc1/drivers/net/wireless/prism54/islpci_eth.c	Tue Mar 16 20=
:55:11 2004
+++ linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/islpci_eth.c	Wed Ma=
r 17 01:00:42 2004
@@ -63,6 +63,7 @@
 					 priv->pci_map_tx_address[index],
 					 skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb_irq(skb);
+			skb =3D NULL;
 		}
 		/* increment the free data low queue pointer */
 		priv->free_data_tx++;
@@ -72,7 +73,7 @@
 int
 islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	isl38xx_control_block *cb =3D priv->control_block;
 	u32 index;
 	dma_addr_t pci_map_address;
@@ -238,6 +239,7 @@
  drop_free:
 	/* free the skbuf structure before aborting */
 	dev_kfree_skb(skb);
+	skb =3D NULL;
=20
 	priv->statistics.tx_dropped++;
 	spin_unlock_irqrestore(&priv->slock, flags);
@@ -346,8 +348,10 @@
 	     skb->data[0], skb->data[1], skb->data[2], skb->data[3],
 	     skb->data[4], skb->data[5]);
 #endif
-	if (discard)
+	if (discard) {
 		dev_kfree_skb(skb);
+		skb =3D NULL;
+	}
 	else
 		netif_rx(skb);
=20
@@ -388,6 +392,7 @@
=20
 			/* free the skbuf structure before aborting */
 			dev_kfree_skb((struct sk_buff *) skb);
+			skb =3D NULL;
 			break;
 		}
 		/* update the fragment address */
@@ -411,7 +416,7 @@
 void
 islpci_eth_tx_timeout(struct net_device *ndev)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	struct net_device_stats *statistics =3D &priv->statistics;
=20
 	/* increment the transmit error counter */
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.6.5-rc1/drivers/net/wireles=
s/prism54/islpci_hotplug.c linux-2.6.5-rc1-mcgrof/drivers/net/wireless/pris=
m54/islpci_hotplug.c
--- linux-2.6.5-rc1/drivers/net/wireless/prism54/islpci_hotplug.c	Tue Mar 1=
6 20:55:11 2004
+++ linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/islpci_hotplug.c	We=
d Mar 17 01:00:42 2004
@@ -29,10 +29,10 @@
 #include "isl_oid.h"
=20
 #define DRV_NAME	"prism54"
-#define DRV_VERSION	"1.0.2.2"
+#define DRV_VERSION	"1.1"
=20
-MODULE_AUTHOR("W.Termorshuizen, R.Bastings, H.V.Riedel, prism54.org team");
-MODULE_DESCRIPTION("Intersil 802.11 Wireless LAN adapter");
+MODULE_AUTHOR("[Intersil] R.Bastings and W.Termorshuizen, The prism54.org =
Development Team <prism54-devel@prism54.org>");
+MODULE_DESCRIPTION("The Prism54 802.11 Wireless LAN adapter");
 MODULE_LICENSE("GPL");
=20
 /* In this order: vendor, device, subvendor, subdevice, class, class_mask,
@@ -97,6 +97,11 @@
 	 0, 0,
 	 (unsigned long) "SMC 2802Wv2"},
 	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCIVENDOR_SMC, 0xa835UL,
+	 0, 0,
+	 (unsigned long) "SMC 2835Wv2"},
+	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3877,
 	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0,
@@ -133,7 +138,7 @@
 	islpci_private	*priv;
 	char		*modelp;
=20
-	priv =3D ndev->priv;
+	priv =3D netdev_priv(ndev);
 	switch (priv->pdev->subsystem_device) {
 	case PCIDEVICE_ISL3877:
 		modelp =3D "PRISM Indigo";
@@ -159,6 +164,9 @@
 	case 0x2835UL:
 		modelp =3D "SMC2835W";
 		break;
+	case 0xa835UL:
+		modelp =3D "SMC2835W V2";
+		break;
 	/* Let's leave this one out for now since it seems bogus/wrong=20
 	 * Even if the manufacturer did use 0x0000UL it may not be correct
 	 * by their part, therefore deserving no name ;) */
@@ -269,7 +277,7 @@
 		goto do_pci_release_regions;
 	}
=20
-	priv =3D ndev->priv;
+	priv =3D netdev_priv(ndev);
 	islpci_set_state(priv, PRV_STATE_PREBOOT); /* we are attempting to boot */
=20
 	/* card is in unknown state yet, might have some interrupts pending */
@@ -314,7 +322,7 @@
 prism54_remove(struct pci_dev *pdev)
 {
 	struct net_device *ndev =3D pci_get_drvdata(pdev);
-	islpci_private *priv =3D ndev ? ndev->priv : 0;
+	islpci_private *priv =3D ndev ? netdev_priv(ndev) : 0;
 	BUG_ON(!priv);
=20
 	if (!__in_cleanup_module) {
@@ -355,7 +363,7 @@
 prism54_suspend(struct pci_dev *pdev, u32 state)
 {
 	struct net_device *ndev =3D pci_get_drvdata(pdev);
-	islpci_private *priv =3D ndev ? ndev->priv : 0;
+	islpci_private *priv =3D ndev ? netdev_priv(ndev) : 0;
 	BUG_ON(!priv);
=20
 	printk(KERN_NOTICE "%s: got suspend request (state %d)\n",
@@ -380,7 +388,7 @@
 prism54_resume(struct pci_dev *pdev)
 {
 	struct net_device *ndev =3D pci_get_drvdata(pdev);
-	islpci_private *priv =3D ndev ? ndev->priv : 0;
+	islpci_private *priv =3D ndev ? netdev_priv(ndev) : 0;
 	BUG_ON(!priv);
=20
 	printk(KERN_NOTICE "%s: got resume request\n", ndev->name);
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.6.5-rc1/drivers/net/wireles=
s/prism54/islpci_mgt.c linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/=
islpci_mgt.c
--- linux-2.6.5-rc1/drivers/net/wireless/prism54/islpci_mgt.c	Tue Mar 16 20=
:55:11 2004
+++ linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/islpci_mgt.c	Wed Ma=
r 17 01:00:42 2004
@@ -22,6 +22,7 @@
 #include <linux/netdevice.h>
 #include <linux/module.h>
 #include <linux/pci.h>
+#include <linux/moduleparam.h>
=20
 #include <asm/io.h>
 #include <asm/system.h>
@@ -38,7 +39,7 @@
         Global variable definition section
 **************************************************************************=
****/
 int pc_debug =3D VERBOSE;
-MODULE_PARM(pc_debug, "i");
+module_param(pc_debug, int, 0);
=20
 /*************************************************************************=
*****
     Driver general functions
@@ -106,7 +107,7 @@
 int
 islpci_mgmt_rx_fill(struct net_device *ndev)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	isl38xx_control_block *cb =3D    /* volatile not needed */
 		(isl38xx_control_block *) priv->control_block;
 	u32 curr =3D le32_to_cpu(cb->driver_curr_frag[ISL38XX_CB_RX_MGMTQ]);
@@ -165,7 +166,7 @@
 islpci_mgt_transmit(struct net_device *ndev, int operation, unsigned long =
oid,
 		    void *data, int length)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	isl38xx_control_block *cb =3D
 		(isl38xx_control_block *) priv->control_block;
 	void *p;
@@ -271,7 +272,7 @@
 int
 islpci_mgt_receive(struct net_device *ndev)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	isl38xx_control_block *cb =3D
 		(isl38xx_control_block *) priv->control_block;
 	u32 curr_frag;
@@ -414,7 +415,7 @@
 void
 islpci_mgt_cleanup_transmit(struct net_device *ndev)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	isl38xx_control_block *cb =3D    /* volatile not needed */
 		(isl38xx_control_block *) priv->control_block;
 	u32 curr_frag;
@@ -451,7 +452,7 @@
 		       void *senddata, int sendlen,
 		       struct islpci_mgmtframe **recvframe)
 {
-	islpci_private *priv =3D ndev->priv;
+	islpci_private *priv =3D netdev_priv(ndev);
 	const long wait_cycle_jiffies =3D (ISL38XX_WAIT_CYCLE * 10 * HZ) / 1000;
 	long timeout_left =3D ISL38XX_MAX_WAIT_CYCLES * wait_cycle_jiffies;
 	int err;
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.6.5-rc1/drivers/net/wireles=
s/prism54/islpci_mgt.h linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/=
islpci_mgt.h
--- linux-2.6.5-rc1/drivers/net/wireless/prism54/islpci_mgt.h	Tue Mar 16 20=
:55:11 2004
+++ linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/islpci_mgt.h	Wed Ma=
r 17 01:00:42 2004
@@ -87,11 +87,13 @@
 #define CARD_DEFAULT_KEY4                       "default_key_4"
 #define CARD_DEFAULT_WEP                        0
 #define CARD_DEFAULT_FILTER                     0
-# define CARD_DEFAULT_WDS                        0
+#define CARD_DEFAULT_WDS                        0
 #define	CARD_DEFAULT_AUTHEN                     DOT11_AUTH_OS
 #define	CARD_DEFAULT_DOT1X			0
 #define CARD_DEFAULT_MLME_MODE			DOT11_MLME_AUTO
 #define CARD_DEFAULT_CONFORMANCE                OID_INL_CONFORMANCE_NONE
+#define CARD_DEFAULT_PROFILE			DOT11_PROFILE_MIXED_G_WIFI
+#define CARD_DEFAULT_MAXFRAMEBURST		DOT11_MAXFRAMEBURST_MIXED_SAFE
=20
 /* PIMFOR package definitions */
 #define PIMFOR_ETHERTYPE                        0x8828
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.6.5-rc1/drivers/net/wireles=
s/prism54/oid_mgt.c linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/oid=
_mgt.c
--- linux-2.6.5-rc1/drivers/net/wireless/prism54/oid_mgt.c	Tue Mar 16 20:55=
:11 2004
+++ linux-2.6.5-rc1-mcgrof/drivers/net/wireless/prism54/oid_mgt.c	Wed Mar 1=
7 01:00:42 2004
@@ -97,7 +97,7 @@
 	[DOT11_OID_ALOFT_CONFIG] =3D OID_UNKNOWN(0x1d000006),
=20
 	[DOT11_OID_VDCFX] =3D {0x1b000000, 7, 0, 0},
-	[DOT11_OID_MAXFRAMEBURST] =3D OID_U32(0x1b000008),
+	[DOT11_OID_MAXFRAMEBURST] =3D OID_U32(0x1b000008), /* in microseconds */
=20
 	[DOT11_OID_PSM] =3D OID_U32(0x14000000),
 	[DOT11_OID_CAMTIMEOUT] =3D OID_U32(0x14000001),

--kH8JNVvasRCCW1Oz--

--+9faIjRurCDpBc7U
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAV/ILat1JN+IKUl4RAhOrAKCMAR7Uy1/c+B+96GABgaGyIacfhgCfX+EW
7/l9ooML5RfZxeXguFthFCk=
=5FuO
-----END PGP SIGNATURE-----

--+9faIjRurCDpBc7U--
