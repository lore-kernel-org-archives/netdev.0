From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH net-next] myri10ge: fix incorrect use of ntohs()
Date: Fri, 30 Nov 2012 17:31:26 -0500
Message-ID: <1354314686-16149-1-git-send-email-gallatin@myri.com>
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:63571 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302Ab2K3Wbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 17:31:38 -0500
Received: by mail-gg0-f174.google.com with SMTP id k2so158605ggd.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 14:31:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1b4c44e6369dbbafd113f1e00b406f1eda5ab5b2 incorrectly used
ntohs() rather than htons() in myri10ge_vlan_rx().

Thanks to Fengguang Wu, Yuanhan Liu's kernel-build tester
for pointing out this bug.

Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 2fc984a..a40234e 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -1283,7 +1283,7 @@ myri10ge_vlan_rx(struct net_device *dev, void *addr, struct sk_buff *skb)
 	va += MXGEFW_PAD;
 	veh = (struct vlan_ethhdr *)va;
 	if ((dev->features & NETIF_F_HW_VLAN_RX) == NETIF_F_HW_VLAN_RX &&
-	    veh->h_vlan_proto == ntohs(ETH_P_8021Q)) {
+	    veh->h_vlan_proto == htons(ETH_P_8021Q)) {
 		/* fixup csum if needed */
 		if (skb->ip_summed == CHECKSUM_COMPLETE) {
 			vsum = csum_partial(va + ETH_HLEN, VLAN_HLEN, 0);
-- 
1.7.9.5
