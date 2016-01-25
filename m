From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] net: i40e: shut up uninitialized variable warnings
Date: Mon, 25 Jan 2016 15:58:52 -0800
Message-ID: <1453766332-43274-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1453766332-43274-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:32347 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755477AbcAYX7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 18:59:14 -0500
In-Reply-To: <1453766332-43274-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

intel/i40e/i40e_txrx.c: In function 'i40e_xmit_frame_ring':
intel/i40e/i40e_txrx.c:2367:20: error: 'oiph' may be used uninitialized in this function [-Werror=maybe-uninitialized]
intel/i40e/i40e_txrx.c:2317:16: note: 'oiph' was declared here
intel/i40e/i40e_txrx.c:2367:17: error: 'oudph' may be used uninitialized in this function [-Werror=maybe-uninitialized]
intel/i40e/i40e_txrx.c:2316:17: note: 'oudph' was declared here

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 720516b..47bd8b3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2313,8 +2313,8 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 	struct iphdr *this_ip_hdr;
 	u32 network_hdr_len;
 	u8 l4_hdr = 0;
-	struct udphdr *oudph;
-	struct iphdr *oiph;
+	struct udphdr *oudph = NULL;
+	struct iphdr *oiph = NULL;
 	u32 l4_tunnel = 0;
 
 	if (skb->encapsulation) {
-- 
2.5.0
