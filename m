From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for airo
Date: Tue, 29 Aug 2006 17:58:11 -0700
Message-ID: <20060830005811.GB8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:1260 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S1750869AbWH3A7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 20:59:16 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Javier Achirica <achirica@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi,

	WE-21 for Aironet driver...

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/drivers/net/wireless/airo.20.c linux/drivers/net/wireless/airo.c
--- linux/drivers/net/wireless/airo.20.c	2006-08-28 17:32:03.000000000 -0700
+++ linux/drivers/net/wireless/airo.c	2006-08-28 17:32:14.000000000 -0700
@@ -5876,7 +5876,7 @@ static int airo_set_essid(struct net_dev
 		int	index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
 
 		/* Check the size of the string */
-		if(dwrq->length > IW_ESSID_MAX_SIZE+1) {
+		if(dwrq->length > IW_ESSID_MAX_SIZE) {
 			return -E2BIG ;
 		}
 		/* Check if index is valid */
@@ -5888,7 +5888,7 @@ static int airo_set_essid(struct net_dev
 		memset(SSID_rid.ssids[index].ssid, 0,
 		       sizeof(SSID_rid.ssids[index].ssid));
 		memcpy(SSID_rid.ssids[index].ssid, extra, dwrq->length);
-		SSID_rid.ssids[index].len = dwrq->length - 1;
+		SSID_rid.ssids[index].len = dwrq->length;
 	}
 	SSID_rid.len = sizeof(SSID_rid);
 	/* Write it to the card */
@@ -5998,7 +5998,7 @@ static int airo_set_nick(struct net_devi
 	struct airo_info *local = dev->priv;
 
 	/* Check the size of the string */
-	if(dwrq->length > 16 + 1) {
+	if(dwrq->length > 16) {
 		return -E2BIG;
 	}
 	readConfigRid(local, 1);
@@ -6023,7 +6023,7 @@ static int airo_get_nick(struct net_devi
 	readConfigRid(local, 1);
 	strncpy(extra, local->config.nodeName, 16);
 	extra[16] = '\0';
-	dwrq->length = strlen(extra) + 1;
+	dwrq->length = strlen(extra);
 
 	return 0;
 }
@@ -6775,9 +6775,9 @@ static int airo_set_retry(struct net_dev
 	}
 	readConfigRid(local, 1);
 	if(vwrq->flags & IW_RETRY_LIMIT) {
-		if(vwrq->flags & IW_RETRY_MAX)
+		if(vwrq->flags & IW_RETRY_LONG)
 			local->config.longRetryLimit = vwrq->value;
-		else if (vwrq->flags & IW_RETRY_MIN)
+		else if (vwrq->flags & IW_RETRY_SHORT)
 			local->config.shortRetryLimit = vwrq->value;
 		else {
 			/* No modifier : set both */
@@ -6813,14 +6813,14 @@ static int airo_get_retry(struct net_dev
 	if((vwrq->flags & IW_RETRY_TYPE) == IW_RETRY_LIFETIME) {
 		vwrq->flags = IW_RETRY_LIFETIME;
 		vwrq->value = (int)local->config.txLifetime * 1024;
-	} else if((vwrq->flags & IW_RETRY_MAX)) {
-		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	} else if((vwrq->flags & IW_RETRY_LONG)) {
+		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		vwrq->value = (int)local->config.longRetryLimit;
 	} else {
 		vwrq->flags = IW_RETRY_LIMIT;
 		vwrq->value = (int)local->config.shortRetryLimit;
 		if((int)local->config.shortRetryLimit != (int)local->config.longRetryLimit)
-			vwrq->flags |= IW_RETRY_MIN;
+			vwrq->flags |= IW_RETRY_SHORT;
 	}
 
 	return 0;
@@ -6998,6 +6998,7 @@ static int airo_set_power(struct net_dev
 			local->config.rmode |= RXMODE_BC_MC_ADDR;
 			set_bit (FLAG_COMMIT, &local->flags);
 		case IW_POWER_ON:
+			/* This is broken, fixme ;-) */
 			break;
 		default:
 			return -EINVAL;
