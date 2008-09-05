From: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 16/18] netdevice zd1201: Convert directly reference of netdev->priv
 to netdev->ml_priv
Date: Fri, 05 Sep 2008 11:29:36 +0800
Message-ID: <48C0A7A0.9030200@cn.fujitsu.com>
References: <48C0A219.2030004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, NETDEV <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48C0A219.2030004-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We have some reasons to kill netdev->priv:
1. netdev->priv is equal to netdev_priv().
2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
   netdev_priv() is more flexible than netdev->priv.
But we cann't kill netdev->priv, because so many drivers reference to it
directly.

OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
and I want to kill netdev->priv later, I decided to convert all the direct
reference of netdev->priv first.

Different to readonly reference of netdev->priv, in this driver, netdev->priv
was changed. I use netdev->ml_priv to replace netdev->priv.

Signed-off-by: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 drivers/net/wireless/zd1201.c |   64 ++++++++++++++++++++--------------------
 1 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index b16ec6e..abbf327 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -745,7 +745,7 @@ static int zd1201_join(struct zd1201 *zd, char *essid, int essidlen)
 
 static int zd1201_net_open(struct net_device *dev)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 
 	/* Start MAC with wildcard if no essid set */
 	if (!zd->mac_enabled)
@@ -783,7 +783,7 @@ static int zd1201_net_stop(struct net_device *dev)
  */
 static int zd1201_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	unsigned char *txbuf = zd->txdata;
 	int txbuflen, pad = 0, err;
 	struct urb *urb = zd->tx_urb;
@@ -833,7 +833,7 @@ static int zd1201_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static void zd1201_tx_timeout(struct net_device *dev)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 
 	if (!zd)
 		return;
@@ -848,7 +848,7 @@ static void zd1201_tx_timeout(struct net_device *dev)
 static int zd1201_set_mac_address(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	int err;
 
 	if (!zd)
@@ -865,21 +865,21 @@ static int zd1201_set_mac_address(struct net_device *dev, void *p)
 
 static struct net_device_stats *zd1201_get_stats(struct net_device *dev)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 
 	return &zd->stats;
 }
 
 static struct iw_statistics *zd1201_get_wireless_stats(struct net_device *dev)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 
 	return &zd->iwstats;
 }
 
 static void zd1201_set_multicast(struct net_device *dev)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	struct dev_mc_list *mc = dev->mc_list;
 	unsigned char reqbuf[ETH_ALEN*ZD1201_MAXMULTI];
 	int i;
@@ -899,7 +899,7 @@ static void zd1201_set_multicast(struct net_device *dev)
 static int zd1201_config_commit(struct net_device *dev, 
     struct iw_request_info *info, struct iw_point *data, char *essid)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 
 	return zd1201_mac_reset(zd);
 }
@@ -914,7 +914,7 @@ static int zd1201_get_name(struct net_device *dev,
 static int zd1201_set_freq(struct net_device *dev,
     struct iw_request_info *info, struct iw_freq *freq, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short channel = 0;
 	int err;
 
@@ -939,7 +939,7 @@ static int zd1201_set_freq(struct net_device *dev,
 static int zd1201_get_freq(struct net_device *dev,
     struct iw_request_info *info, struct iw_freq *freq, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short channel;
 	int err;
 
@@ -955,7 +955,7 @@ static int zd1201_get_freq(struct net_device *dev,
 static int zd1201_set_mode(struct net_device *dev,
     struct iw_request_info *info, __u32 *mode, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short porttype, monitor = 0;
 	unsigned char buffer[IW_ESSID_MAX_SIZE+2];
 	int err;
@@ -1017,7 +1017,7 @@ static int zd1201_set_mode(struct net_device *dev,
 static int zd1201_get_mode(struct net_device *dev,
     struct iw_request_info *info, __u32 *mode, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short porttype;
 	int err;
 
@@ -1093,7 +1093,7 @@ static int zd1201_get_range(struct net_device *dev,
 static int zd1201_get_wap(struct net_device *dev,
     struct iw_request_info *info, struct sockaddr *ap_addr, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	unsigned char buffer[6];
 
 	if (!zd1201_getconfig(zd, ZD1201_RID_COMMSQUALITY, buffer, 6)) {
@@ -1121,7 +1121,7 @@ static int zd1201_set_scan(struct net_device *dev,
 static int zd1201_get_scan(struct net_device *dev,
     struct iw_request_info *info, struct iw_point *srq, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	int err, i, j, enabled_save;
 	struct iw_event iwe;
 	char *cev = extra;
@@ -1213,7 +1213,7 @@ static int zd1201_get_scan(struct net_device *dev,
 static int zd1201_set_essid(struct net_device *dev,
     struct iw_request_info *info, struct iw_point *data, char *essid)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 
 	if (data->length > IW_ESSID_MAX_SIZE)
 		return -EINVAL;
@@ -1228,7 +1228,7 @@ static int zd1201_set_essid(struct net_device *dev,
 static int zd1201_get_essid(struct net_device *dev,
     struct iw_request_info *info, struct iw_point *data, char *essid)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 
 	memcpy(essid, zd->essid, zd->essidlen);
 	data->flags = 1;
@@ -1249,7 +1249,7 @@ static int zd1201_get_nick(struct net_device *dev, struct iw_request_info *info,
 static int zd1201_set_rate(struct net_device *dev,
     struct iw_request_info *info, struct iw_param *rrq, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short rate;
 	int err;
 
@@ -1282,7 +1282,7 @@ static int zd1201_set_rate(struct net_device *dev,
 static int zd1201_get_rate(struct net_device *dev,
     struct iw_request_info *info, struct iw_param *rrq, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short rate;
 	int err;
 
@@ -1315,7 +1315,7 @@ static int zd1201_get_rate(struct net_device *dev,
 static int zd1201_set_rts(struct net_device *dev, struct iw_request_info *info,
     struct iw_param *rts, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	int err;
 	short val = rts->value;
 
@@ -1335,7 +1335,7 @@ static int zd1201_set_rts(struct net_device *dev, struct iw_request_info *info,
 static int zd1201_get_rts(struct net_device *dev, struct iw_request_info *info,
     struct iw_param *rts, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short rtst;
 	int err;
 
@@ -1352,7 +1352,7 @@ static int zd1201_get_rts(struct net_device *dev, struct iw_request_info *info,
 static int zd1201_set_frag(struct net_device *dev, struct iw_request_info *info,
     struct iw_param *frag, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	int err;
 	short val = frag->value;
 
@@ -1373,7 +1373,7 @@ static int zd1201_set_frag(struct net_device *dev, struct iw_request_info *info,
 static int zd1201_get_frag(struct net_device *dev, struct iw_request_info *info,
     struct iw_param *frag, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short fragt;
 	int err;
 
@@ -1402,7 +1402,7 @@ static int zd1201_get_retry(struct net_device *dev,
 static int zd1201_set_encode(struct net_device *dev,
     struct iw_request_info *info, struct iw_point *erq, char *key)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short i;
 	int err, rid;
 
@@ -1459,7 +1459,7 @@ static int zd1201_set_encode(struct net_device *dev,
 static int zd1201_get_encode(struct net_device *dev,
     struct iw_request_info *info, struct iw_point *erq, char *key)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short i;
 	int err;
 
@@ -1492,7 +1492,7 @@ static int zd1201_get_encode(struct net_device *dev,
 static int zd1201_set_power(struct net_device *dev, 
     struct iw_request_info *info, struct iw_param *vwrq, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short enabled, duration, level;
 	int err;
 
@@ -1531,7 +1531,7 @@ out:
 static int zd1201_get_power(struct net_device *dev,
     struct iw_request_info *info, struct iw_param *vwrq, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short enabled, level, duration;
 	int err;
 
@@ -1618,7 +1618,7 @@ static const iw_handler zd1201_iw_handler[] =
 static int zd1201_set_hostauth(struct net_device *dev,
     struct iw_request_info *info, struct iw_param *rrq, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 
 	if (!zd->ap)
 		return -EOPNOTSUPP;
@@ -1629,7 +1629,7 @@ static int zd1201_set_hostauth(struct net_device *dev,
 static int zd1201_get_hostauth(struct net_device *dev,
     struct iw_request_info *info, struct iw_param *rrq, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short hostauth;
 	int err;
 
@@ -1648,7 +1648,7 @@ static int zd1201_get_hostauth(struct net_device *dev,
 static int zd1201_auth_sta(struct net_device *dev,
     struct iw_request_info *info, struct sockaddr *sta, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	unsigned char buffer[10];
 
 	if (!zd->ap)
@@ -1664,7 +1664,7 @@ static int zd1201_auth_sta(struct net_device *dev,
 static int zd1201_set_maxassoc(struct net_device *dev,
     struct iw_request_info *info, struct iw_param *rrq, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	int err;
 
 	if (!zd->ap)
@@ -1679,7 +1679,7 @@ static int zd1201_set_maxassoc(struct net_device *dev,
 static int zd1201_get_maxassoc(struct net_device *dev,
     struct iw_request_info *info, struct iw_param *rrq, char *extra)
 {
-	struct zd1201 *zd = (struct zd1201 *)dev->priv;
+	struct zd1201 *zd = dev->ml_priv;
 	short maxassoc;
 	int err;
 
@@ -1779,7 +1779,7 @@ static int zd1201_probe(struct usb_interface *interface,
 	if (!zd->dev)
 		goto err_start;
 
-	zd->dev->priv = zd;
+	zd->dev->ml_priv = zd;
 	zd->dev->open = zd1201_net_open;
 	zd->dev->stop = zd1201_net_stop;
 	zd->dev->get_stats = zd1201_get_stats;
-- 
1.5.3.4


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
