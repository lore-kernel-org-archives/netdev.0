From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH 3/3] sit: used time_before for comparing jiffies
Date: Fri, 20 Feb 2009 12:07:04 +0800
Message-ID: <499E2C68.7070006@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57639 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753249AbZBTEH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 23:07:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions time_before is more robust for comparing
jiffies against other values.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/ipv6/sit.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index d3467e5..26915ef 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -454,7 +454,7 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
 		goto out;
 
-	if (jiffies - t->err_time < IPTUNNEL_ERR_TIMEO)
+	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
 		t->err_count++;
 	else
 		t->err_count = 1;
@@ -658,7 +658,8 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (tunnel->err_count > 0) {
-		if (jiffies - tunnel->err_time < IPTUNNEL_ERR_TIMEO) {
+		if (time_before(jiffies,
+				tunnel->err_time + IPTUNNEL_ERR_TIMEO)) {
 			tunnel->err_count--;
 			dst_link_failure(skb);
 		} else
-- 
1.5.3.8




