From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for hostap
Date: Tue, 29 Aug 2006 17:59:47 -0700
Message-ID: <20060830005947.GD8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:41213 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S1751124AbWH3BAa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 21:00:30 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Jouni Malinen <jkmaline@cc.hut.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


        Hi,

        WE-21 for HostAP driver...

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/drivers/net/wireless/hostap/hostap_ioctl.20.c linux/drivers/net/wireless/hostap/hostap_ioctl.c
--- linux/drivers/net/wireless/hostap/hostap_ioctl.20.c	2006-04-03 16:49:55.000000000 -0700
+++ linux/drivers/net/wireless/hostap/hostap_ioctl.c	2006-04-03 16:50:04.000000000 -0700
@@ -1412,9 +1412,9 @@ static int prism2_ioctl_siwretry(struct 
 	/* what could be done, if firmware would support this.. */
 
 	if (rrq->flags & IW_RETRY_LIMIT) {
-		if (rrq->flags & IW_RETRY_MAX)
+		if (rrq->flags & IW_RETRY_LONG)
 			HFA384X_RID_LONGRETRYLIMIT = rrq->value;
-		else if (rrq->flags & IW_RETRY_MIN)
+		else if (rrq->flags & IW_RETRY_SHORT)
 			HFA384X_RID_SHORTRETRYLIMIT = rrq->value;
 		else {
 			HFA384X_RID_LONGRETRYLIMIT = rrq->value;
@@ -1468,14 +1468,14 @@ static int prism2_ioctl_giwretry(struct 
 				rrq->value = le16_to_cpu(altretry);
 			else
 				rrq->value = local->manual_retry_count;
-		} else if ((rrq->flags & IW_RETRY_MAX)) {
-			rrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+		} else if ((rrq->flags & IW_RETRY_LONG)) {
+			rrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 			rrq->value = longretry;
 		} else {
 			rrq->flags = IW_RETRY_LIMIT;
 			rrq->value = shortretry;
 			if (shortretry != longretry)
-				rrq->flags |= IW_RETRY_MIN;
+				rrq->flags |= IW_RETRY_SHORT;
 		}
 	}
 	return 0;
