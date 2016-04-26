From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] ps3_gelic: fix memcpy parameter
Date: Tue, 26 Apr 2016 04:33:43 +0200
Message-ID: <1461638023-2986-1-git-send-email-christophe.jaillet@wanadoo.fr>
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.smtpout.orange.fr ([80.12.242.125]:19348 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbcDZCds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 22:33:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The size allocated for target->hwinfo and the number of bytes copied in it
should be consistent.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
Untested

 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index 13214a6..743b182 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -1622,7 +1622,7 @@ static void gelic_wl_scan_complete_event(struct gelic_wl_info *wl)
 			continue;
 
 		/* copy hw scan info */
-		memcpy(target->hwinfo, scan_info, scan_info->size);
+		memcpy(target->hwinfo, scan_info, be16_to_cpu(scan_info->size));
 		target->essid_len = strnlen(scan_info->essid,
 					    sizeof(scan_info->essid));
 		target->rate_len = 0;
-- 
2.7.4
