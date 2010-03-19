From: Joe Perches <joe@perches.com>
Subject: [PATCH v3 9/9] drivers/net/wireless/ray_cs.c: Use iw_handler function prototypes
Date: Thu, 18 Mar 2010 18:29:40 -0700
Message-ID: <1e9e44cb132ac129f027be72cefcec812f3f8121.1268961559.git.joe@perches.com>
References: <cover.1268961559.git.joe@perches.com>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1268961559.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change local functions that are cast to iw_handler to
the more standard use with "union iwreq_data *wrqu"
so the iw_handler array no longer needs the casts.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ray_cs.c |  204 +++++++++++++++++++----------------------
 1 files changed, 93 insertions(+), 111 deletions(-)

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index a42ee01..4f5bdb5 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -1113,10 +1113,10 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 /*
  * Wireless Handler : get protocol name
  */
-static int ray_get_name(struct net_device *dev,
-			struct iw_request_info *info, char *cwrq, char *extra)
+static int ray_get_name(struct net_device *dev, struct iw_request_info *info,
+			union iwreq_data *wrqu, char *extra)
 {
-	strcpy(cwrq, "IEEE 802.11-FH");
+	strcpy(wrqu->name, "IEEE 802.11-FH");
 	return 0;
 }
 
@@ -1124,9 +1124,8 @@ static int ray_get_name(struct net_device *dev,
 /*
  * Wireless Handler : set frequency
  */
-static int ray_set_freq(struct net_device *dev,
-			struct iw_request_info *info,
-			struct iw_freq *fwrq, char *extra)
+static int ray_set_freq(struct net_device *dev, struct iw_request_info *info,
+			union iwreq_data *wrqu, char *extra)
 {
 	ray_dev_t *local = netdev_priv(dev);
 	int err = -EINPROGRESS;	/* Call commit handler */
@@ -1136,10 +1135,10 @@ static int ray_set_freq(struct net_device *dev,
 		return -EBUSY;
 
 	/* Setting by channel number */
-	if ((fwrq->m > USA_HOP_MOD) || (fwrq->e > 0))
+	if ((wrqu->freq.m > USA_HOP_MOD) || (wrqu->freq.e > 0))
 		err = -EOPNOTSUPP;
 	else
-		local->sparm.b5.a_hop_pattern = fwrq->m;
+		local->sparm.b5.a_hop_pattern = wrqu->freq.m;
 
 	return err;
 }
@@ -1148,14 +1147,13 @@ static int ray_set_freq(struct net_device *dev,
 /*
  * Wireless Handler : get frequency
  */
-static int ray_get_freq(struct net_device *dev,
-			struct iw_request_info *info,
-			struct iw_freq *fwrq, char *extra)
+static int ray_get_freq(struct net_device *dev, struct iw_request_info *info,
+			union iwreq_data *wrqu, char *extra)
 {
 	ray_dev_t *local = netdev_priv(dev);
 
-	fwrq->m = local->sparm.b5.a_hop_pattern;
-	fwrq->e = 0;
+	wrqu->freq.m = local->sparm.b5.a_hop_pattern;
+	wrqu->freq.e = 0;
 	return 0;
 }
 
@@ -1163,9 +1161,8 @@ static int ray_get_freq(struct net_device *dev,
 /*
  * Wireless Handler : set ESSID
  */
-static int ray_set_essid(struct net_device *dev,
-			 struct iw_request_info *info,
-			 struct iw_point *dwrq, char *extra)
+static int ray_set_essid(struct net_device *dev, struct iw_request_info *info,
+			 union iwreq_data *wrqu, char *extra)
 {
 	ray_dev_t *local = netdev_priv(dev);
 
@@ -1174,19 +1171,17 @@ static int ray_set_essid(struct net_device *dev,
 		return -EBUSY;
 
 	/* Check if we asked for `any' */
-	if (dwrq->flags == 0) {
+	if (wrqu->essid.flags == 0)
 		/* Corey : can you do that ? */
 		return -EOPNOTSUPP;
-	} else {
-		/* Check the size of the string */
-		if (dwrq->length > IW_ESSID_MAX_SIZE) {
-			return -E2BIG;
-		}
 
-		/* Set the ESSID in the card */
-		memset(local->sparm.b5.a_current_ess_id, 0, IW_ESSID_MAX_SIZE);
-		memcpy(local->sparm.b5.a_current_ess_id, extra, dwrq->length);
-	}
+	/* Check the size of the string */
+	if (wrqu->essid.length > IW_ESSID_MAX_SIZE)
+		return -E2BIG;
+
+	/* Set the ESSID in the card */
+	memset(local->sparm.b5.a_current_ess_id, 0, IW_ESSID_MAX_SIZE);
+	memcpy(local->sparm.b5.a_current_ess_id, extra, wrqu->essid.length);
 
 	return -EINPROGRESS;	/* Call commit handler */
 }
@@ -1195,9 +1190,8 @@ static int ray_set_essid(struct net_device *dev,
 /*
  * Wireless Handler : get ESSID
  */
-static int ray_get_essid(struct net_device *dev,
-			 struct iw_request_info *info,
-			 struct iw_point *dwrq, char *extra)
+static int ray_get_essid(struct net_device *dev, struct iw_request_info *info,
+			 union iwreq_data *wrqu, char *extra)
 {
 	ray_dev_t *local = netdev_priv(dev);
 
@@ -1205,8 +1199,8 @@ static int ray_get_essid(struct net_device *dev,
 	memcpy(extra, local->sparm.b5.a_current_ess_id, IW_ESSID_MAX_SIZE);
 
 	/* Push it out ! */
-	dwrq->length = strlen(extra);
-	dwrq->flags = 1;	/* active */
+	wrqu->essid.length = strlen(extra);
+	wrqu->essid.flags = 1;	/* active */
 
 	return 0;
 }
@@ -1215,14 +1209,13 @@ static int ray_get_essid(struct net_device *dev,
 /*
  * Wireless Handler : get AP address
  */
-static int ray_get_wap(struct net_device *dev,
-		       struct iw_request_info *info,
-		       struct sockaddr *awrq, char *extra)
+static int ray_get_wap(struct net_device *dev, struct iw_request_info *info,
+		       union iwreq_data *wrqu, char *extra)
 {
 	ray_dev_t *local = netdev_priv(dev);
 
-	memcpy(awrq->sa_data, local->bss_id, ETH_ALEN);
-	awrq->sa_family = ARPHRD_ETHER;
+	memcpy(wrqu->ap_addr.sa_data, local->bss_id, ETH_ALEN);
+	wrqu->ap_addr.sa_family = ARPHRD_ETHER;
 
 	return 0;
 }
@@ -1231,9 +1224,8 @@ static int ray_get_wap(struct net_device *dev,
 /*
  * Wireless Handler : set Bit-Rate
  */
-static int ray_set_rate(struct net_device *dev,
-			struct iw_request_info *info,
-			struct iw_param *vwrq, char *extra)
+static int ray_set_rate(struct net_device *dev, struct iw_request_info *info,
+			union iwreq_data *wrqu, char *extra)
 {
 	ray_dev_t *local = netdev_priv(dev);
 
@@ -1242,15 +1234,15 @@ static int ray_set_rate(struct net_device *dev,
 		return -EBUSY;
 
 	/* Check if rate is in range */
-	if ((vwrq->value != 1000000) && (vwrq->value != 2000000))
+	if ((wrqu->bitrate.value != 1000000) && (wrqu->bitrate.value != 2000000))
 		return -EINVAL;
 
 	/* Hack for 1.5 Mb/s instead of 2 Mb/s */
 	if ((local->fw_ver == 0x55) &&	/* Please check */
-	    (vwrq->value == 2000000))
+	    (wrqu->bitrate.value == 2000000))
 		local->net_default_tx_rate = 3;
 	else
-		local->net_default_tx_rate = vwrq->value / 500000;
+		local->net_default_tx_rate = wrqu->bitrate.value / 500000;
 
 	return 0;
 }
@@ -1259,17 +1251,16 @@ static int ray_set_rate(struct net_device *dev,
 /*
  * Wireless Handler : get Bit-Rate
  */
-static int ray_get_rate(struct net_device *dev,
-			struct iw_request_info *info,
-			struct iw_param *vwrq, char *extra)
+static int ray_get_rate(struct net_device *dev, struct iw_request_info *info,
+			union iwreq_data *wrqu, char *extra)
 {
 	ray_dev_t *local = netdev_priv(dev);
 
 	if (local->net_default_tx_rate == 3)
-		vwrq->value = 2000000;	/* Hum... */
+		wrqu->bitrate.value = 2000000;	/* Hum... */
 	else
-		vwrq->value = local->net_default_tx_rate * 500000;
-	vwrq->fixed = 0;	/* We are in auto mode */
+		wrqu->bitrate.value = local->net_default_tx_rate * 500000;
+	wrqu->bitrate.fixed = 0;	/* We are in auto mode */
 
 	return 0;
 }
@@ -1278,19 +1269,18 @@ static int ray_get_rate(struct net_device *dev,
 /*
  * Wireless Handler : set RTS threshold
  */
-static int ray_set_rts(struct net_device *dev,
-		       struct iw_request_info *info,
-		       struct iw_param *vwrq, char *extra)
+static int ray_set_rts(struct net_device *dev, struct iw_request_info *info,
+		       union iwreq_data *wrqu, char *extra)
 {
 	ray_dev_t *local = netdev_priv(dev);
-	int rthr = vwrq->value;
+	int rthr = wrqu->rts.value;
 
 	/* Reject if card is already initialised */
 	if (local->card_status != CARD_AWAITING_PARAM)
 		return -EBUSY;
 
 	/* if(wrq->u.rts.fixed == 0) we should complain */
-	if (vwrq->disabled)
+	if (wrqu->rts.disabled)
 		rthr = 32767;
 	else {
 		if ((rthr < 0) || (rthr > 2347))   /* What's the max packet size ??? */
@@ -1306,16 +1296,15 @@ static int ray_set_rts(struct net_device *dev,
 /*
  * Wireless Handler : get RTS threshold
  */
-static int ray_get_rts(struct net_device *dev,
-		       struct iw_request_info *info,
-		       struct iw_param *vwrq, char *extra)
+static int ray_get_rts(struct net_device *dev, struct iw_request_info *info,
+		       union iwreq_data *wrqu, char *extra)
 {
 	ray_dev_t *local = netdev_priv(dev);
 
-	vwrq->value = (local->sparm.b5.a_rts_threshold[0] << 8)
+	wrqu->rts.value = (local->sparm.b5.a_rts_threshold[0] << 8)
 	    + local->sparm.b5.a_rts_threshold[1];
-	vwrq->disabled = (vwrq->value == 32767);
-	vwrq->fixed = 1;
+	wrqu->rts.disabled = (wrqu->rts.value == 32767);
+	wrqu->rts.fixed = 1;
 
 	return 0;
 }
@@ -1324,19 +1313,18 @@ static int ray_get_rts(struct net_device *dev,
 /*
  * Wireless Handler : set Fragmentation threshold
  */
-static int ray_set_frag(struct net_device *dev,
-			struct iw_request_info *info,
-			struct iw_param *vwrq, char *extra)
+static int ray_set_frag(struct net_device *dev, struct iw_request_info *info,
+			union iwreq_data *wrqu, char *extra)
 {
 	ray_dev_t *local = netdev_priv(dev);
-	int fthr = vwrq->value;
+	int fthr = wrqu->frag.value;
 
 	/* Reject if card is already initialised */
 	if (local->card_status != CARD_AWAITING_PARAM)
 		return -EBUSY;
 
 	/* if(wrq->u.frag.fixed == 0) should complain */
-	if (vwrq->disabled)
+	if (wrqu->frag.disabled)
 		fthr = 32767;
 	else {
 		if ((fthr < 256) || (fthr > 2347))	/* To check out ! */
@@ -1352,16 +1340,15 @@ static int ray_set_frag(struct net_device *dev,
 /*
  * Wireless Handler : get Fragmentation threshold
  */
-static int ray_get_frag(struct net_device *dev,
-			struct iw_request_info *info,
-			struct iw_param *vwrq, char *extra)
+static int ray_get_frag(struct net_device *dev, struct iw_request_info *info,
+			union iwreq_data *wrqu, char *extra)
 {
 	ray_dev_t *local = netdev_priv(dev);
 
-	vwrq->value = (local->sparm.b5.a_frag_threshold[0] << 8)
+	wrqu->frag.value = (local->sparm.b5.a_frag_threshold[0] << 8)
 	    + local->sparm.b5.a_frag_threshold[1];
-	vwrq->disabled = (vwrq->value == 32767);
-	vwrq->fixed = 1;
+	wrqu->frag.disabled = (wrqu->frag.value == 32767);
+	wrqu->frag.fixed = 1;
 
 	return 0;
 }
@@ -1370,8 +1357,8 @@ static int ray_get_frag(struct net_device *dev,
 /*
  * Wireless Handler : set Mode of Operation
  */
-static int ray_set_mode(struct net_device *dev,
-			struct iw_request_info *info, __u32 *uwrq, char *extra)
+static int ray_set_mode(struct net_device *dev, struct iw_request_info *info,
+			union iwreq_data *wrqu, char *extra)
 {
 	ray_dev_t *local = netdev_priv(dev);
 	int err = -EINPROGRESS;	/* Call commit handler */
@@ -1381,7 +1368,7 @@ static int ray_set_mode(struct net_device *dev,
 	if (local->card_status != CARD_AWAITING_PARAM)
 		return -EBUSY;
 
-	switch (*uwrq) {
+	switch (wrqu->mode) {
 	case IW_MODE_ADHOC:
 		card_mode = 0;
 		/* Fall through */
@@ -1399,15 +1386,15 @@ static int ray_set_mode(struct net_device *dev,
 /*
  * Wireless Handler : get Mode of Operation
  */
-static int ray_get_mode(struct net_device *dev,
-			struct iw_request_info *info, __u32 *uwrq, char *extra)
+static int ray_get_mode(struct net_device *dev, struct iw_request_info *info,
+			union iwreq_data *wrqu, char *extra)
 {
 	ray_dev_t *local = netdev_priv(dev);
 
 	if (local->sparm.b5.a_network_type)
-		*uwrq = IW_MODE_INFRA;
+		wrqu->mode = IW_MODE_INFRA;
 	else
-		*uwrq = IW_MODE_ADHOC;
+		wrqu->mode = IW_MODE_ADHOC;
 
 	return 0;
 }
@@ -1416,16 +1403,15 @@ static int ray_get_mode(struct net_device *dev,
 /*
  * Wireless Handler : get range info
  */
-static int ray_get_range(struct net_device *dev,
-			 struct iw_request_info *info,
-			 struct iw_point *dwrq, char *extra)
+static int ray_get_range(struct net_device *dev, struct iw_request_info *info,
+			 union iwreq_data *wrqu, char *extra)
 {
 	struct iw_range *range = (struct iw_range *)extra;
 
-	memset((char *)range, 0, sizeof(struct iw_range));
+	memset(range, 0, sizeof(struct iw_range));
 
 	/* Set the length (very important for backward compatibility) */
-	dwrq->length = sizeof(struct iw_range);
+	wrqu->data.length = sizeof(struct iw_range);
 
 	/* Set the Wireless Extension versions */
 	range->we_version_compiled = WIRELESS_EXT;
@@ -1448,8 +1434,7 @@ static int ray_get_range(struct net_device *dev,
 /*
  * Wireless Private Handler : set framing mode
  */
-static int ray_set_framing(struct net_device *dev,
-			   struct iw_request_info *info,
+static int ray_set_framing(struct net_device *dev, struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
 	translate = *(extra);	/* Set framing mode */
@@ -1461,8 +1446,7 @@ static int ray_set_framing(struct net_device *dev,
 /*
  * Wireless Private Handler : get framing mode
  */
-static int ray_get_framing(struct net_device *dev,
-			   struct iw_request_info *info,
+static int ray_get_framing(struct net_device *dev, struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
 	*(extra) = translate;
@@ -1474,8 +1458,7 @@ static int ray_get_framing(struct net_device *dev,
 /*
  * Wireless Private Handler : get country
  */
-static int ray_get_country(struct net_device *dev,
-			   struct iw_request_info *info,
+static int ray_get_country(struct net_device *dev, struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
 	*(extra) = country;
@@ -1487,10 +1470,9 @@ static int ray_get_country(struct net_device *dev,
 /*
  * Commit handler : called after a bunch of SET operations
  */
-static int ray_commit(struct net_device *dev, struct iw_request_info *info,	/* NULL */
-		      void *zwrq,	/* NULL */
-		      char *extra)
-{ /* NULL */
+static int ray_commit(struct net_device *dev, struct iw_request_info *info,
+		      union iwreq_data *wrqu, char *extra)
+{
 	return 0;
 }
 
@@ -1531,28 +1513,28 @@ static iw_stats *ray_get_wireless_stats(struct net_device *dev)
  */
 
 static const iw_handler ray_handler[] = {
-	IW_HANDLER(SIOCSIWCOMMIT, (iw_handler)ray_commit),
-	IW_HANDLER(SIOCGIWNAME, (iw_handler)ray_get_name),
-	IW_HANDLER(SIOCSIWFREQ, (iw_handler)ray_set_freq),
-	IW_HANDLER(SIOCGIWFREQ, (iw_handler)ray_get_freq),
-	IW_HANDLER(SIOCSIWMODE, (iw_handler)ray_set_mode),
-	IW_HANDLER(SIOCGIWMODE, (iw_handler)ray_get_mode),
-	IW_HANDLER(SIOCGIWRANGE, (iw_handler)ray_get_range),
+	IW_HANDLER(SIOCSIWCOMMIT, ray_commit),
+	IW_HANDLER(SIOCGIWNAME, ray_get_name),
+	IW_HANDLER(SIOCSIWFREQ, ray_set_freq),
+	IW_HANDLER(SIOCGIWFREQ, ray_get_freq),
+	IW_HANDLER(SIOCSIWMODE, ray_set_mode),
+	IW_HANDLER(SIOCGIWMODE, ray_get_mode),
+	IW_HANDLER(SIOCGIWRANGE, ray_get_range),
 #ifdef WIRELESS_SPY
 	IW_HANDLER(SIOCSIWSPY, iw_handler_set_spy),
 	IW_HANDLER(SIOCGIWSPY, iw_handler_get_spy),
 	IW_HANDLER(SIOCSIWTHRSPY, iw_handler_set_thrspy),
 	IW_HANDLER(SIOCGIWTHRSPY, iw_handler_get_thrspy),
 #endif /* WIRELESS_SPY */
-	IW_HANDLER(SIOCGIWAP, (iw_handler)ray_get_wap),
-	IW_HANDLER(SIOCSIWESSID, (iw_handler)ray_set_essid),
-	IW_HANDLER(SIOCGIWESSID, (iw_handler)ray_get_essid),
-	IW_HANDLER(SIOCSIWRATE, (iw_handler)ray_set_rate),
-	IW_HANDLER(SIOCGIWRATE, (iw_handler)ray_get_rate),
-	IW_HANDLER(SIOCSIWRTS, (iw_handler)ray_set_rts),
-	IW_HANDLER(SIOCGIWRTS, (iw_handler)ray_get_rts),
-	IW_HANDLER(SIOCSIWFRAG, (iw_handler)ray_set_frag),
-	IW_HANDLER(SIOCGIWFRAG, (iw_handler)ray_get_frag),
+	IW_HANDLER(SIOCGIWAP, ray_get_wap),
+	IW_HANDLER(SIOCSIWESSID, ray_set_essid),
+	IW_HANDLER(SIOCGIWESSID, ray_get_essid),
+	IW_HANDLER(SIOCSIWRATE, ray_set_rate),
+	IW_HANDLER(SIOCGIWRATE, ray_get_rate),
+	IW_HANDLER(SIOCSIWRTS, ray_set_rts),
+	IW_HANDLER(SIOCGIWRTS, ray_get_rts),
+	IW_HANDLER(SIOCSIWFRAG, ray_set_frag),
+	IW_HANDLER(SIOCGIWFRAG, ray_get_frag),
 };
 
 #define SIOCSIPFRAMING	SIOCIWFIRSTPRIV	/* Set framing mode */
@@ -1560,9 +1542,9 @@ static const iw_handler ray_handler[] = {
 #define SIOCGIPCOUNTRY	SIOCIWFIRSTPRIV + 3	/* Get country code */
 
 static const iw_handler ray_private_handler[] = {
-	[0] = (iw_handler) ray_set_framing,
-	[1] = (iw_handler) ray_get_framing,
-	[3] = (iw_handler) ray_get_country,
+	[0] = ray_set_framing,
+	[1] = ray_get_framing,
+	[3] = ray_get_country,
 };
 
 static const struct iw_priv_args ray_private_args[] = {
-- 
1.7.0.14.g7e948
