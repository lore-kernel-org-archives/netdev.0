From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next] ethtool: exit the loop when invalid index occurs
Date: Sun, 27 Apr 2014 02:20:38 -0600
Message-ID: <1398586838-21474-1-git-send-email-sakiwit@gmail.com>
Cc: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:51705 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752840AbaD0IX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 04:23:59 -0400
Received: by mail-pa0-f52.google.com with SMTP id kx10so4708461pab.11
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2014 01:23:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 3de0b592394d ("ethtool: Support for configurable RSS hash
key") introduced a new function ethtool_copy_validate_indir() with
full iteration of the loop to validate the ring indices, which could
be an overkill. To minimize the impact, we ought to exit the loop as
soon as the invalid index occurs for the very first time. The
remaining loop simply doesn't serve any more purpose.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
---
 net/core/ethtool.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1d72786ef866..aa8978ac47d2 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -568,8 +568,10 @@ static int ethtool_copy_validate_indir(u32 *indir, void __user *useraddr,
 
 	/* Validate ring indices */
 	for (i = 0; i < size; i++) {
-		if (indir[i] >= rx_rings->data)
+		if (indir[i] >= rx_rings->data) {
 			ret = -EINVAL;
+			break;
+		}
 	}
 	return ret;
 }
