From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v2 03/13] esp4: Export esp4_err
Date: Mon, 16 Dec 2013 10:20:22 +0100
Message-ID: <20131216092022.GT31491@secunet.com>
References: <20131216091835.GQ31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51863 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214Ab3LPJUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 04:20:25 -0500
Content-Disposition: inline
In-Reply-To: <20131216091835.GQ31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

esp4_err can be shared with the upcomming vti esp handler.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/esp.h |    2 ++
 net/ipv4/esp4.c   |    3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/net/esp.h b/include/net/esp.h
index a43be85..e239597 100644
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -5,6 +5,8 @@
 
 struct ip_esp_hdr;
 
+int esp4_err(struct sk_buff *skb, u32 info);
+
 static inline struct ip_esp_hdr *ip_esp_hdr(const struct sk_buff *skb)
 {
 	return (struct ip_esp_hdr *)skb_transport_header(skb);
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index d1a4ccd..1e72fe0 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -473,7 +473,7 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 		 net_adj) & ~(blksize - 1)) + net_adj - 2;
 }
 
-static int esp4_err(struct sk_buff *skb, u32 info)
+int esp4_err(struct sk_buff *skb, u32 info)
 {
 	struct net *net = dev_net(skb->dev);
 	const struct iphdr *iph = (const struct iphdr *)skb->data;
@@ -503,6 +503,7 @@ static int esp4_err(struct sk_buff *skb, u32 info)
 
 	return 0;
 }
+EXPORT_SYMBOL(esp4_err);
 
 static void esp_destroy(struct xfrm_state *x)
 {
-- 
1.7.9.5
