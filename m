From: Yan Zheng <yanzheng@21cn.com>
Subject: [PATCH][MCAST]IPv6: Check packet size when process Multicast Address
 and Source Specific Query
Date: Mon, 31 Oct 2005 13:20:21 +0800
Message-ID: <4365A995.3050404@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751370AbVJaFTM@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Yan Zheng <yanzheng@21cn.com>

Index: net/ipv6/mcast.c
================================================================================
--- linux-2.6.14/net/ipv6/mcast.c	2005-10-30 23:09:33.000000000 +0800
+++ linux/net/ipv6/mcast.c	2005-10-31 13:13:10.000000000 +0800
@@ -1156,7 +1156,12 @@ int igmp6_event_query(struct sk_buff *sk
 			return 0;
 		}
 		/* mark sources to include, if group & source-specific */
-		mark = mlh2->nsrcs != 0;
+		if (mlh2->nsrcs != 0) {
+			if (!pskb_may_pull(skb, mlh2->nsrcs * sizeof(struct in6_addr) +
+				(sizeof(struct mld2_query) - sizeof(struct icmp6hdr))))
+				return -EINVAL;
+			mark = 1;
+		}
 	} else {
 		in6_dev_put(idev);
 		return -EINVAL;
