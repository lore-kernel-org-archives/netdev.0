From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH V3 RFC 1/2] ixgbe: ixgbe_atr() should access udp_hdr(skb) only for UDP packets
Date: Mon, 17 Oct 2016 14:12:38 -0700
Message-ID: <0f20149c8dfb8601dcc7a63f1de95e2ab57c6328.1476737917.git.sowmini.varadhan@oracle.com>
References: <cover.1476737917.git.sowmini.varadhan@oracle.com>
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20102 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964903AbcJQVMt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 17:12:49 -0400
In-Reply-To: <cover.1476737917.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1476737917.git.sowmini.varadhan@oracle.com>
References: <cover.1476737917.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9f12df906cd8 ("ixgbe: Store VXLAN port number in network order")
incorrectly checks for hdr.ipv4->protocol != IPPROTO_UDP
in ixgbe_atr(). This check should be for "==" instead.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a244d9a..eceb47b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7653,7 +7653,7 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 	hdr.network = skb_network_header(skb);
 	if (skb->encapsulation &&
 	    first->protocol == htons(ETH_P_IP) &&
-	    hdr.ipv4->protocol != IPPROTO_UDP) {
+	    hdr.ipv4->protocol == IPPROTO_UDP) {
 		struct ixgbe_adapter *adapter = q_vector->adapter;
 
 		/* verify the port is recognized as VXLAN */
-- 
1.7.1
