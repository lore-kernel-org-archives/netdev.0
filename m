From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH 2/3] ipip: used time_before for comparing jiffies
Date: Tue, 24 Feb 2009 15:54:59 +0800
Message-ID: <49A3A7D3.8080508@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61499 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752407AbZBXHz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 02:55:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions time_before is more robust for comparing
jiffies against other values.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/ipv4/ipip.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 5079dfb..4b50199 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -327,7 +327,7 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
 		goto out;

-	if (jiffies - t->err_time < IPTUNNEL_ERR_TIMEO)
+	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
 		t->err_count++;
 	else
 		t->err_count = 1;
@@ -466,7 +466,8 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct
net_device *dev)
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





