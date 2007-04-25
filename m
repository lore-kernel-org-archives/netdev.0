From: Shani Moideen <shani.moideen@wipro.com>
Subject: [PATCH]:Replacing with time_before in net/ipv4/ip_gre.c
Date: Wed, 25 Apr 2007 11:30:17 +0530
Message-ID: <1177480817.27118.18.camel@shani-win>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@lists.osdl.org, netdev@vger.kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:36785 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423217AbXDYGEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 02:04:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Replacing with time_before in net/ipv4/ip_gre.c

thanks.

Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
----

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 9151da6..05cd63b 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -28,6 +28,7 @@
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/if_ether.h>
+#include <linux/jiffies.h>
 
 #include <net/sock.h>
 #include <net/ip.h>
@@ -376,7 +377,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
 		goto out;
 
-	if (jiffies - t->err_time < IPTUNNEL_ERR_TIMEO)
+	if (time_before(jiffies , t->err_time + IPTUNNEL_ERR_TIMEO))
 		t->err_count++;
 	else
 		t->err_count = 1;
@@ -801,7 +802,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 
 	if (tunnel->err_count > 0) {
-		if (jiffies - tunnel->err_time < IPTUNNEL_ERR_TIMEO) {
+		if (time_before(jiffies , tunnel->err_time + IPTUNNEL_ERR_TIMEO)) {
 			tunnel->err_count--;
 
 			dst_link_failure(skb);

----
Shani

