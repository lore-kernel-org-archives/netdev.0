From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH] firewire net: Ensure checksumming in upper layer.
Date: Sun, 20 Jan 2013 16:43:40 +0900
Message-ID: <50FBA02C.9030203@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is wrong to set skb->ip_summed to CHECKSUM_UNNECESSARY unless
the device has already checked it.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index e7a711f5..df6a1ca 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -520,7 +520,7 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 	dev = netdev_priv(net);
 	/* Write metadata, and then pass to the receive level */
 	skb->dev = net;
-	skb->ip_summed = CHECKSUM_UNNECESSARY;  /* don't check it */
+	skb->ip_summed = CHECKSUM_NONE;
 
 	/*
 	 * Parse the encapsulation header. This actually does the job of
-- 
1.7.9.5
