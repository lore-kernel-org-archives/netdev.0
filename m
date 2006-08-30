From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for ipw2100
Date: Tue, 29 Aug 2006 18:00:48 -0700
Message-ID: <20060830010048.GE8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:28396 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S1751287AbWH3BCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 21:02:38 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

        Hi,

        WE-21 for IPW2100 driver...

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/drivers/net/wireless/ipw2100.20.c linux/drivers/net/wireless/ipw2100.c
--- linux/drivers/net/wireless/ipw2100.20.c	2006-08-28 17:34:28.000000000 -0700
+++ linux/drivers/net/wireless/ipw2100.c	2006-08-28 17:34:35.000000000 -0700
@@ -6957,7 +6957,7 @@ static int ipw2100_wx_set_essid(struct n
 	}
 
 	if (wrqu->essid.flags && wrqu->essid.length) {
-		length = wrqu->essid.length - 1;
+		length = wrqu->essid.length;
 		essid = extra;
 	}
 
@@ -7050,7 +7050,7 @@ static int ipw2100_wx_get_nick(struct ne
 
 	struct ipw2100_priv *priv = ieee80211_priv(dev);
 
-	wrqu->data.length = strlen(priv->nick) + 1;
+	wrqu->data.length = strlen(priv->nick);
 	memcpy(extra, priv->nick, wrqu->data.length);
 	wrqu->data.flags = 1;	/* active */
 
@@ -7342,14 +7342,14 @@ static int ipw2100_wx_set_retry(struct n
 		goto done;
 	}
 
-	if (wrqu->retry.flags & IW_RETRY_MIN) {
+	if (wrqu->retry.flags & IW_RETRY_SHORT) {
 		err = ipw2100_set_short_retry(priv, wrqu->retry.value);
 		IPW_DEBUG_WX("SET Short Retry Limit -> %d \n",
 			     wrqu->retry.value);
 		goto done;
 	}
 
-	if (wrqu->retry.flags & IW_RETRY_MAX) {
+	if (wrqu->retry.flags & IW_RETRY_LONG) {
 		err = ipw2100_set_long_retry(priv, wrqu->retry.value);
 		IPW_DEBUG_WX("SET Long Retry Limit -> %d \n",
 			     wrqu->retry.value);
@@ -7382,14 +7382,14 @@ static int ipw2100_wx_get_retry(struct n
 	if ((wrqu->retry.flags & IW_RETRY_TYPE) == IW_RETRY_LIFETIME)
 		return -EINVAL;
 
-	if (wrqu->retry.flags & IW_RETRY_MAX) {
-		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	if (wrqu->retry.flags & IW_RETRY_LONG) {
+		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		wrqu->retry.value = priv->long_retry_limit;
 	} else {
 		wrqu->retry.flags =
 		    (priv->short_retry_limit !=
 		     priv->long_retry_limit) ?
-		    IW_RETRY_LIMIT | IW_RETRY_MIN : IW_RETRY_LIMIT;
+		    IW_RETRY_LIMIT | IW_RETRY_SHORT : IW_RETRY_LIMIT;
 
 		wrqu->retry.value = priv->short_retry_limit;
 	}
