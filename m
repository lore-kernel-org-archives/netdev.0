From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH] tcp: fix tcp_fastopen unaligned access complaints on sparc
Date: Thu, 12 Jan 2017 11:59:17 -0800
Message-ID: <1484251157-245538-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33163 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbdALT7m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 14:59:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix up a data alignment issue on sparc by swapping the order
of the cookie byte array field with the length field in
struct tcp_fastopen_cookie

This addresses log complaints like these:
    log_unaligned: 113 callbacks suppressed
    Kernel unaligned access at TPC[976490] tcp_try_fastopen+0x2d0/0x360
    Kernel unaligned access at TPC[9764ac] tcp_try_fastopen+0x2ec/0x360
    Kernel unaligned access at TPC[9764c8] tcp_try_fastopen+0x308/0x360
    Kernel unaligned access at TPC[9764e4] tcp_try_fastopen+0x324/0x360
    Kernel unaligned access at TPC[976490] tcp_try_fastopen+0x2d0/0x360

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 include/linux/tcp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index fc5848d..95cda75 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -62,8 +62,8 @@ static inline unsigned int tcp_optlen(const struct sk_buff *skb)
 
 /* TCP Fast Open Cookie as stored in memory */
 struct tcp_fastopen_cookie {
-	s8	len;
 	u8	val[TCP_FASTOPEN_COOKIE_MAX];
+	s8	len;
 	bool	exp;	/* In RFC6994 experimental option format */
 };
 
-- 
1.7.1
