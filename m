From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2-RFC 4/6] tun: orphan frags on xmit
Date: Thu, 17 May 2012 00:16:10 +0300
Message-ID: <75cd3b261c994d98e99c8671f3265f42eff4a974.1337202879.git.mst@redhat.com>
References: <cover.1337202879.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1337202879.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tun xmit is actually receive of the internal tun
socket. Orphan the frags same as we do for normal rx path.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/tun.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 987aeef..fe5cd2f3 100644
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
