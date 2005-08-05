From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: atheros driver (6/8)
Date: Fri, 05 Aug 2005 05:00:23 +0200
Message-ID: <42F2D647.7040507@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040002030804010504080609"
Cc: netdev <netdev@vger.kernel.org>
Return-path: <kernel-mentors-bounces@selenic.com>
To: kernel-mentors@selenic.com
List-Unsubscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://www.selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040002030804010504080609
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit



--------------040002030804010504080609
Content-Type: text/x-patch;
 name="atheros5212-6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="atheros5212-6.patch"

diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/ioctl.c netdev-atheros/drivers/net/wireless/atheros/atheros5212/ioctl.c
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/ioctl.c	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/ioctl.c	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,590 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * derived or copied parts of code licensed under
+ * dual GPL/BSD license
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ * 
+ * rest of the code has been reverse engineered by Mateusz Berezecki
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+
+#include <net/iw_handler.h>
+#include <linux/wireless.h>
+#include <net/ieee80211.h>
+
+#include "atheros_id.h"
+#include "atheros_dev.h"
+#include "atheros_defs.h"
+#include "atheros_registers.h"
+#include "atheros.h"
+#include "eeprom.h"
+#include "interrupts.h"
+#include "regops.h"
+#include "powermodes.h"
+#include "transmit_receive.h"
+#include "chans.h"
+
+
+/*
+ * These are just templates for future expansion. I would have done
+ * that already but unfortunately I have to get familiar with
+ * new ieee80211 API first... Help!!! ;-p
+ */
+
+int ath_ioctl_giwname(struct net_device *netdev, struct iw_request_info *info, 
+		char *name, char *extra)
+{
+	struct ieee80211_device *dev = netdev_priv(netdev);
+	
+	switch (dev->mode) {
+		case IEEE_A:
+			strncpy(name, "IEEE 802.11a", IFNAMSIZ);
+			break;
+		case IEEE_B:
+			strncpy(name, "IEEE 802.11b", IFNAMSIZ);
+			break;
+		case IEEE_G:
+			strncpy(name, "IEEE 802.11b", IFNAMSIZ);
+			break;
+		default:
+			strncpy(name, "IEEE 802.11", IFNAMSIZ);
+			break;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(ath_ioctl_giwname);
+
+int ath_ioctl_siwencode(struct net_device *netdev, 
+		struct iw_request_info *info,
+		struct iw_point *erq, char *extra)
+{
+	/* not yet supported */
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwencode);
+
+int ath_ioctl_giwencode(struct net_device *netdev, 
+		struct iw_request_info *info, 
+		struct iw_point *erq, char *extra)
+{
+	/* not yet supported */
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwencode);
+
+int ath_ioctl_siwrate(struct net_device *netdev, 
+		struct iw_request_info *info, 
+		struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwrate);
+
+int ath_ioctl_giwrate(struct net_device *netdev, struct iw_request_info *info, struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwrate);
+
+int ath_ioctl_siwsens(struct net_device *netdev, struct iw_request_info *info, struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwsens);
+
+int ath_ioctl_giwsens(struct net_device *netdev, struct iw_request_info *info, struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwsens);
+
+int ath_ioctl_siwrts(struct net_device *netdev, struct iw_request_info *info, struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwrts);
+
+int ath_ioctl_giwrts(struct net_device *netdev, struct iw_request_info *info, struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwrts);
+
+int ath_ioctl_siwfrag(struct net_device *netdev, struct iw_request_info *info, struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwfrag);
+
+int ath_ioctl_giwfrag(struct net_device *netdev, struct iw_request_info *info, struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwfrag);
+
+int ath_ioctl_siwap(struct net_device *netdev, struct iw_request_info *info, struct sockaddr *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwap);
+
+int ath_ioctl_giwap(struct net_device *netdev, struct iw_request_info *info, struct sockaddr *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwap);
+
+int ath_ioctl_siwnickn(struct net_device *netdev, struct iw_request_info *info, struct iw_point *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwnickn);
+
+int ath_ioctl_giwnickn(struct net_device *netdev, struct iw_request_info *info, struct iw_point *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwnickn);
+
+int ath_ioctl_siwfreq(struct net_device *netdev, struct iw_request_info *info, struct iw_freq *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwfreq);
+
+int ath_ioctl_giwfreq(struct net_device *netdev, struct iw_request_info *info, struct iw_freq *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwfreq);
+
+int ath_ioctl_siwessid(struct net_device *netdev, struct iw_request_info *info, struct iw_point *erq, char *extra)
+{
+	/* XXX: set essid. have to take a look at 
+	 * ieee80211_* files to take a look at 
+	 * how to use ieee80211_network structure */
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwessid);
+
+int ath_ioctl_giwessid(struct net_device *netdev, struct iw_request_info *info, struct iw_point *erq, char *extra)
+{
+	/* TODO: return current extended service set ID 
+	 * ref: take a look above if you are curious
+	 * why it is not implemented yet */
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwessid);
+
+int ath_ioctl_giwrange(struct net_device *netdev, struct iw_request_info *info, struct iw_point *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwrange);
+
+int ath_ioctl_siwmode(struct net_device *netdev, struct iw_request_info *info, unsigned int *erq, char *extra)
+{
+	
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwmode);
+
+int ath_ioctl_giwmode(struct net_device *netdev, struct iw_request_info *info, unsigned int *erq, char *extra)
+{
+	
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwmode);
+
+int ath_ioctl_siwpower(struct net_device *netdev, struct iw_request_info *info, struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwpower);
+
+int ath_ioctl_giwpower(struct net_device *netdev, struct iw_request_info *info, struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwpower);
+
+int ath_ioctl_siwretry(struct net_device *netdev, struct iw_request_info *info, struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwretry);
+
+int ath_ioctl_giwretry(struct net_device *netdev, struct iw_request_info *info, struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwretry);
+
+int ath_ioctl_siwtxpow(struct net_device *netdev, struct iw_request_info *info, struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwtxpow);
+
+int ath_ioctl_giwtxpow(struct net_device *netdev, struct iw_request_info *info, struct iw_param *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwtxpow);
+
+int ath_ioctl_iwaplist(struct net_device *netdev, struct iw_request_info *info, struct iw_point *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_iwaplist);
+
+#ifdef SIOCGIWSCAN
+int ath_ioctl_siwscan(struct net_device *netdev, struct iw_request_info *info, struct iw_point *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_siwscan);
+
+int ath_ioctl_giwscan(struct net_device *netdev, struct iw_request_info *info, struct iw_point *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_giwscan);
+#endif
+
+int ath_ioctl_setparam(struct net_device *netdev, struct iw_request_info *info, void *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_setparam);
+
+int ath_ioctl_getparam(struct net_device *netdev, struct iw_request_info *info, void *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_getparam);
+
+int ath_ioctl_setkey(struct net_device *netdev, struct iw_request_info *info, void *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_setkey);
+
+int ath_ioctl_delkey(struct net_device *netdev, struct iw_request_info *info, void *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_delkey);
+
+int ath_ioctl_setmlme(struct net_device *netdev, struct iw_request_info *info, void *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_setmlme);
+
+int ath_ioctl_setoptie(struct net_device *netdev, struct iw_request_info *info, void *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_setoptie);
+
+int ath_ioctl_getoptie(struct net_device *netdev, struct iw_request_info *info, void *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_getoptie);
+
+int ath_ioctl_addmac(struct net_device *netdev, struct iw_request_info *info, void *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_addmac);
+
+int ath_ioctl_delmac(struct net_device *netdev, struct iw_request_info *info, void *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_delmac);
+
+int ath_ioctl_chanlist(struct net_device *netdev, struct iw_request_info *info, void *erq, char *extra)
+{
+	return -1;
+}
+EXPORT_SYMBOL(ath_ioctl_chanlist);
+
+/* Structures to export the Wireless Handlers */
+const iw_handler ath_handlers[] = {
+	(iw_handler) NULL,				/* SIOCSIWCOMMIT */
+	(iw_handler) ath_ioctl_giwname,			/* SIOCGIWNAME */
+	(iw_handler) NULL,				/* SIOCSIWNWID */
+	(iw_handler) NULL,				/* SIOCGIWNWID */
+	(iw_handler) ath_ioctl_siwfreq,			/* SIOCSIWFREQ */
+	(iw_handler) ath_ioctl_giwfreq,			/* SIOCGIWFREQ */
+	(iw_handler) ath_ioctl_siwmode,			/* SIOCSIWMODE */
+	(iw_handler) ath_ioctl_giwmode,			/* SIOCGIWMODE */
+	(iw_handler) ath_ioctl_siwsens,			/* SIOCSIWSENS */
+	(iw_handler) ath_ioctl_giwsens,			/* SIOCGIWSENS */
+	(iw_handler) NULL /* not used */,		/* SIOCSIWRANGE */
+	(iw_handler) ath_ioctl_giwrange,		/* SIOCGIWRANGE */
+	(iw_handler) NULL /* not used */,		/* SIOCSIWPRIV */
+	(iw_handler) NULL /* kernel code */,		/* SIOCGIWPRIV */
+	(iw_handler) NULL /* not used */,		/* SIOCSIWSTATS */
+	(iw_handler) NULL /* kernel code */,		/* SIOCGIWSTATS */
+	(iw_handler) NULL,				/* SIOCSIWSPY */
+	(iw_handler) NULL,				/* SIOCGIWSPY */
+	(iw_handler) NULL,				/* -- hole -- */
+	(iw_handler) NULL,				/* -- hole -- */
+	(iw_handler) ath_ioctl_siwap,			/* SIOCSIWAP */
+	(iw_handler) ath_ioctl_giwap,			/* SIOCGIWAP */
+	(iw_handler) NULL,				/* -- hole -- */
+	(iw_handler) ath_ioctl_iwaplist,		/* SIOCGIWAPLIST */
+#ifdef SIOCGIWSCAN
+	(iw_handler) ath_ioctl_siwscan,			/* SIOCSIWSCAN */
+	(iw_handler) ath_ioctl_giwscan,			/* SIOCGIWSCAN */
+#else
+	(iw_handler) NULL,				/* SIOCSIWSCAN */
+	(iw_handler) NULL,				/* SIOCGIWSCAN */
+#endif /* SIOCGIWSCAN */
+	(iw_handler) ath_ioctl_siwessid,		/* SIOCSIWESSID */
+	(iw_handler) ath_ioctl_giwessid,		/* SIOCGIWESSID */
+	(iw_handler) ath_ioctl_siwnickn,		/* SIOCSIWNICKN */
+	(iw_handler) ath_ioctl_giwnickn,		/* SIOCGIWNICKN */
+	(iw_handler) NULL,				/* -- hole -- */
+	(iw_handler) NULL,				/* -- hole -- */
+	(iw_handler) ath_ioctl_siwrate,			/* SIOCSIWRATE */
+	(iw_handler) ath_ioctl_giwrate,			/* SIOCGIWRATE */
+	(iw_handler) ath_ioctl_siwrts,			/* SIOCSIWRTS */
+	(iw_handler) ath_ioctl_giwrts,			/* SIOCGIWRTS */
+	(iw_handler) ath_ioctl_siwfrag,			/* SIOCSIWFRAG */
+	(iw_handler) ath_ioctl_giwfrag,			/* SIOCGIWFRAG */
+	(iw_handler) ath_ioctl_siwtxpow,		/* SIOCSIWTXPOW */
+	(iw_handler) ath_ioctl_giwtxpow,		/* SIOCGIWTXPOW */
+	(iw_handler) ath_ioctl_siwretry,		/* SIOCSIWRETRY */
+	(iw_handler) ath_ioctl_giwretry,		/* SIOCGIWRETRY */
+	(iw_handler) ath_ioctl_siwencode,		/* SIOCSIWENCODE */
+	(iw_handler) ath_ioctl_giwencode,		/* SIOCGIWENCODE */
+	(iw_handler) ath_ioctl_siwpower,		/* SIOCSIWPOWER */
+	(iw_handler) ath_ioctl_giwpower,		/* SIOCGIWPOWER */
+};
+
+const iw_handler ath_priv_handlers[] = {
+	(iw_handler) ath_ioctl_setparam,		/* SIOCWFIRSTPRIV+0 */
+	(iw_handler) ath_ioctl_getparam,		/* SIOCWFIRSTPRIV+1 */
+	(iw_handler) ath_ioctl_setkey,			/* SIOCWFIRSTPRIV+2 */
+	(iw_handler) NULL,				/* SIOCWFIRSTPRIV+3 */
+	(iw_handler) ath_ioctl_delkey,			/* SIOCWFIRSTPRIV+4 */
+	(iw_handler) NULL,				/* SIOCWFIRSTPRIV+5 */
+	(iw_handler) ath_ioctl_setmlme,			/* SIOCWFIRSTPRIV+6 */
+	(iw_handler) NULL,				/* SIOCWFIRSTPRIV+7 */
+	(iw_handler) ath_ioctl_setoptie,		/* SIOCWFIRSTPRIV+8 */
+	(iw_handler) ath_ioctl_getoptie,		/* SIOCWFIRSTPRIV+9 */
+	(iw_handler) ath_ioctl_addmac,			/* SIOCWFIRSTPRIV+10 */
+	(iw_handler) NULL,				/* SIOCWFIRSTPRIV+11 */
+	(iw_handler) ath_ioctl_delmac,			/* SIOCWFIRSTPRIV+12 */
+	(iw_handler) NULL,				/* SIOCWFIRSTPRIV+13 */
+	(iw_handler) ath_ioctl_chanlist,		/* SIOCWFIRSTPRIV+14 */
+};
+
+struct iw_handler_def ath_iw_handler_def = {
+#define	N(a)	(sizeof (a) / sizeof (a[0]))
+	.standard		= (iw_handler *) ath_handlers,
+	.num_standard		= N(ath_handlers),
+	.private		= (iw_handler *) ath_priv_handlers,
+	.num_private		= N(ath_priv_handlers),
+#undef N
+};
+
+#define	IW_PRIV_TYPE_OPTIE	IW_PRIV_TYPE_BYTE | IEEE80211_MAX_OPT_IE
+#define	IW_PRIV_TYPE_KEY \
+	IW_PRIV_TYPE_BYTE | sizeof(struct ieee80211req_key)
+#define	IW_PRIV_TYPE_DELKEY \
+	IW_PRIV_TYPE_BYTE | sizeof(struct ieee80211req_del_key)
+#define	IW_PRIV_TYPE_MLME \
+	IW_PRIV_TYPE_BYTE | sizeof(struct ieee80211req_mlme)
+#define	IW_PRIV_TYPE_CHANLIST \
+	IW_PRIV_TYPE_BYTE | sizeof(struct ieee80211req_chanlist)
+
+#ifdef NOT_YET
+const struct iw_priv_args ieee80211_priv_args[] = {
+	/* NB: setoptie & getoptie are !IW_PRIV_SIZE_FIXED */
+	{ IEEE80211_IOCTL_SETOPTIE,
+	  IW_PRIV_TYPE_OPTIE, 0,			"setoptie" },
+	{ IEEE80211_IOCTL_GETOPTIE,
+	  0, IW_PRIV_TYPE_OPTIE,			"getoptie" },
+	{ IEEE80211_IOCTL_SETKEY,
+	  IW_PRIV_TYPE_KEY | IW_PRIV_SIZE_FIXED, 0,	"setkey" },
+	{ IEEE80211_IOCTL_DELKEY,
+	  IW_PRIV_TYPE_DELKEY | IW_PRIV_SIZE_FIXED, 0,	"delkey" },
+	{ IEEE80211_IOCTL_SETMLME,
+	  IW_PRIV_TYPE_MLME | IW_PRIV_SIZE_FIXED, 0,	"setmlme" },
+	{ IEEE80211_IOCTL_ADDMAC,
+	  IW_PRIV_TYPE_ADDR | IW_PRIV_SIZE_FIXED | 1, 0,"addmac" },
+	{ IEEE80211_IOCTL_DELMAC,
+	  IW_PRIV_TYPE_ADDR | IW_PRIV_SIZE_FIXED | 1, 0,"delmac" },
+	{ IEEE80211_IOCTL_CHANLIST,
+	  IW_PRIV_TYPE_CHANLIST | IW_PRIV_SIZE_FIXED, 0,"chanlist" },
+#if WIRELESS_EXT >= 12
+	{ IEEE80211_IOCTL_SETPARAM,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 2, 0, "setparam" },
+	/*
+	 * These depends on sub-ioctl support which added in version 12.
+	 */
+	{ IEEE80211_IOCTL_GETPARAM,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,	"getparam" },
+
+	/* sub-ioctl handlers */
+	{ IEEE80211_IOCTL_SETPARAM,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "" },
+	{ IEEE80211_IOCTL_GETPARAM,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "" },
+
+	/* sub-ioctl definitions */
+	{ IEEE80211_PARAM_TURBO,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "turbo" },
+	{ IEEE80211_PARAM_TURBO,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_turbo" },
+	{ IEEE80211_PARAM_MODE,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "mode" },
+	{ IEEE80211_PARAM_MODE,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_mode" },
+	{ IEEE80211_PARAM_AUTHMODE,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "authmode" },
+	{ IEEE80211_PARAM_AUTHMODE,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_authmode" },
+	{ IEEE80211_PARAM_PROTMODE,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "protmode" },
+	{ IEEE80211_PARAM_PROTMODE,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_protmode" },
+	{ IEEE80211_PARAM_MCASTCIPHER,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "mcastcipher" },
+	{ IEEE80211_PARAM_MCASTCIPHER,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_mcastcipher" },
+	{ IEEE80211_PARAM_MCASTKEYLEN,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "mcastkeylen" },
+	{ IEEE80211_PARAM_MCASTKEYLEN,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_mcastkeylen" },
+	{ IEEE80211_PARAM_UCASTCIPHERS,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "ucastciphers" },
+	{ IEEE80211_PARAM_UCASTCIPHERS,
+	/*
+	 * NB: can't use "get_ucastciphers" 'cuz iwpriv command names
+	 *     must be <IFNAMESIZ which is 16.
+	 */
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_uciphers" },
+	{ IEEE80211_PARAM_UCASTCIPHER,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "ucastcipher" },
+	{ IEEE80211_PARAM_UCASTCIPHER,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_ucastcipher" },
+	{ IEEE80211_PARAM_UCASTKEYLEN,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "ucastkeylen" },
+	{ IEEE80211_PARAM_UCASTKEYLEN,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_ucastkeylen" },
+	{ IEEE80211_PARAM_KEYMGTALGS,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "keymgtalgs" },
+	{ IEEE80211_PARAM_KEYMGTALGS,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_keymgtalgs" },
+	{ IEEE80211_PARAM_RSNCAPS,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "rsncaps" },
+	{ IEEE80211_PARAM_RSNCAPS,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_rsncaps" },
+	{ IEEE80211_PARAM_ROAMING,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "roaming" },
+	{ IEEE80211_PARAM_ROAMING,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_roaming" },
+	{ IEEE80211_PARAM_PRIVACY,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "privacy" },
+	{ IEEE80211_PARAM_PRIVACY,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_privacy" },
+	{ IEEE80211_PARAM_COUNTERMEASURES,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "countermeasures" },
+	{ IEEE80211_PARAM_COUNTERMEASURES,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_countermeas" },
+	{ IEEE80211_PARAM_DROPUNENCRYPTED,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "dropunencrypted" },
+	{ IEEE80211_PARAM_DROPUNENCRYPTED,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_dropunencry" },
+	{ IEEE80211_PARAM_WPA,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "wpa" },
+	{ IEEE80211_PARAM_WPA,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_wpa" },
+	{ IEEE80211_PARAM_DRIVER_CAPS,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "driver_caps" },
+	{ IEEE80211_PARAM_DRIVER_CAPS,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_driver_caps" },
+	{ IEEE80211_PARAM_MACCMD,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "maccmd" },
+	{ IEEE80211_PARAM_WME,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "wme" },
+	{ IEEE80211_PARAM_WME,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_wme" },
+	{ IEEE80211_PARAM_HIDESSID,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "hide_ssid" },
+	{ IEEE80211_PARAM_HIDESSID,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_hide_ssid" },
+	{ IEEE80211_PARAM_APBRIDGE,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "ap_bridge" },
+	{ IEEE80211_PARAM_APBRIDGE,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_ap_bridge" },
+	{ IEEE80211_PARAM_INACT,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "inact" },
+	{ IEEE80211_PARAM_INACT,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_inact" },
+	{ IEEE80211_PARAM_INACT_AUTH,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "inact_auth" },
+	{ IEEE80211_PARAM_INACT_AUTH,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_inact_auth" },
+	{ IEEE80211_PARAM_INACT_INIT,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "inact_init" },
+	{ IEEE80211_PARAM_INACT_INIT,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_inact_init" },
+	{ IEEE80211_PARAM_IBSS,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "ibss" },
+	{ IEEE80211_PARAM_IBSS,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_ibss" },
+	{ IEEE80211_PARAM_PUREG,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "pureg" },
+	{ IEEE80211_PARAM_PUREG,
+	  0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, "get_pureg" },
+	{ IEEE80211_PARAM_RESET,
+	  IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "reset" },
+#endif /* WIRELESS_EXT >= 12 */
+};
+
+unsigned int get_priv_size()
+{
+	return (sizeof(ieee80211_priv_args)/
+		sizeof(ieee80211_priv_args[0]));
+}
+
+#endif
+


--------------040002030804010504080609
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Kernel-mentors mailing list
Kernel-mentors@selenic.com
http://selenic.com/mailman/listinfo/kernel-mentors

--------------040002030804010504080609--
