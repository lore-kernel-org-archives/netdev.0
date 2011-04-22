From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH net-next 1/3] net:use help function of skb_checksum_start_offset
 to calculate offset
Date: Fri, 22 Apr 2011 19:07:41 +0800
Message-ID: <4DB1617D.30600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, cmetcalf@tilera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58322 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754670Ab1DVLLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2011 07:11:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although these are equivalent, but the skb_checksum_start_offset() is more readable.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 drivers/net/tile/tilepro.c |    2 +-
 net/ipv6/udp.c             |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tile/tilepro.c b/drivers/net/tile/tilepro.c
index 0825db6..1e980fd 100644
--- a/drivers/net/tile/tilepro.c
+++ b/drivers/net/tile/tilepro.c
@@ -1930,7 +1930,7 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 	unsigned int len = skb->len;
 	unsigned char *data = skb->data;
 
-	unsigned int csum_start = skb->csum_start - skb_headroom(skb);
+	unsigned int csum_start = skb_checksum_start_offset(skb);
 
 	lepp_frag_t frags[LEPP_MAX_FRAGS];
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 15c3774..95c62a1 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1328,7 +1328,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb, u32 features)
 	/* Do software UFO. Complete and fill in the UDP checksum as HW cannot
 	 * do checksum of UDP packets sent as multiple IP fragments.
 	 */
-	offset = skb->csum_start - skb_headroom(skb);
+	offset = skb_checksum_start_offset(skb);
 	csum = skb_checksum(skb, offset, skb->len- offset, 0);
 	offset += skb->csum_offset;
 	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
-- 
1.6.3.3
