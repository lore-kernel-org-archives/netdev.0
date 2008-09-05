From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 04/18] netdevice: safe convert to netdev_priv() #part-4
Date: Fri, 05 Sep 2008 11:11:38 +0800
Message-ID: <48C0A36A.3070602@cn.fujitsu.com>
References: <48C0A219.2030004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53624 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756158AbYIEDOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 23:14:04 -0400
In-Reply-To: <48C0A219.2030004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/wireless/libertas/wext.c |   72 ++++++++++++++--------------
 drivers/net/wireless/rndis_wlan.c    |   62 ++++++++++++------------
 drivers/net/wireless/wavelan.c       |   88 ++++++++++++++++-----------------
 drivers/net/znet.c                   |   22 ++++----
 net/appletalk/ddp.c                  |    2 +-
 net/atm/br2684.c                     |    2 +-
 net/atm/lec.c                        |   34 +++++++------
 net/atm/mpc.c                        |   10 ++--
 net/bluetooth/bnep/core.c            |    2 +-
 net/bluetooth/bnep/netdev.c          |    6 +-
 net/bridge/br_if.c                   |    2 +-
 net/bridge/br_sysfs_br.c             |    2 +-
 net/irda/irlan/irlan_common.c        |    2 +-
 13 files changed, 153 insertions(+), 153 deletions(-)

diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index 8b3ed77..c9b2331 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -183,7 +183,7 @@ static int lbs_get_name(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_freq(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_freq *fwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct chan_freq_power *cfp;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -209,7 +209,7 @@ static int lbs_get_freq(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_wap(struct net_device *dev, struct iw_request_info *info,
 			struct sockaddr *awrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -227,7 +227,7 @@ static int lbs_get_wap(struct net_device *dev, struct iw_request_info *info,
 static int lbs_set_nick(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -251,7 +251,7 @@ static int lbs_set_nick(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_nick(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -268,7 +268,7 @@ static int lbs_get_nick(struct net_device *dev, struct iw_request_info *info,
 static int mesh_get_nick(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -293,7 +293,7 @@ static int lbs_set_rts(struct net_device *dev, struct iw_request_info *info,
 			struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	u32 rthr = vwrq->value;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -318,7 +318,7 @@ static int lbs_get_rts(struct net_device *dev, struct iw_request_info *info,
 			struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -344,7 +344,7 @@ static int lbs_set_frag(struct net_device *dev, struct iw_request_info *info,
 {
 	int ret = 0;
 	u32 fthr = vwrq->value;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -369,7 +369,7 @@ static int lbs_get_frag(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -394,7 +394,7 @@ out:
 static int lbs_get_mode(struct net_device *dev,
 			 struct iw_request_info *info, u32 * uwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -421,7 +421,7 @@ static int lbs_get_txpow(struct net_device *dev,
 			  struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -452,7 +452,7 @@ static int lbs_set_retry(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -486,7 +486,7 @@ out:
 static int lbs_get_retry(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int ret = 0;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -554,7 +554,7 @@ static int lbs_get_range(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_point *dwrq, char *extra)
 {
 	int i, j;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct iw_range *range = (struct iw_range *)extra;
 	struct chan_freq_power *cfp;
 	u8 rates[MAX_RATES + 1];
@@ -730,7 +730,7 @@ out:
 static int lbs_set_power(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -780,7 +780,7 @@ static int lbs_set_power(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_power(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -803,7 +803,7 @@ static struct iw_statistics *lbs_get_wireless_stats(struct net_device *dev)
 		EXCELLENT = 95,
 		PERFECT = 100
 	};
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	u32 rssi_qual;
 	u32 tx_qual;
 	u32 quality = 0;
@@ -908,7 +908,7 @@ static int lbs_set_freq(struct net_device *dev, struct iw_request_info *info,
 		  struct iw_freq *fwrq, char *extra)
 {
 	int ret = -EINVAL;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct chan_freq_power *cfp;
 	struct assoc_request * assoc_req;
 
@@ -965,7 +965,7 @@ static int lbs_mesh_set_freq(struct net_device *dev,
 			     struct iw_request_info *info,
 			     struct iw_freq *fwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct chan_freq_power *cfp;
 	int ret = -EINVAL;
 
@@ -1014,7 +1014,7 @@ out:
 static int lbs_set_rate(struct net_device *dev, struct iw_request_info *info,
 		  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	u8 new_rate = 0;
 	int ret = -EINVAL;
 	u8 rates[MAX_RATES + 1];
@@ -1062,7 +1062,7 @@ out:
 static int lbs_get_rate(struct net_device *dev, struct iw_request_info *info,
 		  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -1087,7 +1087,7 @@ static int lbs_set_mode(struct net_device *dev,
 		  struct iw_request_info *info, u32 * uwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct assoc_request * assoc_req;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -1132,7 +1132,7 @@ static int lbs_get_encode(struct net_device *dev,
 			   struct iw_request_info *info,
 			   struct iw_point *dwrq, u8 * extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -1327,7 +1327,7 @@ static int lbs_set_encode(struct net_device *dev,
 		    struct iw_point *dwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct assoc_request * assoc_req;
 	u16 is_default = 0, index = 0, set_tx_key = 0;
 
@@ -1403,7 +1403,7 @@ static int lbs_get_encodeext(struct net_device *dev,
 			      char *extra)
 {
 	int ret = -EINVAL;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
 	int index, max_key_len;
 
@@ -1509,7 +1509,7 @@ static int lbs_set_encodeext(struct net_device *dev,
 			      char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
 	int alg = ext->alg;
 	struct assoc_request * assoc_req;
@@ -1633,7 +1633,7 @@ static int lbs_set_genie(struct net_device *dev,
 			  struct iw_point *dwrq,
 			  char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int ret = 0;
 	struct assoc_request * assoc_req;
 
@@ -1679,7 +1679,7 @@ static int lbs_get_genie(struct net_device *dev,
 			  char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -1707,7 +1707,7 @@ static int lbs_set_auth(struct net_device *dev,
 			 struct iw_param *dwrq,
 			 char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct assoc_request * assoc_req;
 	int ret = 0;
 	int updated = 0;
@@ -1806,7 +1806,7 @@ static int lbs_get_auth(struct net_device *dev,
 			 char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -1843,7 +1843,7 @@ static int lbs_set_txpow(struct net_device *dev, struct iw_request_info *info,
 		   struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	u16 dbm;
 
@@ -1884,7 +1884,7 @@ static int lbs_set_txpow(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_essid(struct net_device *dev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -1919,7 +1919,7 @@ static int lbs_get_essid(struct net_device *dev, struct iw_request_info *info,
 static int lbs_set_essid(struct net_device *dev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int ret = 0;
 	u8 ssid[IW_ESSID_MAX_SIZE];
 	u8 ssid_len = 0;
@@ -1982,7 +1982,7 @@ static int lbs_mesh_get_essid(struct net_device *dev,
 			      struct iw_request_info *info,
 			      struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -2000,7 +2000,7 @@ static int lbs_mesh_set_essid(struct net_device *dev,
 			      struct iw_request_info *info,
 			      struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int ret = 0;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -2039,7 +2039,7 @@ static int lbs_mesh_set_essid(struct net_device *dev,
 static int lbs_set_wap(struct net_device *dev, struct iw_request_info *info,
 		 struct sockaddr *awrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct assoc_request * assoc_req;
 	int ret = 0;
 	DECLARE_MAC_BUF(mac);
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 00e965b..9d7630c 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1104,7 +1104,7 @@ static int rndis_iw_get_range(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
 	struct iw_range *range = (struct iw_range *)extra;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	int len, ret, i, j, num, has_80211g_rates;
 	u8 rates[8];
@@ -1210,7 +1210,7 @@ static int rndis_iw_get_range(struct net_device *dev,
 static int rndis_iw_get_name(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	strcpy(wrqu->name, priv->name);
@@ -1223,7 +1223,7 @@ static int rndis_iw_set_essid(struct net_device *dev,
 {
 	struct ndis_80211_ssid ssid;
 	int length = wrqu->essid.length;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 
 	devdbg(usbdev, "SIOCSIWESSID: [flags:%d,len:%d] '%.32s'",
 		wrqu->essid.flags, wrqu->essid.length, essid);
@@ -1250,7 +1250,7 @@ static int rndis_iw_get_essid(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *essid)
 {
 	struct ndis_80211_ssid ssid;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	int ret;
 
 	ret = get_essid(usbdev, &ssid);
@@ -1273,7 +1273,7 @@ static int rndis_iw_get_essid(struct net_device *dev,
 static int rndis_iw_get_bssid(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	unsigned char bssid[ETH_ALEN];
 	int ret;
 	DECLARE_MAC_BUF(mac);
@@ -1295,7 +1295,7 @@ static int rndis_iw_get_bssid(struct net_device *dev,
 static int rndis_iw_set_bssid(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	u8 *bssid = (u8 *)wrqu->ap_addr.sa_data;
 	DECLARE_MAC_BUF(mac);
 	int ret;
@@ -1318,7 +1318,7 @@ static int rndis_iw_set_auth(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
 	struct iw_param *p = &wrqu->param;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	int ret = -ENOTSUPP;
 
@@ -1399,7 +1399,7 @@ static int rndis_iw_get_auth(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
 	struct iw_param *p = &wrqu->param;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	switch (p->flags & IW_AUTH_INDEX) {
@@ -1431,7 +1431,7 @@ static int rndis_iw_get_mode(struct net_device *dev,
 				struct iw_request_info *info,
 				union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	switch (priv->infra_mode) {
@@ -1454,7 +1454,7 @@ static int rndis_iw_get_mode(struct net_device *dev,
 static int rndis_iw_set_mode(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	int mode;
 
 	devdbg(usbdev, "SIOCSIWMODE: %08x", wrqu->mode);
@@ -1479,7 +1479,7 @@ static int rndis_iw_set_mode(struct net_device *dev,
 static int rndis_iw_set_encode(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	int ret, index, key_len;
 	u8 *key;
@@ -1542,7 +1542,7 @@ static int rndis_iw_set_encode_ext(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	struct ndis_80211_key ndis_key;
 	int keyidx, ret;
@@ -1628,7 +1628,7 @@ static int rndis_iw_set_scan(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
 	struct iw_param *param = &wrqu->param;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	union iwreq_data evt;
 	int ret = -EINVAL;
 	__le32 tmp;
@@ -1653,7 +1653,7 @@ static char *rndis_translate_scan(struct net_device *dev,
 				  struct ndis_80211_bssid_ex *bssid)
 {
 #ifdef DEBUG
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 #endif
 	struct ieee80211_info_element *ie;
 	char *current_val;
@@ -1777,7 +1777,7 @@ static char *rndis_translate_scan(struct net_device *dev,
 static int rndis_iw_get_scan(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	void *buf = NULL;
 	char *cev = extra;
 	struct ndis_80211_bssid_list_ex *bssid_list;
@@ -1823,7 +1823,7 @@ out:
 static int rndis_iw_set_genie(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	int ret = 0;
 
@@ -1857,7 +1857,7 @@ static int rndis_iw_set_genie(struct net_device *dev,
 static int rndis_iw_get_genie(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	devdbg(usbdev, "SIOCGIWGENIE");
@@ -1880,7 +1880,7 @@ static int rndis_iw_get_genie(struct net_device *dev,
 static int rndis_iw_set_rts(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	__le32 tmp;
 	devdbg(usbdev, "SIOCSIWRTS");
 
@@ -1893,7 +1893,7 @@ static int rndis_iw_set_rts(struct net_device *dev,
 static int rndis_iw_get_rts(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	__le32 tmp;
 	int len, ret;
 
@@ -1914,7 +1914,7 @@ static int rndis_iw_get_rts(struct net_device *dev,
 static int rndis_iw_set_frag(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	__le32 tmp;
 
 	devdbg(usbdev, "SIOCSIWFRAG");
@@ -1928,7 +1928,7 @@ static int rndis_iw_set_frag(struct net_device *dev,
 static int rndis_iw_get_frag(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	__le32 tmp;
 	int len, ret;
 
@@ -1948,7 +1948,7 @@ static int rndis_iw_get_frag(struct net_device *dev,
 static int rndis_iw_set_nick(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	devdbg(usbdev, "SIOCSIWNICK");
@@ -1965,7 +1965,7 @@ static int rndis_iw_set_nick(struct net_device *dev,
 static int rndis_iw_get_nick(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	wrqu->data.flags = 1;
@@ -1981,7 +1981,7 @@ static int rndis_iw_get_nick(struct net_device *dev,
 static int rndis_iw_set_freq(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct ndis_80211_conf config;
 	unsigned int dsconfig;
 	int len, ret;
@@ -2012,7 +2012,7 @@ static int rndis_iw_set_freq(struct net_device *dev,
 static int rndis_iw_get_freq(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct ndis_80211_conf config;
 	int len, ret;
 
@@ -2029,7 +2029,7 @@ static int rndis_iw_get_freq(struct net_device *dev,
 static int rndis_iw_get_txpower(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	__le32 tx_power;
 	int ret = 0, len;
@@ -2063,7 +2063,7 @@ static int rndis_iw_get_txpower(struct net_device *dev,
 static int rndis_iw_set_txpower(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	__le32 tx_power = 0;
 	int ret = 0;
@@ -2115,7 +2115,7 @@ static int rndis_iw_set_txpower(struct net_device *dev,
 static int rndis_iw_get_rate(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	__le32 tmp;
 	int ret, len;
 
@@ -2133,7 +2133,7 @@ static int rndis_iw_get_rate(struct net_device *dev,
 static int rndis_iw_set_mlme(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	struct iw_mlme *mlme = (struct iw_mlme *)extra;
 	unsigned char bssid[ETH_ALEN];
@@ -2158,7 +2158,7 @@ static int rndis_iw_set_mlme(struct net_device *dev,
 
 static struct iw_statistics *rndis_get_wireless_stats(struct net_device *dev)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	unsigned long flags;
 
@@ -2288,7 +2288,7 @@ get_bssid:
 
 static void rndis_wext_set_multicast_list(struct net_device *dev)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	if (test_bit(WORK_SET_MULTICAST_LIST, &priv->work_pending))
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index 136220b..6a89852 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -134,7 +134,7 @@ static inline void wv_16_on(unsigned long ioaddr, u16 hacr)
  */
 static inline void wv_ints_off(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	
 	lp->hacr &= ~HACR_INTRON;
@@ -148,7 +148,7 @@ static inline void wv_ints_off(struct net_device * dev)
  */
 static inline void wv_ints_on(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 
 	lp->hacr |= HACR_INTRON;
@@ -526,7 +526,7 @@ static inline void obram_write(unsigned long ioaddr, u16 o, u8 * b, int n)
  */
 static void wv_ack(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 scb_cs;
 	int i;
@@ -568,7 +568,7 @@ static void wv_ack(struct net_device * dev)
  */
 static int wv_synchronous_cmd(struct net_device * dev, const char *str)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 scb_cmd;
 	ach_t cb;
@@ -824,7 +824,7 @@ if (lp->tx_n_in_use > 0)
  */
 static void wv_82586_reconfig(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	/* Arm the flag, will be cleard in wv_82586_config() */
@@ -927,7 +927,7 @@ static void wv_psa_show(psa_t * p)
 static void wv_mmc_show(struct net_device * dev)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	mmr_t m;
 
 	/* Basic check */
@@ -1107,8 +1107,6 @@ static void wv_scb_show(unsigned long ioaddr)
  */
 static void wv_ru_show(struct net_device * dev)
 {
-	/* net_local *lp = (net_local *) dev->priv; */
-
 	printk(KERN_DEBUG
 	       "##### WaveLAN i82586 receiver unit status: #####\n");
 	printk(KERN_DEBUG "ru:");
@@ -1153,7 +1151,7 @@ static void wv_cu_show_one(struct net_device * dev, net_local * lp, int i, u16 p
  */
 static void wv_cu_show(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned int i;
 	u16 p;
 
@@ -1195,7 +1193,7 @@ static void wv_local_show(struct net_device * dev)
 {
 	net_local *lp;
 
-	lp = (net_local *) dev->priv;
+	lp = netdev_priv(dev);
 
 	printk(KERN_DEBUG "local:");
 	printk(" tx_n_in_use=%d,", lp->tx_n_in_use);
@@ -1256,7 +1254,7 @@ static inline void wv_packet_info(u8 * p,	/* Packet to dump */
 static void wv_init_info(struct net_device * dev)
 {
 	short ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	psa_t psa;
 #ifdef DEBUG_BASIC_SHOW
 	DECLARE_MAC_BUF(mac);
@@ -1369,7 +1367,7 @@ static en_stats *wavelan_get_stats(struct net_device * dev)
 	printk(KERN_DEBUG "%s: <>wavelan_get_stats()\n", dev->name);
 #endif
 
-	return (&((net_local *) dev->priv)->stats);
+	return &((net_local *)netdev_priv(dev))->stats;
 }
 
 /*------------------------------------------------------------------*/
@@ -1382,7 +1380,7 @@ static en_stats *wavelan_get_stats(struct net_device * dev)
  */
 static void wavelan_set_multicast_list(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 
 #ifdef DEBUG_IOCTL_TRACE
 	printk(KERN_DEBUG "%s: ->wavelan_set_multicast_list()\n",
@@ -1716,7 +1714,7 @@ static inline void wl_spy_gather(struct net_device * dev,
  */
 static inline void wl_his_gather(struct net_device * dev, u8 * stats)
 {				/* Statistics to gather */
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	u8 level = stats[0] & MMR_SIGNAL_LVL;
 	int i;
 
@@ -1753,7 +1751,7 @@ static int wavelan_set_nwid(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	mm_t m;
 	unsigned long flags;
@@ -1812,7 +1810,7 @@ static int wavelan_get_nwid(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 	int ret = 0;
@@ -1844,7 +1842,7 @@ static int wavelan_set_freq(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	unsigned long flags;
 	int ret;
 
@@ -1874,7 +1872,7 @@ static int wavelan_get_freq(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 	int ret = 0;
@@ -1920,7 +1918,7 @@ static int wavelan_set_sens(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 	int ret = 0;
@@ -1956,7 +1954,7 @@ static int wavelan_get_sens(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 	int ret = 0;
@@ -1987,7 +1985,7 @@ static int wavelan_set_encode(struct net_device *dev,
 			      char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	unsigned long flags;
 	psa_t psa;
 	int ret = 0;
@@ -2057,7 +2055,7 @@ static int wavelan_get_encode(struct net_device *dev,
 			      char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 	int ret = 0;
@@ -2104,7 +2102,7 @@ static int wavelan_get_range(struct net_device *dev,
 			     char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	struct iw_range *range = (struct iw_range *) extra;
 	unsigned long flags;
 	int ret = 0;
@@ -2179,7 +2177,7 @@ static int wavelan_set_qthr(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 
@@ -2211,7 +2209,7 @@ static int wavelan_get_qthr(struct net_device *dev,
 			    char *extra)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 	psa_t psa;
 	unsigned long flags;
 
@@ -2239,7 +2237,7 @@ static int wavelan_set_histo(struct net_device *dev,
 			     union iwreq_data *wrqu,
 			     char *extra)
 {
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 
 	/* Check the number of intervals. */
 	if (wrqu->data.length > 16) {
@@ -2282,7 +2280,7 @@ static int wavelan_get_histo(struct net_device *dev,
 			     union iwreq_data *wrqu,
 			     char *extra)
 {
-	net_local *lp = (net_local *) dev->priv;	/* lp is not unused */
+	net_local *lp = netdev_priv(dev);	/* lp is not unused */
 
 	/* Set the number of intervals. */
 	wrqu->data.length = lp->his_number;
@@ -2386,7 +2384,7 @@ static const struct iw_handler_def	wavelan_handler_def =
 static iw_stats *wavelan_get_wireless_stats(struct net_device * dev)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	mmr_t m;
 	iw_stats *wstats;
 	unsigned long flags;
@@ -2461,7 +2459,7 @@ static iw_stats *wavelan_get_wireless_stats(struct net_device * dev)
 static void
 wv_packet_read(struct net_device * dev, u16 buf_off, int sksize)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	struct sk_buff *skb;
 
@@ -2556,7 +2554,7 @@ wv_packet_read(struct net_device * dev, u16 buf_off, int sksize)
 static void wv_receive(struct net_device * dev)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	fd_t fd;
 	rbd_t rbd;
 	int nreaped = 0;
@@ -2738,7 +2736,7 @@ static void wv_receive(struct net_device * dev)
  */
 static int wv_packet_write(struct net_device * dev, void *buf, short length)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned short txblock;
 	unsigned short txpred;
@@ -2869,7 +2867,7 @@ static int wv_packet_write(struct net_device * dev, void *buf, short length)
  */
 static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 	char data[ETH_ZLEN];
 
@@ -2937,7 +2935,7 @@ static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device * dev)
 static int wv_mmc_init(struct net_device * dev)
 {
 	unsigned long ioaddr = dev->base_addr;
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	psa_t psa;
 	mmw_t m;
 	int configured;
@@ -3108,7 +3106,7 @@ static int wv_mmc_init(struct net_device * dev)
  */
 static int wv_ru_start(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 scb_cs;
 	fd_t fd;
@@ -3200,7 +3198,7 @@ static int wv_ru_start(struct net_device * dev)
  */
 static int wv_cu_start(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	int i;
 	u16 txblock;
@@ -3301,7 +3299,7 @@ static int wv_cu_start(struct net_device * dev)
  */
 static int wv_82586_start(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	scp_t scp;		/* system configuration pointer */
 	iscp_t iscp;		/* intermediate scp */
@@ -3433,7 +3431,7 @@ static int wv_82586_start(struct net_device * dev)
  */
 static void wv_82586_config(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned short txblock;
 	unsigned short txpred;
@@ -3613,7 +3611,7 @@ static void wv_82586_config(struct net_device * dev)
  */
 static void wv_82586_stop(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 scb_cmd;
 
@@ -3650,7 +3648,7 @@ static void wv_82586_stop(struct net_device * dev)
  */
 static int wv_hw_reset(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 
 #ifdef DEBUG_CONFIG_TRACE
@@ -3751,7 +3749,7 @@ static irqreturn_t wavelan_interrupt(int irq, void *dev_id)
 	printk(KERN_DEBUG "%s: ->wavelan_interrupt()\n", dev->name);
 #endif
 
-	lp = (net_local *) dev->priv;
+	lp = netdev_priv(dev);
 	ioaddr = dev->base_addr;
 
 #ifdef DEBUG_INTERRUPT_INFO
@@ -3894,7 +3892,7 @@ static irqreturn_t wavelan_interrupt(int irq, void *dev_id)
  */
 static void wavelan_watchdog(struct net_device *	dev)
 {
-	net_local *	lp = (net_local *)dev->priv;
+	net_local *lp = netdev_priv(dev);
 	u_long		ioaddr = dev->base_addr;
 	unsigned long	flags;
 	unsigned int	nreaped;
@@ -3974,7 +3972,7 @@ static void wavelan_watchdog(struct net_device *	dev)
  */
 static int wavelan_open(struct net_device * dev)
 {
-	net_local *	lp = (net_local *)dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long	flags;
 
 #ifdef DEBUG_CALLBACK_TRACE
@@ -4029,7 +4027,7 @@ static int wavelan_open(struct net_device * dev)
  */
 static int wavelan_close(struct net_device * dev)
 {
-	net_local *lp = (net_local *) dev->priv;
+	net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 #ifdef DEBUG_CALLBACK_TRACE
@@ -4128,8 +4126,8 @@ static int __init wavelan_config(struct net_device *dev, unsigned short ioaddr)
 	dev->if_port = 0;
 
 	/* Initialize device structures */
-	memset(dev->priv, 0, sizeof(net_local));
-	lp = (net_local *) dev->priv;
+	memset(netdev_priv(dev), 0, sizeof(net_local));
+	lp = netdev_priv(dev);
 
 	/* Back link to the device structure. */
 	lp->dev = dev;
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index a86c022..b3cd541 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -167,7 +167,7 @@ static void znet_tx_timeout (struct net_device *dev);
 /* Request needed resources */
 static int znet_request_resources (struct net_device *dev)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned long flags;
 
 	if (request_irq (dev->irq, &znet_interrupt, 0, "ZNet", dev))
@@ -201,7 +201,7 @@ static int znet_request_resources (struct net_device *dev)
 
 static void znet_release_resources (struct net_device *dev)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned long flags;
 
 	release_region (znet->sia_base, znet->sia_size);
@@ -216,7 +216,7 @@ static void znet_release_resources (struct net_device *dev)
 /* Keep the magical SIA stuff in a single function... */
 static void znet_transceiver_power (struct net_device *dev, int on)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned char v;
 
 	/* Turn on/off the 82501 SIA, using zenith-specific magic. */
@@ -235,7 +235,7 @@ static void znet_transceiver_power (struct net_device *dev, int on)
    Also used from hardware_init. */
 static void znet_set_multicast_list (struct net_device *dev)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 	struct i82593_conf_block *cfblk = &znet->i593_init;
 
@@ -387,7 +387,7 @@ static int __init znet_probe (void)
 	if (!dev)
 		return -ENOMEM;
 
-	znet = dev->priv;
+	znet = netdev_priv(dev);
 
 	netinfo = (struct netidblk *)p;
 	dev->base_addr = netinfo->iobase1;
@@ -531,7 +531,7 @@ static void znet_tx_timeout (struct net_device *dev)
 static int znet_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned long flags;
 	short length = skb->len;
 
@@ -601,7 +601,7 @@ static int znet_send_packet(struct sk_buff *skb, struct net_device *dev)
 static irqreturn_t znet_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	int ioaddr;
 	int boguscnt = 20;
 	int handled = 0;
@@ -679,7 +679,7 @@ static irqreturn_t znet_interrupt(int irq, void *dev_id)
 
 static void znet_rx(struct net_device *dev)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int boguscount = 1;
 	short next_frame_end_offset = 0; 		/* Offset of next frame start. */
@@ -829,7 +829,7 @@ static void show_dma(struct net_device *dev)
 {
 	short ioaddr = dev->base_addr;
 	unsigned char stat = inb (ioaddr);
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned long flags;
 	short dma_port = ((znet->tx_dma&3)<<2) + IO_DMA2_BASE;
 	unsigned addr = inb(dma_port);
@@ -852,7 +852,7 @@ static void hardware_init(struct net_device *dev)
 {
 	unsigned long flags;
 	short ioaddr = dev->base_addr;
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 
 	znet->rx_cur = znet->rx_start;
 	znet->tx_cur = znet->tx_start;
@@ -914,7 +914,7 @@ static void update_stop_hit(short ioaddr, unsigned short rx_stop_offset)
 static __exit void znet_cleanup (void)
 {
 	if (znet_dev) {
-		struct znet_private *znet = znet_dev->priv;
+		struct znet_private *znet = netdev_priv(znet_dev);
 
 		unregister_netdev (znet_dev);
 		kfree (znet->rx_start);
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 0c85042..287a3df 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1284,7 +1284,7 @@ static int handle_ip_over_ddp(struct sk_buff *skb)
 	skb->dev   = dev;
 	skb_reset_transport_header(skb);
 
-	stats = dev->priv;
+	stats = netdev_priv(dev);
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len + 13;
 	netif_rx(skb);  /* Send the SKB up to a higher place. */
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 8d9a6f1..bdb1013 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -101,7 +101,7 @@ static LIST_HEAD(br2684_devs);
 
 static inline struct br2684_dev *BRPRIV(const struct net_device *net_dev)
 {
-	return (struct br2684_dev *)net_dev->priv;
+	return (struct br2684_dev *)netdev_priv(net_dev);
 }
 
 static inline struct net_device *list_entry_brdev(const struct list_head *le)
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 5799fb5..1053471 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -152,7 +152,7 @@ static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 		buff += 4;
 		mesg->content.normal.flag = *buff & 0x01;	/* 0x01 is topology change */
 
-		priv = (struct lec_priv *)dev->priv;
+		priv = netdev_priv(dev);
 		atm_force_charge(priv->lecd, skb2->truesize);
 		sk = sk_atm(priv->lecd);
 		skb_queue_tail(&sk->sk_receive_queue, skb2);
@@ -218,7 +218,7 @@ static unsigned char *get_tr_dst(unsigned char *packet, unsigned char *rdesc)
 
 static int lec_open(struct net_device *dev)
 {
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 
 	netif_start_queue(dev);
 	memset(&priv->stats, 0, sizeof(struct net_device_stats));
@@ -252,7 +252,7 @@ static void lec_tx_timeout(struct net_device *dev)
 static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sk_buff *skb2;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 	struct lecdatahdr_8023 *lec_h;
 	struct atm_vcc *vcc;
 	struct lec_arp_table *entry;
@@ -442,14 +442,14 @@ static int lec_close(struct net_device *dev)
  */
 static struct net_device_stats *lec_get_stats(struct net_device *dev)
 {
-	return &((struct lec_priv *)dev->priv)->stats;
+	return &((struct lec_priv *)netdev_priv(dev))->stats;
 }
 
 static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	unsigned long flags;
 	struct net_device *dev = (struct net_device *)vcc->proto_data;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 	struct atmlec_msg *mesg;
 	struct lec_arp_table *entry;
 	int i;
@@ -596,7 +596,7 @@ static void lec_atm_close(struct atm_vcc *vcc)
 {
 	struct sk_buff *skb;
 	struct net_device *dev = (struct net_device *)vcc->proto_data;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 
 	priv->lecd = NULL;
 	/* Do something needful? */
@@ -727,7 +727,7 @@ static void lec_push(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	unsigned long flags;
 	struct net_device *dev = (struct net_device *)vcc->proto_data;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 
 #if DUMP_PACKETS >0
 	int i = 0;
@@ -874,7 +874,7 @@ static int lec_vcc_attach(struct atm_vcc *vcc, void __user *arg)
 	vpriv->old_pop = vcc->pop;
 	vcc->user_back = vpriv;
 	vcc->pop = lec_pop;
-	lec_vcc_added(dev_lec[ioc_data.dev_num]->priv,
+	lec_vcc_added(netdev_priv(dev_lec[ioc_data.dev_num]),
 		      &ioc_data, vcc, vcc->push);
 	vcc->proto_data = dev_lec[ioc_data.dev_num];
 	vcc->push = lec_push;
@@ -886,7 +886,8 @@ static int lec_mcast_attach(struct atm_vcc *vcc, int arg)
 	if (arg < 0 || arg >= MAX_LEC_ITF || !dev_lec[arg])
 		return -EINVAL;
 	vcc->proto_data = dev_lec[arg];
-	return (lec_mcast_make((struct lec_priv *)dev_lec[arg]->priv, vcc));
+	return lec_mcast_make((struct lec_priv *)netdev_priv(dev_lec[arg]),
+				vcc);
 }
 
 /* Initialize device. */
@@ -928,11 +929,11 @@ static int lecd_attach(struct atm_vcc *vcc, int arg)
 			return -EINVAL;
 		}
 
-		priv = dev_lec[i]->priv;
+		priv = netdev_priv(dev_lec[i]);
 		priv->is_trdev = is_trdev;
 		lec_init(dev_lec[i]);
 	} else {
-		priv = dev_lec[i]->priv;
+		priv = netdev_priv(dev_lec[i]);
 		if (priv->lecd)
 			return -EADDRINUSE;
 	}
@@ -1093,7 +1094,8 @@ static void *lec_itf_walk(struct lec_state *state, loff_t *l)
 	void *v;
 
 	dev = state->dev ? state->dev : dev_lec[state->itf];
-	v = (dev && dev->priv) ? lec_priv_walk(state, l, dev->priv) : NULL;
+	v = (dev && netdev_priv(dev)) ?
+		lec_priv_walk(state, l, netdev_priv(dev)) : NULL;
 	if (!v && dev) {
 		dev_put(dev);
 		/* Partial state reset for the next time we get called */
@@ -1255,7 +1257,7 @@ static void __exit lane_module_cleanup(void)
 
 	for (i = 0; i < MAX_LEC_ITF; i++) {
 		if (dev_lec[i] != NULL) {
-			priv = (struct lec_priv *)dev_lec[i]->priv;
+			priv = netdev_priv(dev_lec[i]);
 			unregister_netdev(dev_lec[i]);
 			free_netdev(dev_lec[i]);
 			dev_lec[i] = NULL;
@@ -1279,7 +1281,7 @@ static int lane2_resolve(struct net_device *dev, const u8 *dst_mac, int force,
 			 u8 **tlvs, u32 *sizeoftlvs)
 {
 	unsigned long flags;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 	struct lec_arp_table *table;
 	struct sk_buff *skb;
 	int retval;
@@ -1326,7 +1328,7 @@ static int lane2_associate_req(struct net_device *dev, const u8 *lan_dst,
 {
 	int retval;
 	struct sk_buff *skb;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 
 	if (compare_ether_addr(lan_dst, dev->dev_addr))
 		return (0);	/* not our mac address */
@@ -1363,7 +1365,7 @@ static void lane2_associate_ind(struct net_device *dev, const u8 *mac_addr,
 #if 0
 	int i = 0;
 #endif
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 #if 0				/*
 				 * Why have the TLVs in LE_ARP entries
 				 * since we do not use them? When you
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 11b16d1..236f416 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -785,7 +785,7 @@ static int atm_mpoa_mpoad_attach (struct atm_vcc *vcc, int arg)
 	}
 
 	if (mpc->dev) { /* check if the lec is LANE2 capable */
-		priv = (struct lec_priv *)mpc->dev->priv;
+		priv = netdev_priv(mpc->dev);
 		if (priv->lane_version < 2) {
 			dev_put(mpc->dev);
 			mpc->dev = NULL;
@@ -845,7 +845,7 @@ static void mpoad_close(struct atm_vcc *vcc)
 
 	mpc->mpoad_vcc = NULL;
 	if (mpc->dev) {
-		struct lec_priv *priv = (struct lec_priv *)mpc->dev->priv;
+		struct lec_priv *priv = netdev_priv(mpc->dev);
 		priv->lane2_ops->associate_indicator = NULL;
 		stop_mpc(mpc);
 		dev_put(mpc->dev);
@@ -976,7 +976,7 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier, unsigned lo
 
 	switch (event) {
 	case NETDEV_REGISTER:       /* a new lec device was allocated */
-		priv = (struct lec_priv *)dev->priv;
+		priv = netdev_priv(dev);
 		if (priv->lane_version < 2)
 			break;
 		priv->lane2_ops->associate_indicator = lane2_assoc_ind;
@@ -1322,7 +1322,7 @@ static void set_mpc_ctrl_addr_rcvd(struct k_message *mesg, struct mpoa_client *m
 	dprintk("\n");
 
 	if (mpc->dev) {
-		priv = (struct lec_priv *)mpc->dev->priv;
+		priv = netdev_priv(mpc->dev);
 		retval = priv->lane2_ops->associate_req(mpc->dev, mpc->dev->dev_addr, tlv, sizeof(tlv));
 		if (retval == 0)
 			printk("mpoa: (%s) MPOA device type TLV association failed\n", mpc->dev->name);
@@ -1472,7 +1472,7 @@ static void __exit atm_mpoa_cleanup(void)
 		tmp = mpc->next;
 		if (mpc->dev != NULL) {
 			stop_mpc(mpc);
-			priv = (struct lec_priv *)mpc->dev->priv;
+			priv = netdev_priv(mpc->dev);
 			if (priv->lane2_ops != NULL)
 				priv->lane2_ops->associate_indicator = NULL;
 		}
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index 80ba30c..9c617f3 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -566,7 +566,7 @@ int bnep_add_connection(struct bnep_connadd_req *req, struct socket *sock)
 		goto failed;
 	}
 
-	s = dev->priv;
+	s = netdev_priv(dev);
 
 	/* This is rx header therefore addresses are swapped.
 	 * ie eh.h_dest is our local address. */
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index d9fa0ab..47e179f 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -62,14 +62,14 @@ static int bnep_net_close(struct net_device *dev)
 
 static struct net_device_stats *bnep_net_get_stats(struct net_device *dev)
 {
-	struct bnep_session *s = dev->priv;
+	struct bnep_session *s = netdev_priv(dev);
 	return &s->stats;
 }
 
 static void bnep_net_set_mc_list(struct net_device *dev)
 {
 #ifdef CONFIG_BT_BNEP_MC_FILTER
-	struct bnep_session *s = dev->priv;
+	struct bnep_session *s = netdev_priv(dev);
 	struct sock *sk = s->sock->sk;
 	struct bnep_set_filter_req *r;
 	struct sk_buff *skb;
@@ -183,7 +183,7 @@ static inline int bnep_net_proto_filter(struct sk_buff *skb, struct bnep_session
 
 static int bnep_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct bnep_session *s = dev->priv;
+	struct bnep_session *s = netdev_priv(dev);
 	struct sock *sk = s->sock->sk;
 
 	BT_DBG("skb %p, dev %p", skb, dev);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 63c18aa..bd1bc78 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -453,7 +453,7 @@ void __exit br_cleanup_bridges(void)
 restart:
 	for_each_netdev(&init_net, dev) {
 		if (dev->priv_flags & IFF_EBRIDGE) {
-			del_br(dev->priv);
+			del_br(netdev_priv(dev));
 			goto restart;
 		}
 	}
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 27d6a51..3d6d0d4 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -22,7 +22,7 @@
 #include "br_private.h"
 
 #define to_dev(obj)	container_of(obj, struct device, kobj)
-#define to_bridge(cd)	((struct net_bridge *)(to_net_dev(cd)->priv))
+#define to_bridge(cd)	((struct net_bridge *)netdev_priv(to_net_dev(cd)))
 
 /*
  * Common code for storing bridge parameters.
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index 9a1cd87..774d73a 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -207,7 +207,7 @@ static struct irlan_cb *irlan_open(__u32 saddr, __u32 daddr)
 	if (!dev)
 		return NULL;
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 	self->dev = dev;
 
 	/*
-- 
1.5.3.4


