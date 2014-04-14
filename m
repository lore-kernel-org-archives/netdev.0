From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net 1/2] at86rf230: remove check if AVDD settled
Date: Mon, 14 Apr 2014 18:06:45 +0200
Message-ID: <1397491606-7290-2-git-send-email-alex.aring@gmail.com>
References: <1397491606-7290-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, phoebe.buckheister@itwm.fraunhofer.de,
	werner@almesberger.net, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:59629 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523AbaDNQG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 12:06:56 -0400
Received: by mail-ee0-f42.google.com with SMTP id d17so6825787eek.1
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 09:06:54 -0700 (PDT)
In-Reply-To: <1397491606-7290-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The AVDD regulator is only settled TX_ON (PLL_ON) state. Since commit
7dcbd22a97eb0689e6c583ad630ae0e7341e34c1 ("ieee802154: ensure that first
RF212 state comes from TRX_OFF"). We are in TRX_OFF state at the
beginning.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 430bb0d..e102eef 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -1025,14 +1025,6 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 		return -EINVAL;
 	}
 
-	rc = at86rf230_read_subreg(lp, SR_AVDD_OK, &status);
-	if (rc)
-		return rc;
-	if (!status) {
-		dev_err(&lp->spi->dev, "AVDD error\n");
-		return -EINVAL;
-	}
-
 	return 0;
 }
 
-- 
1.9.2
