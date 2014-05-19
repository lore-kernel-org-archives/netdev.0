From: Michael Spang <spang@chromium.org>
Subject: [PATCH] macvlan: Fix checksum errors when ip_summed is CHECKSUM_PARTIAL
Date: Mon, 19 May 2014 13:24:14 -0400
Message-ID: <1400520254-5142-1-git-send-email-spang@chromium.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Spang <spang@chromium.org>, stable@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:64240 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932733AbaESR0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 13:26:39 -0400
Received: by mail-ig0-f172.google.com with SMTP id uy17so3783851igb.5
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 10:26:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing ip_summed from CHECKSUM_PARTIAL to CHECKSUM_UNNECESSARY
will result in an incorrect checksum if the packet is sent off the box.

Cc: stable@vger.kernel.org
Signed-off-by: Michael Spang <spang@chromium.org>
---
 drivers/net/macvlan.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 753a8c2..806b56a 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -267,7 +267,9 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (vlan->mode == MACVLAN_MODE_BRIDGE) {
 		const struct ethhdr *eth = (void *)skb->data;
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+		if (skb->ip_summed == CHECKSUM_NONE)
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 		/* send to other bridge ports directly */
 		if (is_multicast_ether_addr(eth->h_dest)) {
-- 
2.0.0.rc2
