From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 04/14] amd-xgbe: Update TSO packet statistics
 accuracy
Date: Thu, 17 Aug 2017 19:02:40 -0500
Message-ID: <20170818000240.10005.76505.stgit@tlendack-t1.amdoffice.net>
References: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0060.outbound.protection.outlook.com ([104.47.42.60]:16928
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753471AbdHRACq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 20:02:46 -0400
In-Reply-To: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When transmitting a TSO packet, the driver only increments the TSO packet
statistic by one rather than the number of total packets that were sent.
Update the driver to record the total number of packets that resulted from
TSO transmit.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 06f953e..bb60507 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1740,7 +1740,7 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, TCPHDRLEN,
 				  packet->tcp_header_len / 4);
 
-		pdata->ext_stats.tx_tso_packets++;
+		pdata->ext_stats.tx_tso_packets += packet->tx_packets;
 	} else {
 		/* Enable CRC and Pad Insertion */
 		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, CPC, 0);
