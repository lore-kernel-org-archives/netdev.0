From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH] hostap_plx: fix CIS verification
Date: Fri, 20 Oct 2006 18:20:15 -0400
Message-ID: <1161382815.5803.2.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hostap@shmoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:16453 "EHLO c60.cesmail.net")
	by vger.kernel.org with ESMTP id S2992715AbWJTWUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 18:20:17 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hostap_plx: fix CIS verification

The record length for numerical manufacturer ID should be at least 4
bytes (two 16-bit words).  The code required 5 bytes, which would break
for most (if not all) cards.  Reported by ph35sm@free.fr

Signed-off-by: Pavel Roskin <proski@gnu.org>
---
This is an small fix with significant impact.
hostap_plx is currently broken, and this patch fixes it.
Please forward this patch to 2.6.x.y kernels.

 drivers/net/wireless/hostap/hostap_plx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index 6dfa041..b5b72db 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -391,7 +391,7 @@ #define CIS_MAX_LEN 256
 			break;
 
 		case CISTPL_MANFID:
-			if (cis[pos + 1] < 5)
+			if (cis[pos + 1] < 4)
 				goto cis_error;
 			manfid1 = cis[pos + 2] + (cis[pos + 3] << 8);
 			manfid2 = cis[pos + 4] + (cis[pos + 5] << 8);

-- 
Regards,
Pavel Roskin

