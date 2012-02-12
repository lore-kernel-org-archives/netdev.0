From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH] sfc: mtd: Use MTD_FAIL_ADDR_UNKNOWN instead of 0xffffffff
Date: Sun, 12 Feb 2012 11:13:08 +0200
Message-ID: <20120212111308.0267f200@pixies.home.jungo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Artem Bityutskiy <dedekind1@gmail.com>,
	shmulik.ladkani@gmail.com
To: Ben Hutchings <bhutchings@solarflare.com>,
	linux-net-drivers@solarflare.com, linux-mtd@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:41706 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274Ab2BLJNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2012 04:13:19 -0500
Received: by wics10 with SMTP id s10so2875704wic.19
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2012 01:13:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>

As of bb0eb217, MTD_FAIL_ADDR_UNKNOWN should be used to indicate mtd
erase failure not specific to any particular block.

Use MTD_FAIL_ADDR_UNKNOWN instead of 0xffffffff when setting
'erase->fail_addr' in 'efx_mtd_erase()'.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
index 6622eca..c44a03e 100644
--- a/drivers/net/ethernet/sfc/mtd.c
+++ b/drivers/net/ethernet/sfc/mtd.c
@@ -193,7 +193,7 @@ static int efx_mtd_erase(struct mtd_info *mtd, struct erase_info *erase)
 		erase->state = MTD_ERASE_DONE;
 	} else {
 		erase->state = MTD_ERASE_FAILED;
-		erase->fail_addr = 0xffffffff;
+		erase->fail_addr = MTD_FAIL_ADDR_UNKNOWN;
 	}
 	mtd_erase_callback(erase);
 	return rc;
