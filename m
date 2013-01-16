From: Fabio Baltieri <fabio.baltieri@linaro.org>
Subject: [PATCH net-next] ipv6: fix ipv6_prefix_equal64_half mask conversion
Date: Wed, 16 Jan 2013 22:30:17 +0100
Message-ID: <1358371817-15378-1-git-send-email-fabio.baltieri@linaro.org>
Cc: linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Fabio Baltieri <fabio.baltieri@linaro.org>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the 64bit optimized version of ipv6_prefix_equal to convert the
bitmask to network byte order only after the bit-shift.

The bug was introduced in:

3867517 ipv6: 64bit version of ipv6_prefix_equal().

Signed-off-by: Fabio Baltieri <fabio.baltieri@linaro.org>
---
 include/net/ipv6.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index dfc1363..459a5a4 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -404,7 +404,7 @@ static inline bool __ipv6_prefix_equal64_half(const __be64 *a1,
 					      const __be64 *a2,
 					      unsigned int len)
 {
-	if (len && ((*a1 ^ *a2) & cpu_to_be64(~0UL) << (64 - len)))
+	if (len && ((*a1 ^ *a2) & cpu_to_be64((~0UL) << (64 - len))))
 		return false;
 	return true;
 }
-- 
1.7.12.1
