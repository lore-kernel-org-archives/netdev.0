From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] drivers/net/skfp: if !capable(CAP_NET_ADMIN): inverted logic
Date: Wed, 28 Jan 2009 20:25:41 +0100
Message-ID: <4980B135.8040209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:32428 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbZA1TZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 14:25:42 -0500
Received: by nf-out-0910.google.com with SMTP id d3so1350304nfc.21
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2009 11:25:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

untested, but It seems this is likely what it should be.
--------------------->8---------8<----------------
fix inverted logic

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 607efea..9a00e55 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -1003,9 +1003,9 @@ static int skfp_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		break;
 	case SKFP_CLR_STATS:	/* Zero out the driver statistics */
 		if (!capable(CAP_NET_ADMIN)) {
-			memset(&lp->MacStat, 0, sizeof(lp->MacStat));
-		} else {
 			status = -EPERM;
+		} else {
+			memset(&lp->MacStat, 0, sizeof(lp->MacStat));
 		}
 		break;
 	default:
