From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 8/9] net/inetdevice: bad_mask can be boolean
Date: Thu,  8 Oct 2015 21:29:01 +0800
Message-ID: <1444310942-4428-9-git-send-email-bywxiaobai@163.com>
References: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, herbert@gondor.apana.org.au,
	johannes.berg@intel.com, daniel@iogearbox.net,
	gerrit@erg.abdn.ac.uk, socketcan@hartkopp.net, mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes bad_mask return bool due to this particular function
only using either one or zero as its return value.

No functional change.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 include/linux/inetdevice.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 3b0999e..ee971f3 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -180,15 +180,15 @@ static __inline__ bool inet_ifa_match(__be32 addr, struct in_ifaddr *ifa)
  *	Check if a mask is acceptable.
  */
  
-static __inline__ int bad_mask(__be32 mask, __be32 addr)
+static __inline__ bool bad_mask(__be32 mask, __be32 addr)
 {
 	__u32 hmask;
 	if (addr & (mask = ~mask))
-		return 1;
+		return true;
 	hmask = ntohl(mask);
 	if (hmask & (hmask+1))
-		return 1;
-	return 0;
+		return true;
+	return false;
 }
 
 #define for_primary_ifa(in_dev)	{ struct in_ifaddr *ifa; \
-- 
1.9.1
