From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for Prism54
Date: Tue, 29 Aug 2006 18:03:23 -0700
Message-ID: <20060830010323.GH8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:37868 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S1751287AbWH3BD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 21:03:56 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

        Hi,

        WE-21 for Prism54 driver...

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/drivers/net/wireless/prism54/isl_ioctl.20.c linux/drivers/net/wireless/prism54/isl_ioctl.c
--- linux/drivers/net/wireless/prism54/isl_ioctl.20.c	2006-04-03 17:01:26.000000000 -0700
+++ linux/drivers/net/wireless/prism54/isl_ioctl.c	2006-04-03 17:01:50.000000000 -0700
@@ -717,9 +717,9 @@ prism54_set_essid(struct net_device *nde
 
 	/* Check if we were asked for `any' */
 	if (dwrq->flags && dwrq->length) {
-		if (dwrq->length > min(33, IW_ESSID_MAX_SIZE + 1))
+		if (dwrq->length > 32)
 			return -E2BIG;
-		essid.length = dwrq->length - 1;
+		essid.length = dwrq->length;
 		memcpy(essid.octets, extra, dwrq->length);
 	} else
 		essid.length = 0;
@@ -789,7 +789,7 @@ prism54_get_nick(struct net_device *ndev
 	dwrq->length = 0;
 
 	down_read(&priv->mib_sem);
-	dwrq->length = strlen(priv->nickname) + 1;
+	dwrq->length = strlen(priv->nickname);
 	memcpy(extra, priv->nickname, dwrq->length);
 	up_read(&priv->mib_sem);
 
@@ -967,9 +967,9 @@ prism54_set_retry(struct net_device *nde
 		return -EINVAL;
 
 	if (vwrq->flags & IW_RETRY_LIMIT) {
-		if (vwrq->flags & IW_RETRY_MIN)
+		if (vwrq->flags & IW_RETRY_SHORT)
 			slimit = vwrq->value;
-		else if (vwrq->flags & IW_RETRY_MAX)
+		else if (vwrq->flags & IW_RETRY_LONG)
 			llimit = vwrq->value;
 		else {
 			/* we are asked to set both */
@@ -1010,18 +1010,18 @@ prism54_get_retry(struct net_device *nde
 		    mgt_get_request(priv, DOT11_OID_MAXTXLIFETIME, 0, NULL, &r);
 		vwrq->value = r.u * 1024;
 		vwrq->flags = IW_RETRY_LIFETIME;
-	} else if ((vwrq->flags & IW_RETRY_MAX)) {
+	} else if ((vwrq->flags & IW_RETRY_LONG)) {
 		/* we are asked for the long retry limit */
 		rvalue |=
 		    mgt_get_request(priv, DOT11_OID_LONGRETRIES, 0, NULL, &r);
 		vwrq->value = r.u;
-		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 	} else {
 		/* default. get the  short retry limit */
 		rvalue |=
 		    mgt_get_request(priv, DOT11_OID_SHORTRETRIES, 0, NULL, &r);
 		vwrq->value = r.u;
-		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_MIN;
+		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_SHORT;
 	}
 
 	return rvalue;
