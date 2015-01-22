From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH v1] cxgb3: re-use native hex2bin()
Date: Thu, 22 Jan 2015 23:37:39 +0200
Message-ID: <1421962659-25885-1-git-send-email-andy.shevchenko@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
To: netdev@vger.kernel.org, Santosh Raspatur <santosh@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw02.mail.saunalahti.fi ([195.197.172.116]:58469 "EHLO
	gw02.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbbAVVhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 16:37:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call hex2bin() library function instead of doing conversion here.

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
---
 drivers/net/ethernet/chelsio/cxgb3/t3_hw.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
index c74a898..184a8d5 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
@@ -727,9 +727,9 @@ static int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 		p->xauicfg[1] = simple_strtoul(vpd.xaui1cfg_data, NULL, 16);
 	}
 
-	for (i = 0; i < 6; i++)
-		p->eth_base[i] = hex_to_bin(vpd.na_data[2 * i]) * 16 +
-				 hex_to_bin(vpd.na_data[2 * i + 1]);
+	ret = hex2bin(p->eth_base, vpd.na_data, 6);
+	if (ret < 0)
+		return -EINVAL;
 	return 0;
 }
 
-- 
1.8.3.101.g727a46b
