From: Shani Moideen <shani.moideen@wipro.com>
Subject: [PATCH]:Replace with time_before in net/ipv4/ipip.c
Date: Wed, 25 Apr 2007 11:30:13 +0530
Message-ID: <1177480813.27118.17.camel@shani-win>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:36779 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423217AbXDYGEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 02:04:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Replacing (jiffies - errtime < TIMEOUT) with time_before in net/ipv4/ipip.c

thanks.

Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
----


diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 3ec5ce0..d2bc835 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -108,6 +108,7 @@
 #include <linux/init.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/if_ether.h>
+#include <linux/jiffies.h>
 
 #include <net/sock.h>
 #include <net/ip.h>
@@ -324,7 +325,7 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
 		goto out;
 
-	if (jiffies - t->err_time < IPTUNNEL_ERR_TIMEO)
+	if (time_before(jiffies , t->err_time + IPTUNNEL_ERR_TIMEO))
 		t->err_count++;
 	else
 		t->err_count = 1;
@@ -590,7 +591,7 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (tunnel->err_count > 0) {
-		if (jiffies - tunnel->err_time < IPTUNNEL_ERR_TIMEO) {
+		if (time_before(jiffies , tunnel->err_time + IPTUNNEL_ERR_TIMEO)) {
 			tunnel->err_count--;
 			dst_link_failure(skb);
 		} else

-- 
Shani 
