From: Yan Zheng <yanzheng@21cn.com>
Subject: [PATCH]IPv6: small fix for ipv6_dev_get_saddr(...)
Date: Mon, 14 Nov 2005 18:42:30 +0800
Message-ID: <43786A16.9070100@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751064AbVKNKk5@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "score.rule++" doesn't make any sense for me. 
According to codes above, I think it should be "hiscore.rule++;" .


Signed-off-by: Yan Zheng<yanzheng@21cn.com>

Index: net/ipv6/addrconf.c
============================================================
--- a/net/ipv6/addrconf.c	2005-11-13 12:23:06.000000000 +0800
+++ b/net/ipv6/addrconf.c	2005-11-14 18:29:27.000000000 +0800
@@ -1045,9 +1045,10 @@ int ipv6_dev_get_saddr(struct net_device
 			}
 #endif
 			/* Rule 8: Use longest matching prefix */
-			if (hiscore.rule < 8)
+			if (hiscore.rule < 8) {
 				hiscore.matchlen = ipv6_addr_diff(&ifa_result->addr, daddr);
-			score.rule++;
+				hiscore.rule++;
+			}
 			score.matchlen = ipv6_addr_diff(&ifa->addr, daddr);
 			if (score.matchlen > hiscore.matchlen) {
 				score.rule = 8;
