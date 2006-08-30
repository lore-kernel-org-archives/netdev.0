From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for ipw2200
Date: Tue, 29 Aug 2006 18:01:40 -0700
Message-ID: <20060830010140.GF8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:13822 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S1751255AbWH3BCO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 21:02:14 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

        Hi,

        WE-21 for IPW2200 driver...

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/drivers/net/wireless/ipw2200.20.c linux/drivers/net/wireless/ipw2200.c
--- linux/drivers/net/wireless/ipw2200.20.c	2006-08-28 17:35:29.000000000 -0700
+++ linux/drivers/net/wireless/ipw2200.c	2006-08-28 17:36:09.000000000 -0700
@@ -8861,7 +8861,7 @@ static int ipw_wx_set_essid(struct net_d
 	int length = 0;
 	mutex_lock(&priv->mutex);
 	if (wrqu->essid.flags && wrqu->essid.length) {
-		length = wrqu->essid.length - 1;
+		length = wrqu->essid.length;
 		essid = extra;
 	}
 	if (length == 0) {
@@ -8954,7 +8954,7 @@ static int ipw_wx_get_nick(struct net_de
 	struct ipw_priv *priv = ieee80211_priv(dev);
 	IPW_DEBUG_WX("Getting nick\n");
 	mutex_lock(&priv->mutex);
-	wrqu->data.length = strlen(priv->nick) + 1;
+	wrqu->data.length = strlen(priv->nick);
 	memcpy(extra, priv->nick, wrqu->data.length);
 	wrqu->data.flags = 1;	/* active */
 	mutex_unlock(&priv->mutex);
@@ -9277,9 +9277,9 @@ static int ipw_wx_set_retry(struct net_d
 		return -EINVAL;
 
 	mutex_lock(&priv->mutex);
-	if (wrqu->retry.flags & IW_RETRY_MIN)
+	if (wrqu->retry.flags & IW_RETRY_SHORT)
 		priv->short_retry_limit = (u8) wrqu->retry.value;
-	else if (wrqu->retry.flags & IW_RETRY_MAX)
+	else if (wrqu->retry.flags & IW_RETRY_LONG)
 		priv->long_retry_limit = (u8) wrqu->retry.value;
 	else {
 		priv->short_retry_limit = (u8) wrqu->retry.value;
@@ -9308,11 +9308,11 @@ static int ipw_wx_get_retry(struct net_d
 		return -EINVAL;
 	}
 
-	if (wrqu->retry.flags & IW_RETRY_MAX) {
-		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	if (wrqu->retry.flags & IW_RETRY_LONG) {
+		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		wrqu->retry.value = priv->long_retry_limit;
-	} else if (wrqu->retry.flags & IW_RETRY_MIN) {
-		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MIN;
+	} else if (wrqu->retry.flags & IW_RETRY_SHORT) {
+		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_SHORT;
 		wrqu->retry.value = priv->short_retry_limit;
 	} else {
 		wrqu->retry.flags = IW_RETRY_LIMIT;
