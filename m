From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 3/8] amd-xgbe: Incorporate Smatch coding
 suggestion
Date: Thu, 20 Nov 2014 11:03:38 -0600
Message-ID: <20141120170338.15397.26365.stgit@tlendack-t1.amdoffice.net>
References: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0105.outbound.protection.outlook.com ([65.55.169.105]:38604
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758000AbaKTRDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 12:03:44 -0500
In-Reply-To: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Smatch tool indicated that one of the if statements in xgbe-dev.c
could be rewritten to remove a redundant check for the 'err' variable
in an if statement.

Change the statement as suggested and add a comment to help clarify.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index dcd0347..72425ff 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1633,7 +1633,8 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 	etlt = XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, ETLT);
 	DBGPR("  err=%u, etlt=%#x\n", err, etlt);
 
-	if (!err || (err && !etlt)) {
+	if (!err || !etlt) {
+		/* No error if err is 0 or etlt is 0 */
 		if ((etlt == 0x09) &&
 		    (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
 			XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
