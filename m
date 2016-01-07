From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v2 net-next 3/5] net: vxlan: enable local checksum offload
Date: Thu, 7 Jan 2016 17:12:59 +0000
Message-ID: <568E9C9B.3090408@solarflare.com>
References: <568E9BF9.2050001@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:3361 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752883AbcAGRNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 12:13:15 -0500
In-Reply-To: <568E9BF9.2050001@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/vxlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6369a57..d4acbc9 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1733,7 +1733,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 		goto err;
 	}
 
-	skb = iptunnel_handle_offloads(skb, udp_sum, type);
+	skb = iptunnel_handle_offloads(skb, false, type);
 	if (IS_ERR(skb)) {
 		err = -EINVAL;
 		goto err;
@@ -1814,7 +1814,7 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 	if (WARN_ON(!skb))
 		return -ENOMEM;
 
-	skb = iptunnel_handle_offloads(skb, udp_sum, type);
+	skb = iptunnel_handle_offloads(skb, false, type);
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
 
