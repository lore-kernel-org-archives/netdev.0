From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH 1/3] gre: used time_before for comparing jiffies
Date: Tue, 24 Feb 2009 15:54:42 +0800
Message-ID: <49A3A7C2.5050300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52739 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751888AbZBXHzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 02:55:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions time_before is more robust for comparing
jiffies against other values.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/ipv4/ip_gre.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0101521..811bef7 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -432,7 +432,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
 		goto out;

-	if (jiffies - t->err_time < IPTUNNEL_ERR_TIMEO)
+	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
 		t->err_count++;
 	else
 		t->err_count = 1;
@@ -744,7 +744,8 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct
net_device *dev)
 #endif

 	if (tunnel->err_count > 0) {
-		if (jiffies - tunnel->err_time < IPTUNNEL_ERR_TIMEO) {
+		if (time_before(jiffies,
+				tunnel->err_time + IPTUNNEL_ERR_TIMEO)) {
 			tunnel->err_count--;

 			dst_link_failure(skb);
-- 
1.5.3.8






