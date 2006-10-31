From: chunkeey@web.de
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Tue, 31 Oct 2006 18:53:21 +0100
Message-ID: <200610311853.21566.chunkeey@web.de>
References: <200610031457.33215.chunkeey@web.de> <43e72e890610301217g28d169eeu448944e170153948@mail.gmail.com> <1162310754.3155.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_R24RFAeYx9cH2y/"
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:36045 "EHLO
	fmmailgate02.web.de") by vger.kernel.org with ESMTP
	id S1423706AbWJaR4d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 12:56:33 -0500
Received: from smtp05.web.de (fmsmtp05.dlan.cinetic.de [172.20.4.166])
	by fmmailgate02.web.de (Postfix) with ESMTP id AB191301ADB2
	for <netdev@vger.kernel.org>; Tue, 31 Oct 2006 18:56:31 +0100 (CET)
Received: from [84.157.243.66] (helo=debian64.daheim)
	by smtp05.web.de with asmtp (TLSv1:AES256-SHA:256)
	(WEB.DE 4.107 #114)
	id 1Gexqe-0002S0-00
	for netdev@vger.kernel.org; Tue, 31 Oct 2006 18:56:29 +0100
Received: from localhost.localdomain
	([127.0.0.1] helo=localhost ident=chuck)
	by debian64.daheim with esmtpa (Exim 4.63)
	(envelope-from <chunkeey@web.de>)
	id 1Gexqe-0007Fg-55
	for netdev@vger.kernel.org; Tue, 31 Oct 2006 18:56:28 +0100
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1162310754.3155.18.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_R24RFAeYx9cH2y/
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

31. Oct 2006 17:05 Dan Williams wrote:
> On Mon, 2006-10-30 at 15:17 -0500, Luis R. Rodriguez wrote:
> > On 10/29/06, chunkeey@web.de <chunkeey@web.de> wrote:
> > > This patch completes WPA/RSN with TKIP support for all fullmac prism54
> > > cards. I removed all parts which are not relevant for wpa_supplicant
> > > (managed mode).
> >
> > This is great effort and thanks for it! My only concern with the patch
> > is breaking compatiblity with 2.4 but then again I'm tired of having
> > to keep this compat work up too and soon, after d80211 full force push
> > it may not be possible. So I ACK it.
>
> I'd like to test it a bit first with my fullmac card before it gets
> committed/added...  But it's great to get some movement on this
> card/driver!
>
> Dan
>

Dan, the patch was made for this git-tree:
git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git

BTW, here's a little update:
removes (all) duplicated constants and some "home-grown" definitions

Oh, is there a "#definition" for 40Bit-WEP keys? I only found one for 104Bit
and one for SCM.


Christian

--Boundary-00=_R24RFAeYx9cH2y/
Content-Type: text/x-diff;
  charset="iso-8859-15";
  name="prism-wpa-wl26git4.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="prism-wpa-wl26git4.patch"

diff --git a/drivers/net/wireless/prism54/isl_38xx.c b/drivers/net/wireless=
/prism54/isl_38xx.c
index 02fc67b..044a23f 100644
=2D-- a/drivers/net/wireless/prism54/isl_38xx.c
+++ b/drivers/net/wireless/prism54/isl_38xx.c
@@ -24,7 +24,6 @@ #include <linux/delay.h>
 #include <asm/uaccess.h>
 #include <asm/io.h>
=20
=2D#include "prismcompat.h"
 #include "isl_38xx.h"
 #include "islpci_dev.h"
 #include "islpci_mgt.h"
diff --git a/drivers/net/wireless/prism54/isl_38xx.h b/drivers/net/wireless=
/prism54/isl_38xx.h
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireles=
s/prism54/isl_ioctl.c
index 4a20e45..126a85e 100644
=2D-- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -3,6 +3,7 @@
  *            (C) 2003,2004 Aurelien Alleaume <slts@free.fr>
  *            (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
  *            (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
+ *            (C) 2006 Christian Lamparter <chunkeey@web.de>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
@@ -26,18 +27,13 @@ #include <linux/pci.h>
=20
 #include <asm/uaccess.h>
=20
=2D#include "prismcompat.h"
 #include "isl_ioctl.h"
 #include "islpci_mgt.h"
 #include "isl_oid.h"		/* additional types and defs for isl38xx fw */
 #include "oid_mgt.h"
=20
 #include <net/iw_handler.h>	/* New driver API */
=2D
=2D#define KEY_SIZE_WEP104 13	/* 104/128-bit WEP keys */
=2D#define KEY_SIZE_WEP40  5	/* 40/64-bit WEP keys */
=2D/* KEY_SIZE_TKIP should match isl_oid.h, struct obj_key.key[] size */
=2D#define KEY_SIZE_TKIP   32	/* TKIP keys */
+#include <net/ieee80211.h>
=20
 static void prism54_wpa_bss_ie_add(islpci_private *priv, u8 *bssid,
 				u8 *wpa_ie, size_t wpa_ie_len);
@@ -45,11 +41,6 @@ static size_t prism54_wpa_bss_ie_get(isl
 static int prism54_set_wpa(struct net_device *, struct iw_request_info *,
 				__u32 *, char *);
=20
=2D/* In 500 kbps */
=2Dstatic const unsigned char scan_rate_list[] =3D { 2, 4, 11, 22,
=2D						12, 18, 24, 36,
=2D						48, 72, 96, 108 };
=2D
 /**
  * prism54_mib_mode_helper - MIB change mode helper function
  * @mib: the &struct islpci_mib object to modify
@@ -167,14 +158,16 @@ prism54_update_stats(islpci_private *pri
 	if (down_interruptible(&priv->stats_sem))
 		return;
=20
=2D/* Noise floor.
=2D * I'm not sure if the unit is dBm.
=2D * Note : If we are not connected, this value seems to be irrelevant. */
+	/* Noise floor.
+	 * I'm not sure if the unit is dBm.
+
+	 * Note :
+	 * If we are not connected, this value seems to be irrelevant. */
=20
 	mgt_get_request(priv, DOT11_OID_NOISEFLOOR, 0, NULL, &r);
 	priv->local_iwstatistics.qual.noise =3D r.u;
=20
=2D/* Get the rssi of the link. To do this we need to retrieve a bss. */
+	/* Get the rssi of the link. To do this we need to retrieve a bss. */
=20
 	/* First get the MAC address of the AP we are associated with. */
 	mgt_get_request(priv, DOT11_OID_BSSID, 0, NULL, &r);
@@ -199,11 +192,11 @@ prism54_update_stats(islpci_private *pri
 	/* report that the stats are new */
 	priv->local_iwstatistics.qual.updated =3D 0x7;
=20
=2D/* Rx : unable to decrypt the MPDU */
+	/* Rx : unable to decrypt the MPDU */
 	mgt_get_request(priv, DOT11_OID_PRIVRXFAILED, 0, NULL, &r);
 	priv->local_iwstatistics.discard.code =3D r.u;
=20
=2D/* Tx : Max MAC retries num reached */
+	/* Tx : Max MAC retries num reached */
 	mgt_get_request(priv, DOT11_OID_MPDUTXFAILED, 0, NULL, &r);
 	priv->local_iwstatistics.discard.retries =3D r.u;
=20
@@ -227,7 +220,7 @@ prism54_get_wireless_stats(struct net_de
 	} else
 		priv->iwstatistics.qual.updated =3D 0;
=20
=2D	/* Update our wireless stats, but do not schedule to often
+	/* Update our wireless stats, but do not schedule too often
 	 * (max 1 HZ) */
 	if ((priv->stats_timestamp =3D=3D 0) ||
 	    time_after(jiffies, priv->stats_timestamp + 1 * HZ)) {
@@ -414,6 +407,8 @@ prism54_get_sens(struct net_device *ndev
 	return rvalue;
 }
=20
+#define WEP40_KEY_LEN 5	/* 40/64-bit WEP keys */
+
 static int
 prism54_get_range(struct net_device *ndev, struct iw_request_info *info,
 		  struct iw_point *dwrq, char *extra)
@@ -435,11 +430,11 @@ prism54_get_range(struct net_device *nde
 	/* Now the encoding capabilities */
 	range->num_encoding_sizes =3D 3;
 	/* 64(40) bits WEP */
=2D	range->encoding_size[0] =3D 5;
+	range->encoding_size[0] =3D WEP40_KEY_LEN;
 	/* 128(104) bits WEP */
=2D	range->encoding_size[1] =3D 13;
+	range->encoding_size[1] =3D WEP_KEY_LEN;
 	/* 256 bits for WPA-PSK */
=2D	range->encoding_size[2] =3D 32;
+	range->encoding_size[2] =3D SCM_KEY_LEN;
 	/* 4 keys are allowed */
 	range->max_encoding_tokens =3D 4;
=20
@@ -565,6 +560,11 @@ prism54_set_scan(struct net_device *dev,
 	return 0;
 }
=20
+/* In 500 kbps */
+static const unsigned char scan_rate_list[] =3D { 2, 4, 11, 22,
+						12, 18, 24, 36,
+						48, 72, 96, 108 };
+
 /* a little helper that will translate our data into a card independent
  * format that the Wireless Tools will understand. This was inspired by
  * the "Aironet driver for 4500 and 4800 series cards" (GPL)
@@ -596,17 +596,12 @@ prism54_translate_bss(struct net_device
 	current_ev =3D iwe_stream_add_point(current_ev, end_buf,
 					  &iwe, bss->ssid.octets);
=20
=2D	/* Capabilities */
=2D#define CAP_ESS 0x01
=2D#define CAP_IBSS 0x02
=2D#define CAP_CRYPT 0x10
=2D
 	/* Mode */
 	cap =3D bss->capinfo;
 	iwe.u.mode =3D 0;
=2D	if (cap & CAP_ESS)
+	if (cap & WLAN_CAPABILITY_ESS)
 		iwe.u.mode =3D IW_MODE_MASTER;
=2D	else if (cap & CAP_IBSS)
+	else if (cap & WLAN_CAPABILITY_IBSS)
 		iwe.u.mode =3D IW_MODE_ADHOC;
 	iwe.cmd =3D SIOCGIWMODE;
 	if (iwe.u.mode)
@@ -615,7 +610,7 @@ #define CAP_CRYPT 0x10
 					 IW_EV_UINT_LEN);
=20
 	/* Encryption capability */
=2D	if (cap & CAP_CRYPT)
+	if (cap & WLAN_CAPABILITY_PRIVACY)
 		iwe.u.data.flags =3D IW_ENCODE_ENABLED | IW_ENCODE_NOKEY;
 	else
 		iwe.u.data.flags =3D IW_ENCODE_DISABLED;
@@ -875,15 +870,6 @@ prism54_set_rate(struct net_device *ndev
 		data[1] =3D 0;
 	}
=20
=2D/*
=2D	i =3D 0;
=2D	printk("prism54 rate: ");
=2D	while(data[i]) {
=2D		printk("%u ", data[i]);
=2D		i++;
=2D	}
=2D	printk("0\n");
=2D*/
 	profile =3D -1;
 	ret =3D mgt_set_request(priv, DOT11_OID_PROFILES, 0, &profile);
 	ret |=3D mgt_set_request(priv, DOT11_OID_EXTENDEDRATES, 0, data);
@@ -1052,18 +1038,58 @@ prism54_get_retry(struct net_device *nde
 }
=20
 static int
+prism54_set_auth_alg(islpci_private *priv,	u32 flag)
+{
+	int authen =3D DOT11_AUTH_NONE, invoke =3D 0, exunencrypt =3D 0;
+	int ret;
+
+	if (flag & IW_ENCODE_RESTRICTED) {
+		authen =3D DOT11_AUTH_SK;
+		invoke =3D 1;
+		exunencrypt =3D 1;
+	}
+
+	if (flag & IW_ENCODE_OPEN) {
+		authen =3D DOT11_AUTH_OS;
+		invoke =3D 1;
+	/*
+	This is very wrong here, but we've to ensure bug-to-bug compatibility.
+
+	If we set exunencrypt, the Firmware adds the "Privacy" flag to the
+	Capability Information, which is misreaded by many STA/AP as
+	"the device supports WEP, WPA and WPA2"
+	*/
+		exunencrypt =3D 1;=20
+	}
+
+	ret =3D
+	    mgt_set_request(priv, DOT11_OID_AUTHENABLE,
+				0, &authen);
+	ret |=3D
+	    mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED,
+				0, &invoke);
+	ret |=3D
+	    mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED,
+				0,&exunencrypt);
+
+	return ret;
+}
+
+static int
 prism54_set_encode(struct net_device *ndev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
 	islpci_private *priv =3D netdev_priv(ndev);
=2D	int rvalue =3D 0, force =3D 0;
=2D	int authen =3D DOT11_AUTH_OS, invoke =3D 0, exunencrypt =3D 0;
+	int rvalue =3D 0, flags =3D dwrq->flags;
 	union oid_res_t r;
=20
 	/* with the new API, it's impossible to get a NULL pointer.
 	 * New version of iwconfig set the IW_ENCODE_NOKEY flag
 	 * when no key is given, but older versions don't. */
=20
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return -EINVAL;
+
 	if (dwrq->length > 0) {
 		/* we have a key to set */
 		int index =3D (dwrq->flags & IW_ENCODE_INDEX) - 1;
@@ -1071,27 +1097,27 @@ prism54_set_encode(struct net_device *nd
 		struct obj_key key =3D { DOT11_PRIV_WEP, 0, "" };
=20
 		/* get the current key index */
=2D		rvalue =3D mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+		rvalue |=3D mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
 		current_index =3D r.u;
 		/* Verify that the key is not marked as invalid */
 		if (!(dwrq->flags & IW_ENCODE_NOKEY)) {
=2D			if (dwrq->length > KEY_SIZE_TKIP) {
+			if (dwrq->length > MAX_KEY_LEN) {
 				/* User-provided key data too big */
 				return -EINVAL;
 			}
=2D			if (dwrq->length > KEY_SIZE_WEP104) {
+			if (dwrq->length > WEP_KEY_LEN) {
 				/* WPA-PSK TKIP */
 				key.type =3D DOT11_PRIV_TKIP;
=2D				key.length =3D KEY_SIZE_TKIP;
=2D			} else if (dwrq->length > KEY_SIZE_WEP40) {
+				key.length =3D MAX_KEY_LEN;
+			} else if (dwrq->length > WEP40_KEY_LEN) {
 				/* WEP 104/128 */
=2D				key.length =3D KEY_SIZE_WEP104;
+				key.length =3D WEP_KEY_LEN;
 			} else {
 				/* WEP 40/64 */
=2D				key.length =3D KEY_SIZE_WEP40;
+				key.length =3D WEP40_KEY_LEN;
 			}
 			memset(key.key, 0, sizeof (key.key));
=2D			memcpy(key.key, extra, dwrq->length);
+			memcpy(key.key, extra, key.length);
=20
 			if ((index < 0) || (index > 3))
 				/* no index provided use the current one */
@@ -1108,95 +1134,111 @@ prism54_set_encode(struct net_device *nd
 		 * This is also how "iwconfig ethX key on" works
 		 */
 		if ((index =3D=3D current_index) && (key.length > 0))
=2D			force =3D 1;
+			flags |=3D IW_ENCODE_RESTRICTED;
 	} else {
=2D		int index =3D (dwrq->flags & IW_ENCODE_INDEX) - 1;
+		int index =3D (flags & IW_ENCODE_INDEX) - 1;
 		if ((index >=3D 0) && (index <=3D 3)) {
 			/* we want to set the key index */
 			rvalue |=3D
 			    mgt_set_request(priv, DOT11_OID_DEFKEYID, 0,
 					    &index);
 		} else {
=2D			if (!dwrq->flags & IW_ENCODE_MODE) {
+			if (!(flags & IW_ENCODE_MODE)) {
 				/* we cannot do anything. Complain. */
 				return -EINVAL;
 			}
 		}
 	}
=2D	/* now read the flags */
=2D	if (dwrq->flags & IW_ENCODE_DISABLED) {
=2D		/* Encoding disabled,
=2D		 * authen =3D DOT11_AUTH_OS;
=2D		 * invoke =3D 0;
=2D		 * exunencrypt =3D 0; */
=2D	}
=2D	if (dwrq->flags & IW_ENCODE_OPEN)
=2D		/* Encode but accept non-encoded packets. No auth */
=2D		invoke =3D 1;
=2D	if ((dwrq->flags & IW_ENCODE_RESTRICTED) || force) {
=2D		/* Refuse non-encoded packets. Auth */
=2D		authen =3D DOT11_AUTH_BOTH;
=2D		invoke =3D 1;
=2D		exunencrypt =3D 1;
=2D	}
 	/* do the change if requested  */
=2D	if ((dwrq->flags & IW_ENCODE_MODE) || force) {
=2D		rvalue |=3D
=2D		    mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
=2D		rvalue |=3D
=2D		    mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &invoke);
=2D		rvalue |=3D
=2D		    mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0,
=2D				    &exunencrypt);
=2D	}
+	if (flags & IW_ENCODE_MODE)
+		rvalue =3D prism54_set_auth_alg(priv, flags);
+
 	return rvalue;
 }
=20
 static int
+prism54_get_auth_algs(islpci_private *priv)
+{
+	u32 authen =3D 0, invoke =3D 0, exunencrypt =3D 0;
+	union oid_res_t r;
+	int ret =3D 0;
+
+	ret =3D mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
+	authen =3D r.u;
+	ret |=3D mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
+	invoke =3D r.u;
+	ret |=3D mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
+	exunencrypt =3D r.u;
+
+	if (ret)
+		return ret;
+
+	if (invoke && exunencrypt &&
+		((authen =3D=3D DOT11_AUTH_SK) || (authen =3D=3D DOT11_AUTH_BOTH)))
+			ret =3D IW_ENCODE_RESTRICTED | IW_ENCODE_ENABLED;
+	else if ((authen =3D=3D DOT11_AUTH_OS)) {
+		if (invoke)
+			ret =3D IW_ENCODE_OPEN | IW_ENCODE_ENABLED;
+		else {
+			ret =3D IW_ENCODE_DISABLED;
+			}
+	}
+	else {
+		ret =3D IW_ENCODE_DISABLED;
+	}
+
+	return ret;
+}
+
+static int
 prism54_get_encode(struct net_device *ndev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
 	islpci_private *priv =3D netdev_priv(ndev);
 	struct obj_key *key;
 	u32 devindex, index =3D (dwrq->flags & IW_ENCODE_INDEX) - 1;
=2D	u32 authen =3D 0, invoke =3D 0, exunencrypt =3D 0;
=2D	int rvalue;
+	int rvalue =3D 0, flags;
 	union oid_res_t r;
=20
+	if (islpci_get_state(priv) < PRV_STATE_INIT) {
+		dwrq->flags =3D IW_ENCODE_DISABLED;
+		dwrq->length =3D 0;
+		return 0;
+		}
+
 	/* first get the flags */
=2D	rvalue =3D mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
=2D	authen =3D r.u;
=2D	rvalue |=3D mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r=
);
=2D	invoke =3D r.u;
=2D	rvalue |=3D mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
=2D	exunencrypt =3D r.u;
+	if ((flags =3D prism54_get_auth_algs(priv)) < 0)
+		return rvalue;=09
=20
=2D	if (invoke && (authen =3D=3D DOT11_AUTH_BOTH) && exunencrypt)
=2D		dwrq->flags =3D IW_ENCODE_RESTRICTED;
=2D	else if ((authen =3D=3D DOT11_AUTH_OS) && !exunencrypt) {
=2D		if (invoke)
=2D			dwrq->flags =3D IW_ENCODE_OPEN;
=2D		else
=2D			dwrq->flags =3D IW_ENCODE_DISABLED;
=2D	} else
=2D		/* The card should not work in this state */
=2D		dwrq->flags =3D 0;
+	memset(extra, 0x0, dwrq->length);
+	dwrq->flags =3D flags;
=20
=2D	/* get the current device key index */
=2D	rvalue |=3D mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
=2D	devindex =3D r.u;
=2D	/* Now get the key, return it */
=2D	if ((index < 0) || (index > 3))
=2D		/* no index provided, use the current one */
=2D		index =3D devindex;
=2D	rvalue |=3D mgt_get_request(priv, DOT11_OID_DEFKEYX, index, NULL, &r);
=2D	key =3D r.ptr;
=2D	dwrq->length =3D key->length;
=2D	memcpy(extra, key->key, dwrq->length);
=2D	kfree(key);
=2D	/* return the used key index */
=2D	dwrq->flags |=3D devindex + 1;
+	if (flags !=3D IW_ENCODE_DISABLED) {
+		/* get the current device key index */
+		rvalue =3D mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+		devindex =3D r.u;
=20
+		/* Now get the key, return it */
+		if ((index < 0) || (index > 3))
+			/* no index provided, use the current one */
+			index =3D devindex;
+
+		rvalue |=3D mgt_get_request(priv, DOT11_OID_DEFKEYX, index, NULL, &r);
+		key =3D r.ptr;
+
+		if (dwrq->length < key->length) {
+			kfree(key);
+			return -EINVAL;
+		}
+
+		dwrq->length =3D key->length;
+		memcpy(extra, key->key, dwrq->length);
+		kfree(key);
+		/* return the used key index */
+		dwrq->flags |=3D devindex + 1;
+	} else
+		rvalue =3D 0;
+=09
 	return rvalue;
 }
=20
@@ -1212,7 +1254,7 @@ prism54_get_txpower(struct net_device *n
 	/* intersil firmware operates in 0.25 dBm (1/4 dBm) */
 	vwrq->value =3D (s32) r.u / 4;
 	vwrq->fixed =3D 1;
=2D	/* radio is not turned of
+	/* radio is not turned off
 	 * btw: how is possible to turn off only the radio
 	 */
 	vwrq->disabled =3D 0;
@@ -1246,9 +1288,9 @@ prism54_set_txpower(struct net_device *n
 	}
 }
=20
=2Dstatic int prism54_set_genie(struct net_device *ndev,
=2D			     struct iw_request_info *info,
=2D			     struct iw_point *data, char *extra)
+static int=20
+prism54_set_genie(struct net_device *ndev, struct iw_request_info *info,
+		  struct iw_point *data, char *extra)
 {
 	islpci_private *priv =3D netdev_priv(ndev);
 	int alen, ret =3D 0;
@@ -1258,6 +1300,9 @@ static int prism54_set_genie(struct net_
 	    (data->length && extra =3D=3D NULL))
 		return -EINVAL;
=20
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return -EINVAL;
+
 	memcpy(priv->wpa_ie, extra, data->length);
 	priv->wpa_ie_len =3D data->length;
=20
@@ -1266,28 +1311,26 @@ static int prism54_set_genie(struct net_
 	if (attach =3D=3D NULL)
 		return -ENOMEM;
=20
=2D#define WLAN_FC_TYPE_MGMT 0
=2D#define WLAN_FC_STYPE_ASSOC_REQ 0
=2D#define WLAN_FC_STYPE_REASSOC_REQ 2
=2D
 	/* Note: endianness is covered by mgt_set_varlen */
=2D	attach->type =3D (WLAN_FC_TYPE_MGMT << 2) |
=2D               (WLAN_FC_STYPE_ASSOC_REQ << 4);
=2D	attach->id =3D -1;
=2D	attach->size =3D priv->wpa_ie_len;
=2D	memcpy(attach->data, extra, priv->wpa_ie_len);
=2D
=2D	ret =3D mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach,
=2D		priv->wpa_ie_len);
=2D	if (ret =3D=3D 0) {
=2D		attach->type =3D (WLAN_FC_TYPE_MGMT << 2) |
=2D			(WLAN_FC_STYPE_REASSOC_REQ << 4);
=2D
=2D		ret =3D mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach,
=2D			priv->wpa_ie_len);
=2D		if (ret =3D=3D 0)
=2D			printk(KERN_DEBUG "%s: WPA IE Attachment was set\n",
=2D				ndev->name);
+	attach->id =3D -1; // global IE
+	attach->size =3D data->length;
+	memcpy(attach->data, extra, data->length);
+
+	if (priv->iw_mode =3D=3D IW_MODE_MASTER) {
+		attach->type =3D IEEE80211_STYPE_BEACON;
+		ret =3D mgt_set_varlen(priv, DOT11_OID_ATTACHMENT,
+			attach, data->length);
+		attach->type =3D IEEE80211_STYPE_PROBE_RESP;
+		ret |=3D mgt_set_varlen(priv, DOT11_OID_ATTACHMENT,
+			attach, data->length);
+	}
+	else {
+		attach->type =3D IEEE80211_STYPE_ASSOC_REQ;
+		ret =3D mgt_set_varlen(priv, DOT11_OID_ATTACHMENT,
+			attach, data->length);
+		attach->type =3D IEEE80211_STYPE_REASSOC_REQ;
+		ret |=3D mgt_set_varlen(priv, DOT11_OID_ATTACHMENT,
+			attach, data->length);
 	}
=20
 	kfree(attach);
@@ -1295,9 +1338,9 @@ #define WLAN_FC_STYPE_REASSOC_REQ 2
 }
=20
=20
=2Dstatic int prism54_get_genie(struct net_device *ndev,
=2D			     struct iw_request_info *info,
=2D			     struct iw_point *data, char *extra)
+static int
+prism54_get_genie(struct net_device *ndev, struct iw_request_info *info,
+		  struct iw_point *data, char *extra)
 {
 	islpci_private *priv =3D netdev_priv(ndev);
 	int len =3D priv->wpa_ie_len;
@@ -1316,38 +1359,17 @@ static int prism54_get_genie(struct net_
 	return 0;
 }
=20
=2Dstatic int prism54_set_auth(struct net_device *ndev,
=2D			       struct iw_request_info *info,
=2D			       union iwreq_data *wrqu, char *extra)
+static int
+prism54_set_auth(struct net_device *ndev, struct iw_request_info *info,
+			union iwreq_data *wrqu, char *extra)
 {
 	islpci_private *priv =3D netdev_priv(ndev);
 	struct iw_param *param =3D &wrqu->param;
=2D	u32 mlmelevel =3D 0, authen =3D 0, dot1x =3D 0;
=2D	u32 exunencrypt =3D 0, privinvoked =3D 0, wpa =3D 0;
=2D	u32 old_wpa;
=2D	int ret =3D 0;
=2D	union oid_res_t r;
+	u32 set =3D 0;
+	int rvalue =3D 0;
=20
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
=2D		return 0;
=2D
=2D	/* first get the flags */
=2D	down_write(&priv->mib_sem);
=2D	wpa =3D old_wpa =3D priv->wpa;
=2D	up_write(&priv->mib_sem);
=2D	ret =3D mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
=2D	authen =3D r.u;
=2D	ret =3D mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
=2D	privinvoked =3D r.u;
=2D	ret =3D mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
=2D	exunencrypt =3D r.u;
=2D	ret =3D mgt_get_request(priv, DOT11_OID_DOT1XENABLE, 0, NULL, &r);
=2D	dot1x =3D r.u;
=2D	ret =3D mgt_get_request(priv, DOT11_OID_MLMEAUTOLEVEL, 0, NULL, &r);
=2D	mlmelevel =3D r.u;
=2D
=2D	if (ret < 0)
=2D		goto out;
+		return -EINVAL;
=20
 	switch (param->flags & IW_AUTH_INDEX) {
 	case IW_AUTH_CIPHER_PAIRWISE:
@@ -1355,103 +1377,72 @@ static int prism54_set_auth(struct net_d
 	case IW_AUTH_KEY_MGMT:
 		break;
=20
=2D	case IW_AUTH_WPA_ENABLED:
=2D		/* Do the same thing as IW_AUTH_WPA_VERSION */
=2D		if (param->value) {
=2D			wpa =3D 1;
=2D			privinvoked =3D 1; /* For privacy invoked */
=2D			exunencrypt =3D 1; /* Filter out all unencrypted frames */
=2D			dot1x =3D 0x01; /* To enable eap filter */
=2D			mlmelevel =3D DOT11_MLME_EXTENDED;
=2D			authen =3D DOT11_AUTH_OS; /* Only WEP uses _SK and _BOTH */
=2D		} else {
=2D			wpa =3D 0;
=2D			privinvoked =3D 0;
=2D			exunencrypt =3D 0; /* Do not filter un-encrypted data */
=2D			dot1x =3D 0;
=2D			mlmelevel =3D DOT11_MLME_AUTO;
=2D		}
=2D		break;
=2D
 	case IW_AUTH_WPA_VERSION:
=2D		if (param->value & IW_AUTH_WPA_VERSION_DISABLED) {
=2D			wpa =3D 0;
=2D			privinvoked =3D 0;
=2D			exunencrypt =3D 0; /* Do not filter un-encrypted data */
=2D			dot1x =3D 0;
=2D			mlmelevel =3D DOT11_MLME_AUTO;
=2D		} else {
=2D			if (param->value & IW_AUTH_WPA_VERSION_WPA)
=2D				wpa =3D 1;
=2D			else if (param->value & IW_AUTH_WPA_VERSION_WPA2)
=2D				wpa =3D 2;
=2D			privinvoked =3D 1; /* For privacy invoked */
=2D			exunencrypt =3D 1; /* Filter out all unencrypted frames */
=2D			dot1x =3D 0x01; /* To enable eap filter */
=2D			mlmelevel =3D DOT11_MLME_EXTENDED;
=2D			authen =3D DOT11_AUTH_OS; /* Only WEP uses _SK and _BOTH */
=2D		}
+		if (set & IW_AUTH_WPA_VERSION_WPA)
+			set =3D 1;
+		if (set & IW_AUTH_WPA_VERSION_WPA2)
+			set |=3D 2;
+	case IW_AUTH_WPA_ENABLED:
+		if (!set)=20
+			set =3D param->value ? 3 : 0;
+		rvalue =3D prism54_set_wpa(ndev, info, &set, extra);
 		break;
=20
 	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
=2D		dot1x =3D param->value ? 1 : 0;
+		set =3D param->value ? 1 : 0;
+		rvalue =3D mgt_set_request(priv, DOT11_OID_DOT1XENABLE,=20
+				0, &set);
 		break;
=20
 	case IW_AUTH_PRIVACY_INVOKED:
=2D		privinvoked =3D param->value ? 1 : 0;
+		set =3D param->value ? 1 : 0;
+		rvalue =3D mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED,=20
+			0, &set);
+		break;
=20
 	case IW_AUTH_DROP_UNENCRYPTED:
=2D		exunencrypt =3D param->value ? 1 : 0;
+		set =3D param->value ? 1 : 0;
+		rvalue =3D mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED,
+			 0, &set);
 		break;
=20
 	case IW_AUTH_80211_AUTH_ALG:
=2D		if (param->value & IW_AUTH_ALG_SHARED_KEY) {
=2D			/* Only WEP uses _SK and _BOTH */
=2D			if (wpa > 0) {
=2D				ret =3D -EINVAL;
=2D				goto out;
=2D			}
=2D			authen =3D DOT11_AUTH_SK;
=2D		} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
=2D			authen =3D DOT11_AUTH_OS;
=2D		} else {
=2D			ret =3D -EINVAL;
=2D			goto out;
+		switch (param->value) {
+		case IW_AUTH_ALG_OPEN_SYSTEM:
+			set =3D DOT11_AUTH_OS;
+			break;
+		case IW_AUTH_ALG_SHARED_KEY:
+			set =3D DOT11_AUTH_SK;
+			break;
+		default:
+			return -EINVAL;
+			break;
 		}
+		rvalue =3D mgt_set_request(priv, DOT11_OID_AUTHENABLE,=20
+				0, &set);
 		break;
=20
 	default:
=2D		return -EOPNOTSUPP;
+		rvalue =3D -EOPNOTSUPP;
+		break;
 	}
=20
=2D	/* Set all the values */
=2D	down_write(&priv->mib_sem);
=2D	priv->wpa =3D wpa;
=2D	up_write(&priv->mib_sem);
=2D	mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
=2D	mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &privinvoked);
=2D	mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0, &exunencrypt);
=2D	mgt_set_request(priv, DOT11_OID_DOT1XENABLE, 0, &dot1x);
=2D	mgt_set_request(priv, DOT11_OID_MLMEAUTOLEVEL, 0, &mlmelevel);
=2D
=2Dout:
=2D	return ret;
+	return rvalue;
 }
=20
=2Dstatic int prism54_get_auth(struct net_device *ndev,
=2D			    struct iw_request_info *info,
=2D			    union iwreq_data *wrqu, char *extra)
+static int
+prism54_get_auth(struct net_device *ndev, struct iw_request_info *info,
+			union iwreq_data *wrqu, char *extra)
 {
 	islpci_private *priv =3D netdev_priv(ndev);
 	struct iw_param *param =3D &wrqu->param;
=2D	u32 wpa =3D 0;
=2D	int ret =3D 0;
 	union oid_res_t r;
+	u32 wpa =3D 0;
+	int rvalue =3D 0;
=20
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return 0;
=20
=2D	/* first get the flags */
 	down_write(&priv->mib_sem);
 	wpa =3D priv->wpa;
 	up_write(&priv->mib_sem);
@@ -1463,272 +1454,292 @@ static int prism54_get_auth(struct net_d
 		/*
 		 * wpa_supplicant will control these internally
 		 */
=2D		ret =3D -EOPNOTSUPP;
=2D		break;
+		param->value =3D 0;
+		return -EOPNOTSUPP;
+	break;
=20
 	case IW_AUTH_WPA_VERSION:
=2D		switch (wpa) {
=2D		case 1:
=2D			param->value =3D IW_AUTH_WPA_VERSION_WPA;
=2D			break;
=2D		case 2:
=2D			param->value =3D IW_AUTH_WPA_VERSION_WPA2;
=2D			break;
=2D		case 0:
=2D		default:
+		if (!wpa)
 			param->value =3D IW_AUTH_WPA_VERSION_DISABLED;
=2D			break;
=2D		}
+		if (wpa & 1)
+			param->value =3D IW_AUTH_WPA_VERSION_WPA;
+		if (wpa & 2)
+			param->value |=3D IW_AUTH_WPA_VERSION_WPA2;
+	=09
 		break;
=20
 	case IW_AUTH_DROP_UNENCRYPTED:
=2D		ret =3D mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
=2D		if (ret >=3D 0)
=2D			param->value =3D r.u > 0 ? 1 : 0;
+		rvalue =3D mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED,=20
+			0, NULL, &r);
+		param->value =3D r.u;
 		break;
=20
 	case IW_AUTH_80211_AUTH_ALG:
=2D		ret =3D mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
=2D		if (ret >=3D 0) {
=2D			switch (r.u) {
=2D			case DOT11_AUTH_OS:
=2D				param->value =3D IW_AUTH_ALG_OPEN_SYSTEM;
=2D				break;
=2D			case DOT11_AUTH_BOTH:
=2D			case DOT11_AUTH_SK:
=2D				param->value =3D IW_AUTH_ALG_SHARED_KEY;
=2D			case DOT11_AUTH_NONE:
=2D			default:
=2D				param->value =3D 0;
=2D				break;
=2D			}
+		rvalue =3D mgt_get_request(priv, DOT11_OID_AUTHENABLE,
+			 0, NULL, &r);
+
+		switch (r.u) {
+		case DOT11_AUTH_OS:
+			param->value =3D IW_AUTH_ALG_OPEN_SYSTEM;
+			break;
+		case DOT11_AUTH_BOTH:
+		case DOT11_AUTH_SK:
+			param->value =3D IW_AUTH_ALG_SHARED_KEY;
+			break;
+		default:
+			param->value =3D 0;
+			rvalue =3D -EOPNOTSUPP;
+			break;
 		}
 		break;
=20
 	case IW_AUTH_WPA_ENABLED:
=2D		param->value =3D wpa > 0 ? 1 : 0;
+		param->value =3D wpa ? 0 : 1;
 		break;
=20
 	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
=2D		ret =3D mgt_get_request(priv, DOT11_OID_DOT1XENABLE, 0, NULL, &r);
=2D		if (ret >=3D 0)
=2D			param->value =3D r.u > 0 ? 1 : 0;
+		rvalue =3D mgt_get_request(priv, DOT11_OID_DOT1XENABLE,=20
+			0, NULL, &r);
+		param->value =3D r.u;
 		break;
=20
 	case IW_AUTH_PRIVACY_INVOKED:
=2D		ret =3D mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
=2D		if (ret >=3D 0)
=2D			param->value =3D r.u > 0 ? 1 : 0;
+		rvalue =3D mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED,=20
+			0, NULL, &r);
+		param->value =3D r.u;
 		break;
=20
 	default:
 		return -EOPNOTSUPP;
+		break;
 	}
=2D	return ret;
+
+	return 0;
 }
=20
=2Dstatic int prism54_set_encodeext(struct net_device *ndev,
=2D				 struct iw_request_info *info,
=2D				 union iwreq_data *wrqu,
=2D				 char *extra)
+static int
+prism54_set_encodeext(struct net_device *ndev, struct iw_request_info *inf=
o,
+			struct iw_point *dwrq, char *extra)
 {
 	islpci_private *priv =3D netdev_priv(ndev);
=2D	struct iw_point *encoding =3D &wrqu->encoding;
=2D	struct iw_encode_ext *ext =3D (struct iw_encode_ext *)extra;
=2D	int idx, alg =3D ext->alg, set_key =3D 1;
+	struct iw_encode_ext *enc =3D (struct iw_encode_ext *)extra;
+	struct obj_stakey* key;
 	union oid_res_t r;
=2D	int authen =3D DOT11_AUTH_OS, invoke =3D 0, exunencrypt =3D 0;
=2D	int ret =3D 0;
=2D
=2D	if (islpci_get_state(priv) < PRV_STATE_INIT)
=2D		return 0;
=2D
=2D	/* Determine and validate the key index */
=2D	idx =3D (encoding->flags & IW_ENCODE_INDEX) - 1;
=2D	if (idx) {
=2D		if (idx < 0 || idx > 3)
=2D			return -EINVAL;
=2D	} else {
=2D		ret =3D mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
=2D		if (ret < 0)
=2D			goto out;
=2D		idx =3D r.u;
=2D	}
+	int index, key_type, keyop =3D DOT11_KEYOP_SET_KEY;
+	int ret =3D -EINVAL;
=20
=2D	if (encoding->flags & IW_ENCODE_DISABLED)
=2D		alg =3D IW_ENCODE_ALG_NONE;
=2D
=2D	if (ext->ext_flags & IW_ENCODE_EXT_SET_TX_KEY) {
=2D		/* Only set transmit key index here, actual
=2D		 * key is set below if needed.
=2D		 */
=2D		ret =3D mgt_set_request(priv, DOT11_OID_DEFKEYID, 0, &idx);
=2D		set_key =3D ext->key_len > 0 ? 1 : 0;
=2D	}
+	if ((islpci_get_state(priv) < PRV_STATE_INIT) ||
+	   (enc->key_len > (dwrq->length - sizeof(*enc))) ||
+	   (enc->addr.sa_family !=3D ARPHRD_ETHER))
+		return -EINVAL;
=20
=2D	if (set_key) {
=2D		struct obj_key key =3D { DOT11_PRIV_WEP, 0, "" };
=2D		switch (alg) {
+	switch (enc->alg) {
 		case IW_ENCODE_ALG_NONE:
+#if 0
+			key_type =3D DOT11_PRIV_WEP;
+			keyop =3D DOT11_KEYOP_REMOVE_KEY;
+#else=20
+			return 0;
+#endif
 			break;
 		case IW_ENCODE_ALG_WEP:
=2D			if (ext->key_len > KEY_SIZE_WEP104) {
=2D				ret =3D -EINVAL;
=2D				goto out;
=2D			}
=2D			if (ext->key_len > KEY_SIZE_WEP40)
=2D				key.length =3D KEY_SIZE_WEP104;
=2D			else
=2D				key.length =3D KEY_SIZE_WEP40;
+			key_type =3D DOT11_PRIV_WEP;
 			break;
 		case IW_ENCODE_ALG_TKIP:
=2D			if (ext->key_len > KEY_SIZE_TKIP) {
=2D				ret =3D -EINVAL;
=2D				goto out;
=2D			}
=2D			key.type =3D DOT11_PRIV_TKIP;
=2D			key.length =3D KEY_SIZE_TKIP;
+			key_type =3D DOT11_PRIV_TKIP;
+			break;
 		default:
=2D			return -EINVAL;
=2D		}
=2D
=2D		if (key.length) {
=2D			memset(key.key, 0, sizeof(key.key));
=2D			memcpy(key.key, ext->key, ext->key_len);
=2D			ret =3D mgt_set_request(priv, DOT11_OID_DEFKEYX, idx,
=2D					    &key);
=2D			if (ret < 0)
=2D				goto out;
=2D		}
+			return -EOPNOTSUPP;
 	}
=20
=2D	/* Read the flags */
=2D	if (encoding->flags & IW_ENCODE_DISABLED) {
=2D		/* Encoding disabled,
=2D		 * authen =3D DOT11_AUTH_OS;
=2D		 * invoke =3D 0;
=2D		 * exunencrypt =3D 0; */
=2D	}
=2D	if (encoding->flags & IW_ENCODE_OPEN) {
=2D		/* Encode but accept non-encoded packets. No auth */
=2D		invoke =3D 1;
=2D	}
=2D	if (encoding->flags & IW_ENCODE_RESTRICTED) {
=2D		/* Refuse non-encoded packets. Auth */
=2D		authen =3D DOT11_AUTH_BOTH;
=2D		invoke =3D 1;
=2D		exunencrypt =3D 1;
+	index =3D (dwrq->flags & IW_ENCODE_INDEX);
+	if ((index < 0) || (index > 3)) {
+		 /* no index provided, so get the current one */
+		ret =3D mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+		if (ret)
+			return ret;
+		index =3D r.u;
 	}
=20
=2D	/* do the change if requested  */
=2D	if (encoding->flags & IW_ENCODE_MODE) {
=2D		ret =3D mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0,
=2D				      &authen);
=2D		ret =3D mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0,
=2D				      &invoke);
=2D		ret =3D mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0,
=2D				      &exunencrypt);
+	key =3D kzalloc(sizeof(*key) + enc->key_len, GFP_KERNEL);
+	if (!key)
+		return -ENOMEM;
+
+	key->type =3D key_type;
+	key->length =3D enc->key_len;
+	key->keyid =3D index;
+	key->reserved =3D keyop;
+	if (!(enc->ext_flags & IW_ENCODE_EXT_GROUP_KEY))
+		key->options =3D DOT11_STAKEY_OPTION_DEFAULTKEY;
+	else=20
+		key->options =3D DOT11_STAKEY_OPTION_GROUPKEY;
+
+	memcpy(key->key, enc->key, key->length);
+	memcpy(key->address, enc->addr.sa_data, ETH_ALEN);
+
+	ret =3D mgt_set_request(priv, DOT11_OID_STAKEY, 0, key);
+	kfree(key);
+	if (ret)
+		return ret;
+
+	if (enc->ext_flags & IW_ENCODE_EXT_RX_SEQ_VALID) {
+		struct obj_stasc *stasc;
+		stasc =3D kzalloc(sizeof(*stasc), GFP_KERNEL);
+		if (!stasc)
+			return -ENOMEM;
+		memcpy(stasc->address, enc->addr.sa_data, ETH_ALEN);=09
+		stasc->keyid =3D index;
+		stasc->tx_sc =3D 1;
+		memcpy(stasc->sc, enc->rx_seq, 6);
+		ret =3D mgt_set_request(priv, DOT11_OID_STASC, 0, stasc);
+		kfree(stasc);
+		if (ret)
+			return ret;
 	}
=20
=2Dout:
+	if (dwrq->flags & IW_ENCODE_MODE)
+		ret =3D prism54_set_auth_alg(priv, dwrq->flags);
+
 	return ret;
 }
=20
=2D
=2Dstatic int prism54_get_encodeext(struct net_device *ndev,
=2D				 struct iw_request_info *info,
=2D				 union iwreq_data *wrqu,
=2D				 char *extra)
+static int
+prism54_get_encodeext(struct net_device *ndev,
+		struct iw_request_info *info, struct iw_point *dwrq, char *extra)
 {
 	islpci_private *priv =3D netdev_priv(ndev);
=2D	struct iw_point *encoding =3D &wrqu->encoding;
=2D	struct iw_encode_ext *ext =3D (struct iw_encode_ext *)extra;
=2D	int idx, max_key_len;
+	struct iw_encode_ext *enc =3D (struct iw_encode_ext *)extra;
+	struct obj_stasc   *stasc;
 	union oid_res_t r;
=2D	int authen =3D DOT11_AUTH_OS, invoke =3D 0, exunencrypt =3D 0, wpa =3D =
0;
=2D	int ret =3D 0;
+	int index;
+	int ret =3D -EINVAL;
+	int max_key_len;
=20
=2D	if (islpci_get_state(priv) < PRV_STATE_INIT)
=2D		return 0;
=2D
=2D	/* first get the flags */
=2D	ret =3D mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
=2D	authen =3D r.u;
=2D	ret =3D mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
=2D	invoke =3D r.u;
=2D	ret =3D mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
=2D	exunencrypt =3D r.u;
=2D	if (ret < 0)
=2D		goto out;
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
=20
=2D	max_key_len =3D encoding->length - sizeof(*ext);
+	max_key_len =3D dwrq->length - sizeof(*enc);
 	if (max_key_len < 0)
 		return -EINVAL;
=20
=2D	idx =3D (encoding->flags & IW_ENCODE_INDEX) - 1;
=2D	if (idx) {
=2D		if (idx < 0 || idx > 3)
=2D			return -EINVAL;
=2D	} else {
+	memset(enc, 0, sizeof(*enc));
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT) {
+		dwrq->flags =3D IW_ENCODE_DISABLED;
+		return 0;
+		}
+
+	index =3D (dwrq->flags & IW_ENCODE_INDEX) - 1;
+	if ((index < 0) || (index > 3)) {
+		 /* no index provided, so get the current one */
 		ret =3D mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
=2D		if (ret < 0)
=2D			goto out;
=2D		idx =3D r.u;
+		if (ret)
+			return ret;
+		index =3D r.u;
 	}
=20
=2D	encoding->flags =3D idx + 1;
=2D	memset(ext, 0, sizeof(*ext));
+	if (enc->addr.sa_family !=3D ARPHRD_ETHER) {
+		/* no "per-station key" */
+		struct obj_key *key;
+		ret =3D mgt_get_request(priv, DOT11_OID_DEFKEYX, index, NULL, &r);
+		key =3D r.ptr;
+		if (ret) {
+			kfree(key);
+			return ret;
+			}
=20
=2D	switch (authen) {
=2D	case DOT11_AUTH_BOTH:
=2D	case DOT11_AUTH_SK:
=2D		wrqu->encoding.flags |=3D IW_ENCODE_RESTRICTED;
=2D	case DOT11_AUTH_OS:
=2D	default:
=2D		wrqu->encoding.flags |=3D IW_ENCODE_OPEN;
+		if (key->length > max_key_len) {
+			kfree(key);
+			return -E2BIG;
+		}
+
+		enc->key_len =3D key->length;
+		switch (key->type) {
+		case DOT11_PRIV_WEP:
+			enc->alg =3D IW_ENCODE_ALG_WEP;
+			break;
+		case DOT11_PRIV_TKIP:
+			enc->alg =3D IW_ENCODE_ALG_TKIP;
 		break;
=2D	}
+		default:
+			kfree(key);
+			return -EIO;
+			break;
+		}
=20
=2D	down_write(&priv->mib_sem);
=2D	wpa =3D priv->wpa;
=2D	up_write(&priv->mib_sem);
+		dwrq->flags |=3D IW_ENCODE_ENABLED;
+		memcpy(enc->key, key->key, enc->key_len);
+		dwrq->flags |=3D index +1;
+		return ret;
=20
=2D	if (authen =3D=3D DOT11_AUTH_OS && !exunencrypt && !invoke && !wpa) {
=2D		/* No encryption */
=2D		ext->alg =3D IW_ENCODE_ALG_NONE;
=2D		ext->key_len =3D 0;
=2D		wrqu->encoding.flags |=3D IW_ENCODE_DISABLED;
=2D	} else {
=2D		struct obj_key *key;
+	}
+	else {
+		/* no "per-station key" */
+		struct obj_stakey *key;
+		key =3D kzalloc(sizeof(*key), GFP_KERNEL);
+		if (!key)
+			return -ENOMEM;
+=09
+		memcpy(key->address, enc->addr.sa_data, ETH_ALEN);
+		key->keyid =3D index;
+		ret =3D mgt_get_request(priv, DOT11_OID_STAKEY, 0, (void*)key, &r);
+		kfree(key);
+		key =3D (struct obj_stakey*)r.ptr;
+		if (ret) {
+			kfree(key);
+			return ret;
+		}
=20
=2D		ret =3D mgt_get_request(priv, DOT11_OID_DEFKEYX, idx, NULL, &r);
=2D		if (ret < 0)
=2D			goto out;
=2D		key =3D r.ptr;
=2D		if (max_key_len < key->length) {
=2D			ret =3D -E2BIG;
=2D			goto out;
+		if (key->length > max_key_len) {
+			kfree(key);
+			return -EINVAL;
 		}
=2D		memcpy(ext->key, key->key, key->length);
=2D		ext->key_len =3D key->length;
=20
 		switch (key->type) {
=2D		case DOT11_PRIV_TKIP:
=2D			ext->alg =3D IW_ENCODE_ALG_TKIP;
+			case DOT11_PRIV_WEP:
+				enc->alg =3D IW_ENCODE_ALG_WEP;
 			break;
=2D		default:
=2D		case DOT11_PRIV_WEP:
=2D			ext->alg =3D IW_ENCODE_ALG_WEP;
+			case DOT11_PRIV_TKIP:
+				enc->alg =3D IW_ENCODE_ALG_TKIP;
+			break;
+			default:
+				kfree(key);
+				return -EIO;
 			break;
 		}
=2D		wrqu->encoding.flags |=3D IW_ENCODE_ENABLED;
+
+		enc->key_len =3D key->length;
+		dwrq->flags =3D index + 1;
+		memcpy(enc->key, key->key, key->length);
+		kfree(key);
+
+		/* add replay counter */
+		stasc =3D kzalloc(sizeof(*stasc), GFP_KERNEL);
+		if (!stasc)
+			return -ENOMEM;
+
+		memcpy(stasc->address, enc->addr.sa_data, ETH_ALEN);
+		stasc->keyid =3D index;
+		stasc->tx_sc =3D 1;
+		ret =3D mgt_get_request(priv, DOT11_OID_STASC, 0, (void*)stasc, &r);
+		kfree(stasc);
+		stasc =3D (struct obj_stasc*)r.ptr;
+		if (ret) {
+			kfree(stasc);
+			return ret;
+		}
+
+		memset(enc->tx_seq, 0, IW_ENCODE_SEQ_MAX_SIZE);
+		// prism's FW has only a 6 byte wide RSC!
+		memcpy(enc->tx_seq, stasc->sc, IW_ENCODE_SEQ_MAX_SIZE - 2);
+		enc->ext_flags |=3D IW_ENCODE_EXT_TX_SEQ_VALID;
+		kfree(stasc);
+
 	}
=20
=2Dout:
 	return ret;
 }
=20
=2D
 static int
 prism54_reset(struct net_device *ndev, struct iw_request_info *info,
 	      __u32 * uwrq, char *extra)
@@ -2030,14 +2041,12 @@ static void
 format_event(islpci_private *priv, char *dest, const char *str,
 	     const struct obj_mlme *mlme, u16 *length, int error)
 {
=2D	const u8 *a =3D mlme->address;
 	int n =3D snprintf(dest, IW_CUSTOM_MAX,
=2D			 "%s %s %2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X %s (%2.2X)",
+			 "%s %s " MAC_FMT " [%2.2x %2.2X %4.4X]",
 			 str,
 			 ((priv->iw_mode =3D=3D IW_MODE_MASTER) ? "from" : "to"),
=2D			 a[0], a[1], a[2], a[3], a[4], a[5],
=2D			 (error ? (mlme->code ? " : REJECTED " : " : ACCEPTED ")
=2D			  : ""), mlme->code);
+			 MAC_ARG(mlme->address),
+			 mlme->state, mlme->code, mlme->id);
 	BUG_ON(n > IW_CUSTOM_MAX);
 	*length =3D n;
 }
@@ -2103,12 +2112,6 @@ struct ieee80211_beacon_phdr {
 	u16 capab_info;
 } __attribute__ ((packed));
=20
=2D#define WLAN_EID_GENERIC 0xdd
=2Dstatic u8 wpa_oid[4] =3D { 0x00, 0x50, 0xf2, 1 };
=2D
=2D#define MAC2STR(a) (a)[0], (a)[1], (a)[2], (a)[3], (a)[4], (a)[5]
=2D#define MACSTR "%02x:%02x:%02x:%02x:%02x:%02x"
=2D
 static void
 prism54_wpa_bss_ie_add(islpci_private *priv, u8 *bssid,
 		       u8 *wpa_ie, size_t wpa_ie_len)
@@ -2140,10 +2143,9 @@ prism54_wpa_bss_ie_add(islpci_private *p
 					 struct islpci_bss_wpa_ie, list);
 			list_del(&bss->list);
 		} else {
=2D			bss =3D kmalloc(sizeof (*bss), GFP_ATOMIC);
+			bss =3D kzalloc(sizeof(*bss), GFP_ATOMIC);
 			if (bss !=3D NULL) {
 				priv->num_bss_wpa++;
=2D				memset(bss, 0, sizeof (*bss));
 			}
 		}
 		if (bss !=3D NULL) {
@@ -2157,8 +2159,8 @@ prism54_wpa_bss_ie_add(islpci_private *p
 		bss->wpa_ie_len =3D wpa_ie_len;
 		bss->last_update =3D jiffies;
 	} else {
=2D		printk(KERN_DEBUG "Failed to add BSS WPA entry for " MACSTR
=2D		       "\n", MAC2STR(bssid));
+		printk(KERN_DEBUG "Failed to add BSS WPA entry for " MAC_FMT
+		       "\n", MAC_ARG(bssid));
 	}
=20
 	/* expire old entries from WPA list */
@@ -2220,6 +2222,8 @@ prism54_wpa_bss_ie_clean(islpci_private
 	}
 }
=20
+static u8 wpa_oid[4] =3D { 0x00, 0x50, 0xf2, 1 };
+
 static void
 prism54_process_bss_data(islpci_private *priv, u32 oid, u8 *addr,
 			 u8 *payload, size_t len)
@@ -2235,11 +2239,16 @@ prism54_process_bss_data(islpci_private
 	end =3D payload + len;
 	while (pos < end) {
 		if (pos + 2 + pos[1] > end) {
=2D			printk(KERN_DEBUG "Parsing Beacon/ProbeResp failed "
=2D			       "for " MACSTR "\n", MAC2STR(addr));
+			printk(KERN_DEBUG "Parsing %s failed "
+			       "for " MAC_FMT "\n", (oid =3D=3D DOT11_OID_BEACON ? "Beacon" : "=
ProbeResp"), MAC_ARG(addr));
 			return;
 		}
=2D		if (pos[0] =3D=3D WLAN_EID_GENERIC && pos[1] >=3D 4 &&
+		/* Don't forget RSN/WPA2 ! */
+		if (pos[0] =3D=3D MFIE_TYPE_RSN && pos[1] > 4) {
+			prism54_wpa_bss_ie_add(priv, addr, pos, pos[1] + 2);
+			return;
+		}
+		if (pos[0] =3D=3D MFIE_TYPE_GENERIC && pos[1] >=3D 4 &&
 		    memcmp(pos + 2, wpa_oid, 4) =3D=3D 0) {
 			prism54_wpa_bss_ie_add(priv, addr, pos, pos[1] + 2);
 			return;
@@ -2264,39 +2273,81 @@ handle_request(islpci_private *priv, str
 }
=20
 static int
+prism54_process_sta_trap(islpci_private *priv, enum oid_num_t oid,
+				struct obj_mlmeex* mlmeex)
+{
+	struct obj_mlme *mlme =3D (struct obj_mlme*)mlmeex;
+	int ret =3D 0;
+
+	switch (oid) {
+	case DOT11_OID_DEAUTHENTICATEEX:
+		send_formatted_event(priv, "DeAuthenticate request",
+				       mlme, 0);
+		break;
+
+	case DOT11_OID_AUTHENTICATEEX:
+		if (prism54_mac_accept(&priv->acl, mlmeex->address) &&
+		   (mlmeex->state =3D=3D DOT11_STATE_AUTH)) {
+
+			mlmeex->state =3D DOT11_STATE_ASSOCING;
+			mlmeex->code =3D 0;
+			mlmeex->size =3D 0;
+			ret =3D mgt_set_request(priv, DOT11_OID_ASSOCIATEEX,
+				0, mlmeex);
+			if (ret)
+				return ret;
+		}
+		if (mlmeex->code !=3D 0)
+			send_formatted_event(priv, "Authenticate request",
+					     mlme, 1);
+		break;
+
+	case DOT11_OID_DISASSOCIATEEX:
+		send_formatted_event(priv, "Disassociate request",
+				     mlme, 0);
+		break;
+
+	case DOT11_OID_ASSOCIATEEX:
+		if (mlmeex->code)
+			send_formatted_event(priv, "Associate request",
+					     mlme, 1);
+		break;
+
+	case DOT11_OID_REASSOCIATEEX:
+		if (mlmeex->code)
+			send_formatted_event(priv, "Reassociate request",
+				       mlme, 1);
+		break;
+
+	default:
+		printk(KERN_INFO "%s: Unhandled OID %x, "
+			"please fill a bug-report!\n", priv->ndev->name, oid);
+		break;
+	}
+
+	return ret;
+}
+
+static int
 prism54_process_trap_helper(islpci_private *priv, enum oid_num_t oid,
 			    char *data)
 {
 	struct obj_mlme *mlme =3D (struct obj_mlme *) data;
 	struct obj_mlmeex *mlmeex =3D (struct obj_mlmeex *) data;
=2D	struct obj_mlmeex *confirm;
=2D	u8 wpa_ie[MAX_WPA_IE_LEN];
=2D	int wpa_ie_len;
=2D	size_t len =3D 0; /* u16, better? */
=2D	u8 *payload =3D NULL, *pos =3D NULL;
=2D	int ret;
=2D
=2D	/* I think all trapable objects are listed here.
=2D	 * Some oids have a EX version. The difference is that they are emitted
=2D	 * in DOT11_MLME_EXTENDED mode (set with DOT11_OID_MLMEAUTOLEVEL)
=2D	 * with more info.
=2D	 * The few events already defined by the wireless tools are not really
=2D	 * suited. We use the more flexible custom event facility.
=2D	 */
=2D
=2D	if (oid >=3D DOT11_OID_BEACON) {
=2D		len =3D mlmeex->size;
=2D		payload =3D pos =3D mlmeex->data;
=2D	}
+	int ret =3D 0;
=20
 	/* I fear prism54_process_bss_data won't work with big endian data */
=2D	if ((oid =3D=3D DOT11_OID_BEACON) || (oid =3D=3D DOT11_OID_PROBE))
=2D		prism54_process_bss_data(priv, oid, mlmeex->address,
=2D					 payload, len);
=20
 	mgt_le_to_cpu(isl_oid[oid].flags & OID_FLAG_TYPE, (void *) mlme);
=20
 	switch (oid) {
+	case DOT11_OID_BEACON:
+	case DOT11_OID_PROBE:
+		if (priv->iw_mode !=3D IW_MODE_MASTER=20
+			&& mlmeex->state !=3D DOT11_STATE_AUTHING)
+			prism54_process_bss_data(priv, oid, mlmeex->address,
+						 mlmeex->data, mlmeex->size);
+		break;
=20
 	case GEN_OID_LINKSTATE:
 		link_changed(priv->ndev, (u32) *data);
@@ -2329,163 +2380,12 @@ prism54_process_trap_helper(islpci_priva
 		send_formatted_event(priv, "ReAssociate request", mlme, 1);
 		break;
=20
=2D	case DOT11_OID_BEACON:
=2D		send_formatted_event(priv,
=2D				     "Received a beacon from an unkown AP",
=2D				     mlme, 0);
=2D		break;
=2D
=2D	case DOT11_OID_PROBE:
=2D		/* we received a probe from a client. */
=2D		send_formatted_event(priv, "Received a probe from client", mlme,
=2D				     0);
=2D		break;
=2D
=2D		/* Note : "mlme" is actually a "struct obj_mlmeex *" here, but this
=2D		 * is backward compatible layout-wise with "struct obj_mlme".
=2D		 */
=2D
=2D	case DOT11_OID_DEAUTHENTICATEEX:
=2D		send_formatted_event(priv, "DeAuthenticate request", mlme, 0);
=2D		break;
=2D
=2D	case DOT11_OID_AUTHENTICATEEX:
=2D		handle_request(priv, mlme, oid);
=2D		send_formatted_event(priv, "Authenticate request (ex)", mlme, 1);
=2D
=2D		if (priv->iw_mode !=3D IW_MODE_MASTER
=2D				&& mlmeex->state !=3D DOT11_STATE_AUTHING)
=2D			break;
=2D
=2D		confirm =3D kmalloc(sizeof(struct obj_mlmeex) + 6, GFP_ATOMIC);
=2D
=2D		if (!confirm)
=2D			break;
=2D
=2D		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
=2D		printk(KERN_DEBUG "Authenticate from: address:\t%02x:%02x:%02x:%02x:%0=
2x:%02x\n",
=2D				mlmeex->address[0],
=2D				mlmeex->address[1],
=2D				mlmeex->address[2],
=2D				mlmeex->address[3],
=2D				mlmeex->address[4],
=2D				mlmeex->address[5]
=2D				);
=2D		confirm->id =3D -1; /* or mlmeex->id ? */
=2D		confirm->state =3D 0; /* not used */
=2D		confirm->code =3D 0;
=2D		confirm->size =3D 6;
=2D		confirm->data[0] =3D 0x00;
=2D		confirm->data[1] =3D 0x00;
=2D		confirm->data[2] =3D 0x02;
=2D		confirm->data[3] =3D 0x00;
=2D		confirm->data[4] =3D 0x00;
=2D		confirm->data[5] =3D 0x00;
=2D
=2D		ret =3D mgt_set_varlen(priv, DOT11_OID_ASSOCIATEEX, confirm, 6);
=2D
=2D		kfree(confirm);
=2D		if (ret)
=2D			return ret;
=2D		break;
=2D
=2D	case DOT11_OID_DISASSOCIATEEX:
=2D		send_formatted_event(priv, "Disassociate request (ex)", mlme, 0);
=2D		break;
=2D
=2D	case DOT11_OID_ASSOCIATEEX:
=2D		handle_request(priv, mlme, oid);
=2D		send_formatted_event(priv, "Associate request (ex)", mlme, 1);
=2D
=2D		if (priv->iw_mode !=3D IW_MODE_MASTER
=2D				&& mlmeex->state !=3D DOT11_STATE_ASSOCING)
=2D			break;
=2D
=2D		confirm =3D kmalloc(sizeof(struct obj_mlmeex), GFP_ATOMIC);
=2D
=2D		if (!confirm)
=2D			break;
=2D
=2D		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
=2D
=2D		confirm->id =3D ((struct obj_mlmeex *)mlme)->id;
=2D		confirm->state =3D 0; /* not used */
=2D		confirm->code =3D 0;
=2D
=2D		wpa_ie_len =3D prism54_wpa_bss_ie_get(priv, mlmeex->address, wpa_ie);
=2D
=2D		if (!wpa_ie_len) {
=2D			printk(KERN_DEBUG "No WPA IE found from "
=2D					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n",
=2D				mlmeex->address[0],
=2D				mlmeex->address[1],
=2D				mlmeex->address[2],
=2D				mlmeex->address[3],
=2D				mlmeex->address[4],
=2D				mlmeex->address[5]
=2D				);
=2D			kfree(confirm);
=2D			break;
=2D		}
=2D
=2D		confirm->size =3D wpa_ie_len;
=2D		memcpy(&confirm->data, wpa_ie, wpa_ie_len);
=2D
=2D		mgt_set_varlen(priv, oid, confirm, wpa_ie_len);
=2D
=2D		kfree(confirm);
=2D
=2D		break;
=2D
=2D	case DOT11_OID_REASSOCIATEEX:
=2D		handle_request(priv, mlme, oid);
=2D		send_formatted_event(priv, "Reassociate request (ex)", mlme, 1);
=2D
=2D		if (priv->iw_mode !=3D IW_MODE_MASTER
=2D				&& mlmeex->state !=3D DOT11_STATE_ASSOCING)
=2D			break;
=2D
=2D		confirm =3D kmalloc(sizeof(struct obj_mlmeex), GFP_ATOMIC);
=2D
=2D		if (!confirm)
=2D			break;
=2D
=2D		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
=2D
=2D		confirm->id =3D mlmeex->id;
=2D		confirm->state =3D 0; /* not used */
=2D		confirm->code =3D 0;
=2D
=2D		wpa_ie_len =3D prism54_wpa_bss_ie_get(priv, mlmeex->address, wpa_ie);
=2D
=2D		if (!wpa_ie_len) {
=2D			printk(KERN_DEBUG "No WPA IE found from "
=2D					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n",
=2D				mlmeex->address[0],
=2D				mlmeex->address[1],
=2D				mlmeex->address[2],
=2D				mlmeex->address[3],
=2D				mlmeex->address[4],
=2D				mlmeex->address[5]
=2D				);
=2D			kfree(confirm);
=2D			break;
=2D		}
=2D
=2D		confirm->size =3D wpa_ie_len;
=2D		memcpy(&confirm->data, wpa_ie, wpa_ie_len);
=2D
=2D		mgt_set_varlen(priv, oid, confirm, wpa_ie_len);
=2D
=2D		kfree(confirm);
=2D
=2D		break;
=2D
 	default:
=2D		return -EINVAL;
+		ret =3D prism54_process_sta_trap(priv, oid, mlmeex);
+		break;
 	}
=20
=2D	return 0;
+	return ret;
 }
=20
 /*
@@ -2521,368 +2421,33 @@ prism54_set_mac_address(struct net_devic
 	return ret;
 }
=20
=2D/* Note: currently, use hostapd ioctl from the Host AP driver for WPA
=2D * support. This is to be replaced with Linux wireless extensions once t=
hey
=2D * get WPA support. */
=2D
=2D/* Note II: please leave all this together as it will be easier to remov=
e later,
=2D * once wireless extensions add WPA support -mcgrof */
=2D
=2D/* PRISM54_HOSTAPD ioctl() cmd: */
=2Denum {
=2D	PRISM2_SET_ENCRYPTION =3D 6,
=2D	PRISM2_HOSTAPD_SET_GENERIC_ELEMENT =3D 12,
=2D	PRISM2_HOSTAPD_MLME =3D 13,
=2D	PRISM2_HOSTAPD_SCAN_REQ =3D 14,
=2D};
=2D
=2D#define PRISM54_SET_WPA			SIOCIWFIRSTPRIV+12
=2D#define PRISM54_HOSTAPD			SIOCIWFIRSTPRIV+25
=2D#define PRISM54_DROP_UNENCRYPTED	SIOCIWFIRSTPRIV+26
=2D
=2D#define PRISM2_HOSTAPD_MAX_BUF_SIZE 1024
=2D#define PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN \
=2D((int) (&((struct prism2_hostapd_param *) 0)->u.generic_elem.data))
=2D
=2D/* Maximum length for algorithm names (-1 for nul termination)
=2D * used in ioctl() */
=2D#define HOSTAP_CRYPT_ALG_NAME_LEN 16
=2D
=2Dstruct prism2_hostapd_param {
=2D	u32 cmd;
=2D	u8 sta_addr[ETH_ALEN];
=2D	union {
=2D	       struct {
=2D		       u8 alg[HOSTAP_CRYPT_ALG_NAME_LEN];
=2D		       u32 flags;
=2D		       u32 err;
=2D		       u8 idx;
=2D		       u8 seq[8]; /* sequence counter (set: RX, get: TX) */
=2D		       u16 key_len;
=2D		       u8 key[0];
=2D		       } crypt;
=2D               struct {
=2D                       u8 len;
=2D                       u8 data[0];
=2D               } generic_elem;
=2D               struct {
=2D#define MLME_STA_DEAUTH 0
=2D#define MLME_STA_DISASSOC 1
=2D                       u16 cmd;
=2D                       u16 reason_code;
=2D               } mlme;
=2D               struct {
=2D                       u8 ssid_len;
=2D                       u8 ssid[32];
=2D               } scan_req;
=2D       } u;
=2D};
=2D
=2D
=2Dstatic int
=2Dprism2_ioctl_set_encryption(struct net_device *dev,
=2D	struct prism2_hostapd_param *param,
=2D	int param_len)
=2D{
=2D	islpci_private *priv =3D netdev_priv(dev);
=2D	int rvalue =3D 0, force =3D 0;
=2D	int authen =3D DOT11_AUTH_OS, invoke =3D 0, exunencrypt =3D 0;
=2D	union oid_res_t r;
=2D
=2D	/* with the new API, it's impossible to get a NULL pointer.
=2D	 * New version of iwconfig set the IW_ENCODE_NOKEY flag
=2D	 * when no key is given, but older versions don't. */
=2D
=2D	if (param->u.crypt.key_len > 0) {
=2D		/* we have a key to set */
=2D		int index =3D param->u.crypt.idx;
=2D		int current_index;
=2D		struct obj_key key =3D { DOT11_PRIV_TKIP, 0, "" };
=2D
=2D		/* get the current key index */
=2D		rvalue =3D mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
=2D		current_index =3D r.u;
=2D		/* Verify that the key is not marked as invalid */
=2D		if (!(param->u.crypt.flags & IW_ENCODE_NOKEY)) {
=2D			key.length =3D param->u.crypt.key_len > sizeof (param->u.crypt.key) ?
=2D			    sizeof (param->u.crypt.key) : param->u.crypt.key_len;
=2D			memcpy(key.key, param->u.crypt.key, key.length);
=2D			if (key.length =3D=3D 32)
=2D				/* we want WPA-PSK */
=2D				key.type =3D DOT11_PRIV_TKIP;
=2D			if ((index < 0) || (index > 3))
=2D				/* no index provided use the current one */
=2D				index =3D current_index;
=2D
=2D			/* now send the key to the card  */
=2D			rvalue |=3D
=2D			    mgt_set_request(priv, DOT11_OID_DEFKEYX, index,
=2D					    &key);
=2D		}
=2D		/*
=2D		 * If a valid key is set, encryption should be enabled
=2D		 * (user may turn it off later).
=2D		 * This is also how "iwconfig ethX key on" works
=2D		 */
=2D		if ((index =3D=3D current_index) && (key.length > 0))
=2D			force =3D 1;
=2D	} else {
=2D		int index =3D (param->u.crypt.flags & IW_ENCODE_INDEX) - 1;
=2D		if ((index >=3D 0) && (index <=3D 3)) {
=2D			/* we want to set the key index */
=2D			rvalue |=3D
=2D			    mgt_set_request(priv, DOT11_OID_DEFKEYID, 0,
=2D					    &index);
=2D		} else {
=2D			if (!param->u.crypt.flags & IW_ENCODE_MODE) {
=2D				/* we cannot do anything. Complain. */
=2D				return -EINVAL;
=2D			}
=2D		}
=2D	}
=2D	/* now read the flags */
=2D	if (param->u.crypt.flags & IW_ENCODE_DISABLED) {
=2D		/* Encoding disabled,
=2D		 * authen =3D DOT11_AUTH_OS;
=2D		 * invoke =3D 0;
=2D		 * exunencrypt =3D 0; */
=2D	}
=2D	if (param->u.crypt.flags & IW_ENCODE_OPEN)
=2D		/* Encode but accept non-encoded packets. No auth */
=2D		invoke =3D 1;
=2D	if ((param->u.crypt.flags & IW_ENCODE_RESTRICTED) || force) {
=2D		/* Refuse non-encoded packets. Auth */
=2D		authen =3D DOT11_AUTH_BOTH;
=2D		invoke =3D 1;
=2D		exunencrypt =3D 1;
=2D	}
=2D	/* do the change if requested  */
=2D	if ((param->u.crypt.flags & IW_ENCODE_MODE) || force) {
=2D		rvalue |=3D
=2D		    mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
=2D		rvalue |=3D
=2D		    mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &invoke);
=2D		rvalue |=3D
=2D		    mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0,
=2D				    &exunencrypt);
=2D	}
=2D	return rvalue;
=2D}
=2D
=2Dstatic int
=2Dprism2_ioctl_set_generic_element(struct net_device *ndev,
=2D	struct prism2_hostapd_param *param,
=2D	int param_len)
=2D{
=2D       islpci_private *priv =3D netdev_priv(ndev);
=2D       int max_len, len, alen, ret=3D0;
=2D       struct obj_attachment *attach;
=2D
=2D       len =3D param->u.generic_elem.len;
=2D       max_len =3D param_len - PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN;
=2D       if (max_len < 0 || max_len < len)
=2D               return -EINVAL;
=2D
=2D       alen =3D sizeof(*attach) + len;
=2D       attach =3D kmalloc(alen, GFP_KERNEL);
=2D       if (attach =3D=3D NULL)
=2D               return -ENOMEM;
=2D
=2D       memset(attach, 0, alen);
=2D#define WLAN_FC_TYPE_MGMT 0
=2D#define WLAN_FC_STYPE_ASSOC_REQ 0
=2D#define WLAN_FC_STYPE_REASSOC_REQ 2
=2D
=2D       /* Note: endianness is covered by mgt_set_varlen */
=2D
=2D       attach->type =3D (WLAN_FC_TYPE_MGMT << 2) |
=2D               (WLAN_FC_STYPE_ASSOC_REQ << 4);
=2D       attach->id =3D -1;
=2D       attach->size =3D len;
=2D       memcpy(attach->data, param->u.generic_elem.data, len);
=2D
=2D       ret =3D mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach, len);
=2D
=2D       if (ret =3D=3D 0) {
=2D               attach->type =3D (WLAN_FC_TYPE_MGMT << 2) |
=2D                       (WLAN_FC_STYPE_REASSOC_REQ << 4);
=2D
=2D	       ret =3D mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach, len);
=2D
=2D	       if (ret =3D=3D 0)
=2D		       printk(KERN_DEBUG "%s: WPA IE Attachment was set\n",
=2D				       ndev->name);
=2D       }
=2D
=2D       kfree(attach);
=2D       return ret;
=2D
=2D}
=2D
=2Dstatic int
=2Dprism2_ioctl_mlme(struct net_device *dev, struct prism2_hostapd_param *p=
aram)
=2D{
=2D	return -EOPNOTSUPP;
=2D}
=2D
=2Dstatic int
=2Dprism2_ioctl_scan_req(struct net_device *ndev,
=2D                     struct prism2_hostapd_param *param)
=2D{
=2D	islpci_private *priv =3D netdev_priv(ndev);
=2D	int i, rvalue;
=2D	struct obj_bsslist *bsslist;
=2D	u32 noise =3D 0;
=2D	char *extra =3D "";
=2D	char *current_ev =3D "foo";
=2D	union oid_res_t r;
=2D
=2D	if (islpci_get_state(priv) < PRV_STATE_INIT) {
=2D		/* device is not ready, fail gently */
=2D		return 0;
=2D	}
=2D
=2D	/* first get the noise value. We will use it to report the link quality=
 */
=2D	rvalue =3D mgt_get_request(priv, DOT11_OID_NOISEFLOOR, 0, NULL, &r);
=2D	noise =3D r.u;
=2D
=2D	/* Ask the device for a list of known bss. We can report at most
=2D	 * IW_MAX_AP=3D64 to the range struct. But the device won't repport any=
thing
=2D	 * if you change the value of IWMAX_BSS=3D24.
=2D	 */
=2D	rvalue |=3D mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
=2D	bsslist =3D r.ptr;
=2D
=2D	/* ok now, scan the list and translate its info */
=2D	for (i =3D 0; i < min(IW_MAX_AP, (int) bsslist->nr); i++)
=2D		current_ev =3D prism54_translate_bss(ndev, current_ev,
=2D						   extra + IW_SCAN_MAX_DATA,
=2D						   &(bsslist->bsslist[i]),
=2D						   noise);
=2D	kfree(bsslist);
=2D
=2D	return rvalue;
=2D}
=2D
=2Dstatic int
=2Dprism54_hostapd(struct net_device *ndev, struct iw_point *p)
=2D{
=2D       struct prism2_hostapd_param *param;
=2D       int ret =3D 0;
=2D       u32 uwrq;
=2D
=2D       printk(KERN_DEBUG "prism54_hostapd - len=3D%d\n", p->length);
=2D       if (p->length < sizeof(struct prism2_hostapd_param) ||
=2D           p->length > PRISM2_HOSTAPD_MAX_BUF_SIZE || !p->pointer)
=2D               return -EINVAL;
=2D
=2D       param =3D (struct prism2_hostapd_param *) kmalloc(p->length, GFP_=
KERNEL);
=2D       if (param =3D=3D NULL)
=2D               return -ENOMEM;
=2D
=2D       if (copy_from_user(param, p->pointer, p->length)) {
=2D               kfree(param);
=2D               return -EFAULT;
=2D       }
=2D
=2D       switch (param->cmd) {
=2D       case PRISM2_SET_ENCRYPTION:
=2D	       printk(KERN_DEBUG "%s: Caught WPA supplicant set encryption requ=
est\n",
=2D			       ndev->name);
=2D               ret =3D prism2_ioctl_set_encryption(ndev, param, p->lengt=
h);
=2D               break;
=2D       case PRISM2_HOSTAPD_SET_GENERIC_ELEMENT:
=2D	       printk(KERN_DEBUG "%s: Caught WPA supplicant set WPA IE request\=
n",
=2D			       ndev->name);
=2D               ret =3D prism2_ioctl_set_generic_element(ndev, param,
=2D                                                      p->length);
=2D               break;
=2D       case PRISM2_HOSTAPD_MLME:
=2D	       printk(KERN_DEBUG "%s: Caught WPA supplicant MLME request\n",
=2D			       ndev->name);
=2D               ret =3D prism2_ioctl_mlme(ndev, param);
=2D               break;
=2D       case PRISM2_HOSTAPD_SCAN_REQ:
=2D	       printk(KERN_DEBUG "%s: Caught WPA supplicant scan request\n",
=2D			       ndev->name);
=2D               ret =3D prism2_ioctl_scan_req(ndev, param);
=2D               break;
=2D	case PRISM54_SET_WPA:
=2D	       printk(KERN_DEBUG "%s: Caught WPA supplicant wpa init request\n",
=2D			       ndev->name);
=2D	       uwrq =3D 1;
=2D	       ret =3D prism54_set_wpa(ndev, NULL, &uwrq, NULL);
=2D	       break;
=2D	case PRISM54_DROP_UNENCRYPTED:
=2D	       printk(KERN_DEBUG "%s: Caught WPA drop unencrypted request\n",
=2D			       ndev->name);
=2D#if 0
=2D	       uwrq =3D 0x01;
=2D	       mgt_set(priv, DOT11_OID_EXUNENCRYPTED, &uwrq);
=2D	       down_write(&priv->mib_sem);
=2D	       mgt_commit(priv);
=2D	       up_write(&priv->mib_sem);
=2D#endif
=2D	       /* Not necessary, as set_wpa does it, should we just do it here =
though? */
=2D	       ret =3D 0;
=2D	       break;
=2D       default:
=2D	       printk(KERN_DEBUG "%s: Caught a WPA supplicant request that is n=
ot supported\n",
=2D			       ndev->name);
=2D               ret =3D -EOPNOTSUPP;
=2D               break;
=2D       }
=2D
=2D       if (ret =3D=3D 0 && copy_to_user(p->pointer, param, p->length))
=2D               ret =3D -EFAULT;
=2D
=2D       kfree(param);
=2D
=2D       return ret;
=2D}
=2D
 static int
 prism54_set_wpa(struct net_device *ndev, struct iw_request_info *info,
 		__u32 * uwrq, char *extra)
 {
 	islpci_private *priv =3D netdev_priv(ndev);
=2D	u32 mlme, authen, dot1x, filter, wep;
+	u32 mlme, dot1x;
=20
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return 0;
=20
=2D	wep =3D 1; /* For privacy invoked */
=2D	filter =3D 1; /* Filter out all unencrypted frames */
=2D	dot1x =3D 0x01; /* To enable eap filter */
=2D	mlme =3D DOT11_MLME_EXTENDED;
=2D	authen =3D DOT11_AUTH_OS; /* Only WEP uses _SK and _BOTH */
+	dot1x =3D 0; // disable global filtering
+	mlme =3D DOT11_MLME_AUTO;
=20
 	down_write(&priv->mib_sem);
 	priv->wpa =3D *uwrq;
=20
=2D	switch (priv->wpa) {
=2D		default:
=2D		case 0: /* Clears/disables WPA and friends */
=2D			wep =3D 0;
=2D			filter =3D 0; /* Do not filter un-encrypted data */
=2D			dot1x =3D 0;
=2D			mlme =3D DOT11_MLME_AUTO;
=2D			printk("%s: Disabling WPA\n", ndev->name);
=2D			break;
=2D		case 2:
=2D		case 1: /* WPA */
=2D			printk("%s: Enabling WPA\n", ndev->name);
=2D			break;
+	if (priv->wpa) {
+		if (priv->iw_mode =3D=3D IW_MODE_MASTER)
+			dot1x =3D 1;
+		mlme =3D DOT11_MLME_EXTENDED;
 	}
 	up_write(&priv->mib_sem);
=20
=2D	mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
=2D	mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &wep);
=2D	mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0, &filter);
 	mgt_set_request(priv, DOT11_OID_DOT1XENABLE, 0, &dot1x);
 	mgt_set_request(priv, DOT11_OID_MLMEAUTOLEVEL, 0, &mlme);
=20
=2D	return 0;
+	return prism54_set_auth_alg(priv, IW_ENCODE_OPEN);
 }
=20
 static int
@@ -2890,7 +2455,9 @@ prism54_get_wpa(struct net_device *ndev,
 		__u32 * uwrq, char *extra)
 {
 	islpci_private *priv =3D netdev_priv(ndev);
+	down_write(&priv->mib_sem);
 	*uwrq =3D priv->wpa;
+	up_write(&priv->mib_sem);
 	return 0;
 }
=20
@@ -3025,6 +2592,80 @@ prism54_set_spy(struct net_device *ndev,
 	return iw_handler_set_spy(ndev, info, uwrq, extra);
 }
=20
+static int
+prism54_send_mlme(struct net_device *ndev, struct iw_request_info *info,
+		  struct iw_point *dwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	struct iw_mlme *iwmlme;
+	struct obj_mlme mlme;
+	struct obj_sta *sta;
+	union oid_res_t r;
+	int ret =3D 0;
+=09
+	if (dwrq->length !=3D sizeof(*iwmlme))
+		return -EINVAL;
+
+	iwmlme =3D (struct iw_mlme*)extra;
+
+	if (iwmlme->addr.sa_family !=3D ARPHRD_ETHER)
+		return -EINVAL;
+
+	/* get STA/AP Id.
+	   or the card will BROADCAST the packet! */
+
+	sta =3D (struct obj_sta*)kzalloc(sizeof(*sta), GFP_KERNEL);
+	if (!sta)
+		return -ENOMEM;
+
+	memcpy(sta->address, iwmlme->addr.sa_data, ETH_ALEN);
+	ret =3D mgt_get_request(priv, DOT11_OID_CLIENTFIND, 0, sta, &r);
+	kfree(sta);
+
+	if (ret) {
+		sta =3D r.ptr;
+		memcpy(mlme.address, iwmlme->addr.sa_data, ETH_ALEN);
+=09
+		if (sta->node >=3D 1)
+			mlme.id =3D sta->node;=20
+		else
+			mlme.id =3D -1;
+	} else
+		/* use broadcast id */
+		mlme.id =3D -1;
+
+	mlme.code =3D iwmlme->reason_code;
+
+	kfree(r.ptr);
+	switch (iwmlme->cmd) {
+	case IW_MLME_DEAUTH:
+		mlme.state =3D DOT11_STATE_NONE;
+		return mgt_set_request(priv, DOT11_OID_DEAUTHENTICATE,
+				       0, &mlme);
+		break;
+	case IW_MLME_DISASSOC:
+		mlme.state =3D DOT11_STATE_NONE;
+		return mgt_set_request(priv, DOT11_OID_DISASSOCIATE,
+				       0, &mlme);
+		break;
+#if 0
+	/* not in WEXT yet */
+	case IW_MLME_AUTH:
+		mlme.state =3D DOT11_STATE_AUTH;
+		return mgt_set_request(priv, DOT11_OID_AUTHENTICATE,
+				       0, &mlme);
+		break;
+	case IW_MLME_ASSOC:
+		mlme.state =3D DOT11_STATE_ASSOC;
+		return mgt_set_request(priv, DOT11_OID_ASSOCIATE,
+				       0, &mlme);
+		break;
+#endif
+	}
+=09
+	return -EOPNOTSUPP;
+}
+
 static const iw_handler prism54_handler[] =3D {
 	(iw_handler) prism54_commit,	/* SIOCSIWCOMMIT */
 	(iw_handler) prism54_get_name,	/* SIOCGIWNAME */
@@ -3042,13 +2683,13 @@ static const iw_handler prism54_handler[
 	(iw_handler) NULL,	/* SIOCGIWPRIV */
 	(iw_handler) NULL,	/* SIOCSIWSTATS */
 	(iw_handler) NULL,	/* SIOCGIWSTATS */
=2D	prism54_set_spy,	/* SIOCSIWSPY */
+	(iw_handler) prism54_set_spy,	/* SIOCSIWSPY */
 	iw_handler_get_spy,	/* SIOCGIWSPY */
 	iw_handler_set_thrspy,	/* SIOCSIWTHRSPY */
 	iw_handler_get_thrspy,	/* SIOCGIWTHRSPY */
 	(iw_handler) prism54_set_wap,	/* SIOCSIWAP */
 	(iw_handler) prism54_get_wap,	/* SIOCGIWAP */
=2D	(iw_handler) NULL,	/* -- hole -- */
+	(iw_handler) prism54_send_mlme,	/* SIOCSIWMLME */
 	(iw_handler) NULL,	/* SIOCGIWAPLIST depreciated */
 	(iw_handler) prism54_set_scan,	/* SIOCSIWSCAN */
 	(iw_handler) prism54_get_scan,	/* SIOCGIWSCAN */
@@ -3072,15 +2713,15 @@ static const iw_handler prism54_handler[
 	(iw_handler) prism54_get_encode,	/* SIOCGIWENCODE */
 	(iw_handler) NULL,	/* SIOCSIWPOWER */
 	(iw_handler) NULL,	/* SIOCGIWPOWER */
=2D	NULL,			/* -- hole -- */
=2D	NULL,			/* -- hole -- */
+	(iw_handler) NULL,	/* -- hole -- */
+	(iw_handler) NULL,	/* -- hole -- */
 	(iw_handler) prism54_set_genie,	/* SIOCSIWGENIE */
 	(iw_handler) prism54_get_genie,	/* SIOCGIWGENIE */
 	(iw_handler) prism54_set_auth,	/* SIOCSIWAUTH */
 	(iw_handler) prism54_get_auth,	/* SIOCGIWAUTH */
=2D	(iw_handler) prism54_set_encodeext, /* SIOCSIWENCODEEXT */
=2D	(iw_handler) prism54_get_encodeext, /* SIOCGIWENCODEEXT */
=2D	NULL,			/* SIOCSIWPMKSA */
+	(iw_handler) prism54_set_encodeext,	/* SIOCSIWENCODEEXT */
+	(iw_handler) prism54_get_encodeext,	/* SIOCGIWENCODEEXT */
+	(iw_handler) NULL			/* SIOCSIWPMKSA */
 };
=20
 /* The low order bit identify a SET (0) or a GET (1) ioctl.  */
@@ -3259,14 +2900,5 @@ const struct iw_handler_def prism54_hand
 int
 prism54_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
=2D	struct iwreq *wrq =3D (struct iwreq *) rq;
=2D	int ret =3D -1;
=2D	switch (cmd) {
=2D		case PRISM54_HOSTAPD:
=2D		if (!capable(CAP_NET_ADMIN))
=2D		return -EPERM;
=2D		ret =3D prism54_hostapd(ndev, &wrq->u.data);
=2D		return ret;
=2D	}
 	return -EOPNOTSUPP;
 }
diff --git a/drivers/net/wireless/prism54/isl_ioctl.h b/drivers/net/wireles=
s/prism54/isl_ioctl.h
index e8183d3..8322133 100644
=2D-- a/drivers/net/wireless/prism54/isl_ioctl.h
+++ b/drivers/net/wireless/prism54/isl_ioctl.h
@@ -1,4 +1,5 @@
 /*
+ * =20
  *  Copyright (C) 2002 Intersil Americas Inc.
  *            (C) 2003 Aurelien Alleaume <slts@free.fr>
  *            (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
@@ -21,12 +22,11 @@
 #ifndef _ISL_IOCTL_H
 #define _ISL_IOCTL_H
=20
+#include <net/iw_handler.h>	/* New driver API */
 #include "islpci_mgt.h"
 #include "islpci_dev.h"
=20
=2D#include <net/iw_handler.h>	/* New driver API */
=2D
=2D#define SUPPORTED_WIRELESS_EXT                  19
+#define SUPPORTED_WIRELESS_EXT                  21
=20
 void prism54_mib_init(islpci_private *);
=20
diff --git a/drivers/net/wireless/prism54/isl_oid.h b/drivers/net/wireless/=
prism54/isl_oid.h
index b7534c2..88b24d6 100644
=2D-- a/drivers/net/wireless/prism54/isl_oid.h
+++ b/drivers/net/wireless/prism54/isl_oid.h
@@ -2,6 +2,7 @@
  *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
  *  Copyright (C) 2004 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
  *  Copyright (C) 2004 Aurelien Alleaume <slts@free.fr>
+ *  Copyright (C) 2006 Christian Lamparter <chunkeey@web.de>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
@@ -26,29 +27,67 @@ #define _ISL_OID_H
  * with the device firmware
  */
=20
+#define MAX_KEY_LEN 32
+
 struct obj_ssid {
 	u8 length;
=2D	char octets[33];
+	u8 octets[IW_ESSID_MAX_SIZE + 1];
 } __attribute__ ((packed));
=20
+enum dot11_priv_t {
+	DOT11_PRIV_WEP =3D 0,
+	DOT11_PRIV_TKIP =3D 1
+};
+
 struct obj_key {
 	u8 type;		/* dot11_priv_t */
 	u8 length;
=2D	char key[32];
+	u8 key[MAX_KEY_LEN];
 } __attribute__ ((packed));
=20
+enum dot11_stakey_opt_t {
+	DOT11_STAKEY_OPTION_GROUPKEY =3D 0x0000,
+	DOT11_STAKEY_OPTION_DEFAULTKEY =3D 0x0001
+};
+
+enum dot11_keyop_t {
+	DOT11_KEYOP_SET_KEY =3D 0x0000,
+	DOT11_KEYOP_REMOVE_KEY =3D 0x0001
+};
+
+struct obj_stakey {
+	u8 address[ETH_ALEN];
+	u8 keyid;
+	u8 reserved;	/* dot11_keyop_t */
+	u16 options;	/* dot11_stakey_opt_t */
+	u8 type;		/* dot11_priv_t */
+	u8 length;
+	u8 key[MAX_KEY_LEN];
+} __attribute__ ((packed));
+
+enum dot11_state_t {
+	DOT11_STATE_NONE =3D 0,
+	DOT11_STATE_AUTHING =3D 1,
+	DOT11_STATE_AUTH =3D 2,
+	DOT11_STATE_ASSOCING =3D 3,
+	DOT11_STATE_REASSOC =3D 4,
+	DOT11_STATE_ASSOC =3D 5,
+	DOT11_STATE_IBSS =3D 6,
+	DOT11_STATE_WDS =3D 7
+};
+
 struct obj_mlme {
=2D	u8 address[6];
+	u8 address[ETH_ALEN];
 	u16 id;
=2D	u16 state;
=2D	u16 code;
+	u16 state;		/* dot11_state_t */
+	u16 code;		/* WLAN_STATUS_ / WLAN_REASON_ */
 } __attribute__ ((packed));
=20
 struct obj_mlmeex {
=2D	u8 address[6];
+	u8 address[ETH_ALEN];
 	u16 id;
=2D	u16 state;
=2D	u16 code;
+	u16 state;		/* dot11_state_t */
+	u16 code;		/* WLAN_STATUS_ / WLAN_REASON_ */
 	u16 size;
 	u8 data[0];
 } __attribute__ ((packed));
@@ -59,23 +98,23 @@ struct obj_buffer {
 } __attribute__ ((packed));
=20
 struct obj_bss {
=2D	u8 address[6];
+	u8 address[ETH_ALEN];
 	int:16;			/* padding */
=20
=2D	char state;
=2D	char reserved;
=2D	short age;
+	u8 state;		/* dot11_state_t */
+	u8 reserved;
+	u16 age;
=20
=2D	char quality;
=2D	char rssi;
+	u8 quality;
+	u8 rssi;
=20
 	struct obj_ssid ssid;
=2D	short channel;
=2D	char beacon_period;
=2D	char dtim_period;
=2D	short capinfo;
=2D	short rates;
=2D	short basic_rates;
+	u16 channel;
+	u8 beacon_period;
+	u8 dtim_period;
+	u16 capinfo;	/* WLAN_CAPABILITY_ */
+	u16 rates;
+	u16 basic_rates;
 	int:16;			/* padding */
 } __attribute__ ((packed));
=20
@@ -90,14 +129,33 @@ struct obj_frequencies {
 } __attribute__ ((packed));
=20
 struct obj_attachment {
=2D	char type;
=2D	char reserved;
=2D	short id;
=2D	short size;
=2D	char data[0];
+	u8 type;	/* IEEE80211_STYPE_ */
+	u8 reserved;
+	u16 id;
+	u16 size;
+	u8 data[0];
 } __attribute__((packed));
=20
=2D/*
+struct obj_stasc {
+	u8 address[ETH_ALEN];
+	u8 keyid;
+	u8 tx_sc;
+	u8 sc[6];
+} __attribute__ ((packed));
+
+struct obj_sta {
+	u8 address[ETH_ALEN];
+	int:16;
+	u8 state;		/* dot11_state_t */
+	u8 node;		/* Station ID */
+	u16 age;
+	u8 reserved1;
+	u8 rssi;
+	u8 rate;
+	u8 reserved2;
+} __attribute__ ((packed));
+
+/*=20
  * in case everything's ok, the inlined function below will be
  * optimized away by the compiler...
  */
@@ -112,19 +170,12 @@ __bug_on_wrong_struct_sizes(void)
 	BUILD_BUG_ON(sizeof (struct obj_bss) !=3D 60);
 	BUILD_BUG_ON(sizeof (struct obj_bsslist) !=3D 4);
 	BUILD_BUG_ON(sizeof (struct obj_frequencies) !=3D 2);
+	BUILD_BUG_ON(sizeof (struct obj_sta) !=3D 16);
+	BUILD_BUG_ON(sizeof (struct obj_stasc) !=3D 14);
+	BUILD_BUG_ON(sizeof (struct obj_stakey) !=3D 44);
+	BUILD_BUG_ON(sizeof (struct obj_attachment) !=3D 6);
 }
=20
=2Denum dot11_state_t {
=2D	DOT11_STATE_NONE =3D 0,
=2D	DOT11_STATE_AUTHING =3D 1,
=2D	DOT11_STATE_AUTH =3D 2,
=2D	DOT11_STATE_ASSOCING =3D 3,
=2D
=2D	DOT11_STATE_ASSOC =3D 5,
=2D	DOT11_STATE_IBSS =3D 6,
=2D	DOT11_STATE_WDS =3D 7
=2D};
=2D
 enum dot11_bsstype_t {
 	DOT11_BSSTYPE_NONE =3D 0,
 	DOT11_BSSTYPE_INFRA =3D 1,
@@ -145,11 +196,6 @@ enum dot11_mlme_t {
 	DOT11_MLME_EXTENDED =3D 2
 };
=20
=2Denum dot11_priv_t {
=2D	DOT11_PRIV_WEP =3D 0,
=2D	DOT11_PRIV_TKIP =3D 1
=2D};
=2D
 /* Prism "Nitro" / Frameburst / "Packet Frame Grouping"
  * Value is in microseconds. Represents the # microseconds
  * the firmware will take to group frames before sending out then out
@@ -464,31 +510,32 @@ enum oid_num_t {
 	OID_NUM_LAST
 };
=20
=2D#define OID_FLAG_CACHED		0x80
=2D#define OID_FLAG_TYPE		0x7f
=2D
=2D#define OID_TYPE_U32		0x01
=2D#define OID_TYPE_SSID		0x02
=2D#define OID_TYPE_KEY		0x03
=2D#define OID_TYPE_BUFFER		0x04
=2D#define OID_TYPE_BSS		0x05
=2D#define OID_TYPE_BSSLIST	0x06
=2D#define OID_TYPE_FREQUENCIES	0x07
=2D#define OID_TYPE_MLME		0x08
=2D#define OID_TYPE_MLMEEX		0x09
=2D#define OID_TYPE_ADDR		0x0A
=2D#define OID_TYPE_RAW		0x0B
=2D#define OID_TYPE_ATTACH		0x0C
=2D
=2D/* OID_TYPE_MLMEEX is special because of a variable size field when send=
ing.
=2D * Not yet implemented (not used in driver anyway).
=2D */
+enum oid_types_t {
+	OID_TYPE_U32 =3D 0x01,
+	OID_TYPE_SSID =3D 0x02,
+	OID_TYPE_KEY =3D 0x03,
+	OID_TYPE_BUFFER =3D 0x04,
+	OID_TYPE_BSS =3D 0x05,
+	OID_TYPE_BSSLIST =3D 0x06,
+	OID_TYPE_FREQUENCIES =3D 0x07,
+	OID_TYPE_MLME =3D 0x08,
+	OID_TYPE_MLMEEX =3D 0x09,
+	OID_TYPE_ADDR =3D 0x0A,
+	OID_TYPE_RAW =3D 0x0B,
+	OID_TYPE_ATTACH =3D 0x0C,
+	OID_TYPE_STASC =3D 0x0D,
+	OID_TYPE_STAKEY =3D 0x0E,
+	OID_TYPE_STAINFO =3D 0x0F,
+
+	OID_FLAG_CACHED =3D 0x80,
+	OID_FLAG_TYPE =3D 0x7f
+};
=20
 struct oid_t {
 	enum oid_num_t oid;
=2D	short range;		/* to define a range of oid */
=2D	short size;		/* max size of the associated data */
=2D	char flags;
+	u16 range;		/* to define a range of oid */
+	u16 size;		/* max size of the associated data */
+	enum oid_types_t flags;
 };
=20
 union oid_res_t {
@@ -496,8 +543,8 @@ union oid_res_t {
 	u32 u;
 };
=20
=2D#define	IWMAX_BITRATES	20
=2D#define	IWMAX_BSS	24
+#define IWMAX_BITRATES	20
+#define IWMAX_BSS	24
 #define IWMAX_FREQ	30
 #define PRIV_STR_SIZE	1024
=20
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wirele=
ss/prism54/islpci_dev.c
index 1e0603c..e6d9b26 100644
=2D-- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -25,10 +25,10 @@ #include <linux/pci.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
 #include <linux/if_arp.h>
+#include <linux/firmware.h>
=20
 #include <asm/io.h>
=20
=2D#include "prismcompat.h"
 #include "isl_38xx.h"
 #include "isl_ioctl.h"
 #include "islpci_dev.h"
@@ -86,7 +86,7 @@ isl_upload_firmware(islpci_private *priv
 		long fw_len;
 		const u32 *fw_ptr;
=20
=2D		rc =3D request_firmware(&fw_entry, priv->firmware, PRISM_FW_PDEV);
+		rc =3D request_firmware(&fw_entry, priv->firmware, &priv->pdev->dev);
 		if (rc) {
 			printk(KERN_ERR
 			       "%s: request_firmware() failed for '%s'\n",
diff --git a/drivers/net/wireless/prism54/islpci_dev.h b/drivers/net/wirele=
ss/prism54/islpci_dev.h
index a9aa166..3d0bb8f 100644
=2D-- a/drivers/net/wireless/prism54/islpci_dev.h
+++ b/drivers/net/wireless/prism54/islpci_dev.h
@@ -71,7 +71,6 @@ struct islpci_bss_wpa_ie {
 	u8 bssid[ETH_ALEN];
 	u8 wpa_ie[MAX_WPA_IE_LEN];
 	size_t wpa_ie_len;
=2D
 };
=20
 typedef struct {
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wirele=
ss/prism54/islpci_eth.c
index 676d838..6da1f86 100644
=2D-- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -24,7 +24,6 @@ #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/if_arp.h>
=20
=2D#include "prismcompat.h"
 #include "isl_38xx.h"
 #include "islpci_eth.h"
 #include "islpci_mgt.h"
@@ -482,8 +481,7 @@ #endif
 void
 islpci_do_reset_and_wake(void *data)
 {
=2D	islpci_private *priv =3D data;
=2D
+	islpci_private *priv =3D (islpci_private *) data;
 	islpci_reset(priv, 1);
 	priv->reset_task_pending =3D 0;
 	smp_wmb();
@@ -500,13 +498,12 @@ islpci_eth_tx_timeout(struct net_device
 	statistics->tx_errors++;
=20
 	if (!priv->reset_task_pending) {
=2D		printk(KERN_WARNING
=2D			"%s: tx_timeout, scheduling reset", ndev->name);
+		printk(KERN_WARNING "%s: tx_timeout\n", ndev->name);
 		netif_stop_queue(ndev);
 		priv->reset_task_pending =3D 1;
 		schedule_work(&priv->reset_task);
 	} else {
 		printk(KERN_WARNING
=2D			"%s: tx_timeout, waiting for reset", ndev->name);
+			"%s: tx_timeout, waiting for reset\n", ndev->name);
 	}
 }
diff --git a/drivers/net/wireless/prism54/islpci_eth.h b/drivers/net/wirele=
ss/prism54/islpci_eth.h
diff --git a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wi=
reless/prism54/islpci_hotplug.c
index f6354b1..0e07c2b 100644
=2D-- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -23,7 +23,6 @@ #include <linux/delay.h>
 #include <linux/init.h> /* For __init, __exit */
 #include <linux/dma-mapping.h>
=20
=2D#include "prismcompat.h"
 #include "islpci_dev.h"
 #include "islpci_mgt.h"		/* for pc_debug */
 #include "isl_oid.h"
@@ -170,7 +169,8 @@ #endif
 	pci_set_master(pdev);
=20
 	/* enable MWI */
=2D	pci_set_mwi(pdev);
+	if (pci_set_mwi(pdev))
+		printk(KERN_ERR "%s: pci_set_mwi failed\n", DRV_NAME);
=20
 	/* setup the network device interface and its structure */
 	if (!(ndev =3D islpci_setup(pdev))) {
@@ -289,7 +289,10 @@ prism54_resume(struct pci_dev *pdev)
 	islpci_private *priv =3D ndev ? netdev_priv(ndev) : NULL;
 	BUG_ON(!priv);
=20
=2D	pci_enable_device(pdev);
+	if (pci_enable_device(pdev)) {
+		printk(KERN_ERR "%s: pci_enable_device() failed.\n", DRV_NAME);
+		return -ENODEV;
+	}
=20
 	printk(KERN_NOTICE "%s: got resume request\n", ndev->name);
=20
diff --git a/drivers/net/wireless/prism54/islpci_mgt.c b/drivers/net/wirele=
ss/prism54/islpci_mgt.c
index 036a875..8fd781d 100644
=2D-- a/drivers/net/wireless/prism54/islpci_mgt.c
+++ b/drivers/net/wireless/prism54/islpci_mgt.c
@@ -25,7 +25,6 @@ #include <asm/io.h>
 #include <asm/system.h>
 #include <linux/if_arp.h>
=20
=2D#include "prismcompat.h"
 #include "isl_38xx.h"
 #include "islpci_mgt.h"
 #include "isl_oid.h"		/* additional types and defs for isl38xx fw */
diff --git a/drivers/net/wireless/prism54/islpci_mgt.h b/drivers/net/wirele=
ss/prism54/islpci_mgt.h
diff --git a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/=
prism54/oid_mgt.c
index fbc52b6..24b5a49 100644
=2D-- a/drivers/net/wireless/prism54/oid_mgt.c
+++ b/drivers/net/wireless/prism54/oid_mgt.c
@@ -16,7 +16,6 @@
  *
  */
=20
=2D#include "prismcompat.h"
 #include "islpci_dev.h"
 #include "islpci_mgt.h"
 #include "isl_oid.h"
@@ -85,9 +84,9 @@ struct oid_t isl_oid[] =3D {
 	OID_U32_C(DOT11_OID_DEFKEYID, 0x12000003),
 	[DOT11_OID_DEFKEYX] =3D {0x12000004, 3, sizeof (struct obj_key),
 			       OID_FLAG_CACHED | OID_TYPE_KEY},	/* DOT11_OID_DEFKEY1,...DOT11_O=
ID_DEFKEY4 */
=2D	OID_UNKNOWN(DOT11_OID_STAKEY, 0x12000008),
+	OID_STRUCT(DOT11_OID_STAKEY, 0x12000008, struct obj_stakey, OID_TYPE_STAK=
EY),
 	OID_U32(DOT11_OID_REKEYTHRESHOLD, 0x12000009),
=2D	OID_UNKNOWN(DOT11_OID_STASC, 0x1200000a),
+	OID_STRUCT(DOT11_OID_STASC, 0x1200000a, struct obj_stasc, OID_TYPE_STASC),
=20
 	OID_U32(DOT11_OID_PRIVTXREJECTED, 0x1a000000),
 	OID_U32(DOT11_OID_PRIVRXPLAIN, 0x1a000001),
@@ -122,9 +121,10 @@ struct oid_t isl_oid[] =3D {
 	OID_U32(DOT11_OID_BRIDGELOCAL, 0x15000000),
 	OID_U32(DOT11_OID_CLIENTS, 0x15000001),
 	OID_U32(DOT11_OID_CLIENTSASSOCIATED, 0x15000002),
=2D	[DOT11_OID_CLIENTX] =3D {0x15000003, 2006, 0, 0},	/* DOT11_OID_CLIENTX,=
=2E..DOT11_OID_CLIENT2007 */
+	[DOT11_OID_CLIENTX] =3D {0x15000003, 2006, sizeof(struct obj_sta),
+		 OID_TYPE_STAINFO},	/* DOT11_OID_CLIENTX,...DOT11_OID_CLIENT2007 */
=20
=2D	OID_STRUCT(DOT11_OID_CLIENTFIND, 0x150007DB, u8[6], OID_TYPE_ADDR),
+	OID_STRUCT(DOT11_OID_CLIENTFIND, 0x150007DB, struct obj_sta, OID_TYPE_STA=
INFO),
 	OID_STRUCT(DOT11_OID_WDSLINKADD, 0x150007DC, u8[6], OID_TYPE_ADDR),
 	OID_STRUCT(DOT11_OID_WDSLINKREMOVE, 0x150007DD, u8[6], OID_TYPE_ADDR),
 	OID_STRUCT(DOT11_OID_EAPAUTHSTA, 0x150007DE, u8[6], OID_TYPE_ADDR),
@@ -201,8 +201,7 @@ struct oid_t isl_oid[] =3D {
 	OID_U32(DOT11_OID_STATIMEOUT, 0x19000000),
 	OID_U32_C(DOT11_OID_MLMEAUTOLEVEL, 0x19000001),
 	OID_U32(DOT11_OID_BSSTIMEOUT, 0x19000002),
=2D	[DOT11_OID_ATTACHMENT] =3D {0x19000003, 0,
=2D		sizeof(struct obj_attachment), OID_TYPE_ATTACH},
+	OID_STRUCT_C(DOT11_OID_ATTACHMENT, 0x19000003, sizeof(struct obj_attachme=
nt), OID_TYPE_ATTACH),
 	OID_STRUCT_C(DOT11_OID_PSMBUFFER, 0x19000004, struct obj_buffer,
 		     OID_TYPE_BUFFER),
=20
@@ -277,7 +276,7 @@ mgt_clean(islpci_private *priv)
 }
=20
 void
=2Dmgt_le_to_cpu(int type, void *data)
+mgt_le_to_cpu(enum oid_types_t type, void *data)
 {
 	switch (type) {
 	case OID_TYPE_U32:
@@ -334,19 +333,31 @@ mgt_le_to_cpu(int type, void *data)
 			attach->id =3D le16_to_cpu(attach->id);
 			attach->size =3D le16_to_cpu(attach->size);
 			break;
=2D	}
+		}
+	case OID_TYPE_STAKEY: {
+			struct obj_stakey *stakey =3D data;
+			stakey->options =3D le16_to_cpu(stakey->options);
+			break;
+		}
+	case OID_TYPE_STAINFO: {
+			struct obj_sta *sta =3D data;
+			sta->age =3D le16_to_cpu(sta->age);
+			break;
+		}
 	case OID_TYPE_SSID:
 	case OID_TYPE_KEY:
 	case OID_TYPE_ADDR:
 	case OID_TYPE_RAW:
+	case OID_TYPE_STASC:
 		break;
 	default:
 		BUG();
+		break;
 	}
 }
=20
 static void
=2Dmgt_cpu_to_le(int type, void *data)
+mgt_cpu_to_le(enum oid_types_t type, void *data)
 {
 	switch (type) {
 	case OID_TYPE_U32:
@@ -403,14 +414,26 @@ mgt_cpu_to_le(int type, void *data)
 			attach->id =3D cpu_to_le16(attach->id);
 			attach->size =3D cpu_to_le16(attach->size);
 			break;
=2D	}
+		}
+	case OID_TYPE_STAKEY: {
+			struct obj_stakey *stakey =3D data;
+			stakey->options =3D cpu_to_le16(stakey->options);
+			break;
+		}
+	case OID_TYPE_STAINFO: {
+			struct obj_sta *sta =3D data;
+			sta->age =3D cpu_to_le16(sta->age);
+			break;
+		}
 	case OID_TYPE_SSID:
 	case OID_TYPE_KEY:
 	case OID_TYPE_ADDR:
 	case OID_TYPE_RAW:
+	case OID_TYPE_STASC:
 		break;
 	default:
 		BUG();
+		break;
 	}
 }
=20
@@ -658,13 +681,16 @@ static enum oid_num_t commit_part1[] =3D {
=20
 static enum oid_num_t commit_part2[] =3D {
 	DOT11_OID_SSID,
+	/* problematic with WPA
 	DOT11_OID_PSMBUFFER,
+	*/
 	DOT11_OID_AUTHENABLE,
 	DOT11_OID_PRIVACYINVOKED,
 	DOT11_OID_EXUNENCRYPTED,
 	DOT11_OID_DEFKEYX,	/* MULTIPLE */
 	DOT11_OID_DEFKEYID,
 	DOT11_OID_DOT1XENABLE,
+	DOT11_OID_ATTACHMENT,
 	OID_INL_DOT11D_CONFORMANCE,
 	/* Do not initialize this - fw < 1.0.4.3 rejects it
 	OID_INL_OUTPUTPOWER,
diff --git a/drivers/net/wireless/prism54/oid_mgt.h b/drivers/net/wireless/=
prism54/oid_mgt.h
index 92c8a2d..10a5cc3 100644
=2D-- a/drivers/net/wireless/prism54/oid_mgt.h
+++ b/drivers/net/wireless/prism54/oid_mgt.h
@@ -32,7 +32,7 @@ void mgt_clean(islpci_private *);
 extern const int frequency_list_a[];
 int channel_of_freq(int);
=20
=2Dvoid mgt_le_to_cpu(int, void *);
+void mgt_le_to_cpu(enum oid_types_t, void *);
=20
 int mgt_set_request(islpci_private *, enum oid_num_t, int, void *);
 int mgt_set_varlen(islpci_private *, enum oid_num_t, void *, int);
diff --git a/drivers/net/wireless/prism54/prismcompat.h b/drivers/net/wirel=
ess/prism54/prismcompat.h
deleted file mode 100644
index aa1d174..0000000
=2D-- a/drivers/net/wireless/prism54/prismcompat.h
+++ /dev/null
@@ -1,43 +0,0 @@
=2D/*
=2D *  (C) 2004 Margit Schubert-While <margitsw@t-online.de>
=2D *
=2D *  This program is free software; you can redistribute it and/or modify
=2D *  it under the terms of the GNU General Public License as published by
=2D *  the Free Software Foundation; either version 2 of the License
=2D *
=2D *  This program is distributed in the hope that it will be useful,
=2D *  but WITHOUT ANY WARRANTY; without even the implied warranty of
=2D *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
=2D *  GNU General Public License for more details.
=2D *
=2D *  You should have received a copy of the GNU General Public License
=2D *  along with this program; if not, write to the Free Software
=2D *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307=
  USA
=2D *
=2D */
=2D
=2D/*
=2D *	Compatibility header file to aid support of different kernel versions
=2D */
=2D
=2D#ifdef PRISM54_COMPAT24
=2D#include "prismcompat24.h"
=2D#else	/* PRISM54_COMPAT24 */
=2D
=2D#ifndef _PRISM_COMPAT_H
=2D#define _PRISM_COMPAT_H
=2D
=2D#include <linux/device.h>
=2D#include <linux/firmware.h>
=2D#include <linux/moduleparam.h>
=2D#include <linux/workqueue.h>
=2D#include <linux/compiler.h>
=2D
=2D#ifndef __iomem
=2D#define __iomem
=2D#endif
=2D
=2D#define PRISM_FW_PDEV		&priv->pdev->dev
=2D
=2D#endif				/* _PRISM_COMPAT_H */
=2D#endif				/* PRISM54_COMPAT24 */
diff --git a/scripts/package/Makefile b/scripts/package/Makefile
diff --git a/scripts/package/builddeb b/scripts/package/builddeb
diff --git a/scripts/package/buildtar b/scripts/package/buildtar
diff --git a/scripts/package/mkspec b/scripts/package/mkspec

--Boundary-00=_R24RFAeYx9cH2y/--
