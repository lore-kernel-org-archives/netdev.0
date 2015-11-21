From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 5/9] net: ipmr: make ip_mroute_getsockopt more understandable
Date: Sat, 21 Nov 2015 14:01:38 +0100
Message-ID: <1448110902-28793-6-git-send-email-razor@blackwall.org>
References: <1448110902-28793-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35762 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759895AbbKUNBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 08:01:52 -0500
Received: by wmuu63 with SMTP id u63so6066332wmu.0
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 05:01:50 -0800 (PST)
In-Reply-To: <1448110902-28793-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Use a switch to determine if optname is correct and set val accordingly.
This produces a much more straight-forward and readable code.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/ipv4/ipmr.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 286ede3716ee..694fecf7838e 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1443,29 +1443,29 @@ int ip_mroute_getsockopt(struct sock *sk, int optname, char __user *optval, int
 	if (!mrt)
 		return -ENOENT;
 
-	if (optname != MRT_VERSION &&
-	   optname != MRT_PIM &&
-	   optname != MRT_ASSERT)
+	switch (optname) {
+	case MRT_VERSION:
+		val = 0x0305;
+		break;
+	case MRT_PIM:
+		if (!pimsm_enabled())
+			return -ENOPROTOOPT;
+		val = mrt->mroute_do_pim;
+		break;
+	case MRT_ASSERT:
+		val = mrt->mroute_do_assert;
+		break;
+	default:
 		return -ENOPROTOOPT;
+	}
 
 	if (get_user(olr, optlen))
 		return -EFAULT;
-
 	olr = min_t(unsigned int, olr, sizeof(int));
 	if (olr < 0)
 		return -EINVAL;
-
 	if (put_user(olr, optlen))
 		return -EFAULT;
-	if (optname == MRT_VERSION) {
-		val = 0x0305;
-	} else if (optname == MRT_PIM) {
-		if (!pimsm_enabled())
-			return -ENOPROTOOPT;
-		val = mrt->mroute_do_pim;
-	} else {
-		val = mrt->mroute_do_assert;
-	}
 	if (copy_to_user(optval, &val, olr))
 		return -EFAULT;
 	return 0;
-- 
2.4.3
