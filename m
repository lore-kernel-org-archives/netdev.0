From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 1/1] Drivers: net-next: hyperv: Fix a bug in netvsc_start_xmit()
Date: Sun, 28 Sep 2014 19:49:51 -0700
Message-ID: <1411958991-28049-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>, <stable@vger.kernel.org>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After the packet is successfully sent, we should not touch the skb as it may
have been freed. This patch is based on the work done by
Long Li <longli@microsoft.com>. 

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Tested-by: Long Li <longli@microsoft.com>
Cc: <stable@vger.kernel.org>
---
 drivers/net/hyperv/netvsc_drv.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index a9c5eaa..0fcb5e7 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -387,6 +387,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	int  hdr_offset;
 	u32 net_trans_info;
 	u32 hash;
+	u32 skb_length = skb->len;
 
 
 	/* We will atmost need two pages to describe the rndis
@@ -562,7 +563,7 @@ do_send:
 
 drop:
 	if (ret == 0) {
-		net->stats.tx_bytes += skb->len;
+		net->stats.tx_bytes += skb_length;
 		net->stats.tx_packets++;
 	} else {
 		kfree(packet);
-- 
1.7.4.1
