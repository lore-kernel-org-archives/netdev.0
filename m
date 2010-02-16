From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 5/6] bnx2: Fix bug when saving statistics.
Date: Mon, 15 Feb 2010 21:42:11 -0800
Message-ID: <1266298932-28129-5-git-send-email-mchan@broadcom.com>
References: <1266298932-28129-1-git-send-email-mchan@broadcom.com>
 <1266298932-28129-2-git-send-email-mchan@broadcom.com>
 <1266298932-28129-3-git-send-email-mchan@broadcom.com>
 <1266298932-28129-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3640 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152Ab0BPFdB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 00:33:01 -0500
In-Reply-To: <1266298932-28129-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Rabau <pr2345@gmail.com>

This fixes the problem of dropping the carry when adding 2 32-bit values.
Switch to use array indexing for better readability.

Reported by and fix provided by Patrick Rabau.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 2c75fd7..dda815a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6555,16 +6555,16 @@ bnx2_save_stats(struct bnx2 *bp)
 		u32 hi;
 		u64 lo;
 
-		hi = *(temp_stats + i) + *(hw_stats + i);
-		lo = *(temp_stats + i + 1) + *(hw_stats + i + 1);
+		hi = temp_stats[i] + hw_stats[i];
+		lo = (u64) temp_stats[i + 1] + (u64) hw_stats[i + 1];
 		if (lo > 0xffffffff)
 			hi++;
-		*(temp_stats + i) = hi;
-		*(temp_stats + i + 1) = lo & 0xffffffff;
+		temp_stats[i] = hi;
+		temp_stats[i + 1] = lo & 0xffffffff;
 	}
 
 	for ( ; i < sizeof(struct statistics_block) / 4; i++)
-		*(temp_stats + i) = *(temp_stats + i) + *(hw_stats + i);
+		temp_stats[i] += hw_stats[i];
 }
 
 #define GET_64BIT_NET_STATS64(ctr)				\
-- 
1.6.4.GIT


