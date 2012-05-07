From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC 4/6] tun: orphan frags on xmit
Date: Mon, 7 May 2012 16:54:47 +0300
Message-ID: <248cee8310a8d41b58b988dfea94e75ee79c6647.1336397823.git.mst@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57989 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756171Ab2EGNyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 09:54:45 -0400
Content-Disposition: inline
In-Reply-To: <cover.1336397823.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tun xmit is actually receive of the internal tun
socket. Orphan the frags same as we do for normal rx path.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/tun.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index bb8c72c..1ccbfd0 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -414,6 +414,8 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Orphan the skb - required as we might hang on to it
 	 * for indefinite time. */
+	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+		goto drop;
 	skb_orphan(skb);
 
 	/* Enqueue packet */
-- 
MST
