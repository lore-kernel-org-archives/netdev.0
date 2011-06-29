From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: ucc_geth:  Omit check for multicast bit in netdev_for_each_mc_addr
Date: Wed, 29 Jun 2011 14:16:33 +0200
Message-ID: <1309349793-1864-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: "David S. Miller" <davem@davemloft.net>,
	Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:40102 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753907Ab1F2MZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2011 08:25:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to check for the address being a multicast address in
the netdev_for_each_mc_addr loop, so remove it.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ucc_geth.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 3127700..d3465ab 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2030,11 +2030,6 @@ static void ucc_geth_set_multi(struct net_device *dev)
 			out_be32(&p_82xx_addr_filt->gaddr_l, 0x0);
 
 			netdev_for_each_mc_addr(ha, dev) {
-				/* Only support group multicast for now.
-				 */
-				if (!is_multicast_ether_addr(ha->addr))
-					continue;
-
 				/* Ask CPM to run CRC and set bit in
 				 * filter mask.
 				 */
-- 
1.7.5.4

