From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for atmel
Date: Tue, 29 Aug 2006 17:59:03 -0700
Message-ID: <20060830005903.GC8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:5868 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S1751114AbWH3A7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 20:59:41 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Simon Kelley <simon@thekelleys.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


        Hi,

        WE-21 for Atmel driver...

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/drivers/net/wireless/atmel.19.c linux/drivers/net/wireless/atmel.c
--- linux/drivers/net/wireless/atmel.19.c	2006-08-28 17:24:23.000000000 -0700
+++ linux/drivers/net/wireless/atmel.c	2006-08-28 17:29:56.000000000 -0700
@@ -1656,13 +1656,13 @@ static int atmel_set_essid(struct net_de
 		priv->connect_to_any_BSS = 0;
 
 		/* Check the size of the string */
-		if (dwrq->length > MAX_SSID_LENGTH + 1)
+		if (dwrq->length > MAX_SSID_LENGTH)
 			 return -E2BIG;
 		if (index != 0)
 			return -EINVAL;
 
-		memcpy(priv->new_SSID, extra, dwrq->length - 1);
-		priv->new_SSID_size = dwrq->length - 1;
+		memcpy(priv->new_SSID, extra, dwrq->length);
+		priv->new_SSID_size = dwrq->length;
 	}
 
 	return -EINPROGRESS;
@@ -2120,9 +2120,9 @@ static int atmel_set_retry(struct net_de
 	struct atmel_private *priv = netdev_priv(dev);
 
 	if (!vwrq->disabled && (vwrq->flags & IW_RETRY_LIMIT)) {
-		if (vwrq->flags & IW_RETRY_MAX)
+		if (vwrq->flags & IW_RETRY_LONG)
 			priv->long_retry = vwrq->value;
-		else if (vwrq->flags & IW_RETRY_MIN)
+		else if (vwrq->flags & IW_RETRY_SHORT)
 			priv->short_retry = vwrq->value;
 		else {
 			/* No modifier : set both */
@@ -2144,15 +2144,15 @@ static int atmel_get_retry(struct net_de
 
 	vwrq->disabled = 0;      /* Can't be disabled */
 
-	/* Note : by default, display the min retry number */
-	if (vwrq->flags & IW_RETRY_MAX) {
-		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	/* Note : by default, display the short retry number */
+	if (vwrq->flags & IW_RETRY_LONG) {
+		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		vwrq->value = priv->long_retry;
 	} else {
 		vwrq->flags = IW_RETRY_LIMIT;
 		vwrq->value = priv->short_retry;
 		if (priv->long_retry != priv->short_retry)
-			vwrq->flags |= IW_RETRY_MIN;
+			vwrq->flags |= IW_RETRY_SHORT;
 	}
 
 	return 0;
