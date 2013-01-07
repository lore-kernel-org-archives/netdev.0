From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] drivers/net/wireless/iwlegacy: use strlcpy instead of strncpy
Date: Mon, 07 Jan 2013 12:42:46 +0800
Message-ID: <50EA5246.8060206@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: sgruszka@redhat.com, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:32722 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524Ab3AGEly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 23:41:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  The fields must be null-terminated, or simple_strtoul will cause issue.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 drivers/net/wireless/iwlegacy/3945-mac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireless/iwlegacy/3945-mac.c
index d604b40..3726cd6 100644
--- a/drivers/net/wireless/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/iwlegacy/3945-mac.c
@@ -3273,7 +3273,7 @@ il3945_store_measurement(struct device *d, struct device_attribute *attr,
 
 	if (count) {
 		char *p = buffer;
-		strncpy(buffer, buf, min(sizeof(buffer), count));
+		strlcpy(buffer, buf, sizeof(buffer));
 		channel = simple_strtoul(p, NULL, 0);
 		if (channel)
 			params.channel = channel;
-- 
1.7.10.4
