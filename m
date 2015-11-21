From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 6/9] net: ipmr: drop an instance of CONFIG_IP_MROUTE_MULTIPLE_TABLES
Date: Sat, 21 Nov 2015 14:01:39 +0100
Message-ID: <1448110902-28793-7-git-send-email-razor@blackwall.org>
References: <1448110902-28793-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34258 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759899AbbKUNBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 08:01:52 -0500
Received: by wmvv187 with SMTP id v187so105479265wmv.1
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 05:01:51 -0800 (PST)
In-Reply-To: <1448110902-28793-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Trivial replace of ifdef with IS_BUILTIN().

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/ipv4/ipmr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 694fecf7838e..a006d96d6cd9 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1396,11 +1396,12 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		rtnl_unlock();
 		return ret;
 	}
-#ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES
 	case MRT_TABLE:
 	{
 		u32 v;
 
+		if (!IS_BUILTIN(CONFIG_IP_MROUTE_MULTIPLE_TABLES))
+			return -ENOPROTOOPT;
 		if (optlen != sizeof(u32))
 			return -EINVAL;
 		if (get_user(v, (u32 __user *)optval))
@@ -1420,7 +1421,6 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		rtnl_unlock();
 		return ret;
 	}
-#endif
 	/* Spurious command, or MRT_VERSION which you cannot set. */
 	default:
 		return -ENOPROTOOPT;
-- 
2.4.3
