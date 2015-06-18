From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] tun, macvtap: higher order allocations for skbs
Date: Thu, 18 Jun 2015 12:20:17 +0200
Message-ID: <1434622758-16549-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753027AbbFRKUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2015 06:20:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Needs more testing. Anyone see anything wrong with this?

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/macvtap.c | 2 +-
 drivers/net/tun.c     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 928f3f4..80e87e4 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -610,7 +610,7 @@ static inline struct sk_buff *macvtap_alloc_skb(struct sock *sk, size_t prepad,
 		linear = len;
 
 	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
-				   err, 0);
+				   err, 1);
 	if (!skb)
 		return NULL;
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index cb376b2d..8f2f1e5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1069,7 +1069,7 @@ static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
 		linear = len;
 
 	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
-				   &err, 0);
+				   &err, 1);
 	if (!skb)
 		return ERR_PTR(err);
 
-- 
MST
