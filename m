From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net] cxgb4: Fix unable to get UP event from the LLD
Date: Mon, 29 Oct 2012 17:32:36 +0530
Message-ID: <1351512156-11636-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>,
	Jay Hernandez <jay@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28385 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754978Ab2J2MGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 08:06:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If T4 configuration file gets loaded from the /lib/firmware/cxgb4/ directory
then offload capabilities of the cards were getting disabled during
initialization. Hence ULDs do not get an UP event from the LLD.

Signed-off-by: Jay Hernandez <jay@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c1cde11..0df1284 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3416,16 +3416,6 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 			 finicsum, cfcsum);
 
 	/*
-	 * If we're a pure NIC driver then disable all offloading facilities.
-	 * This will allow the firmware to optimize aspects of the hardware
-	 * configuration which will result in improved performance.
-	 */
-	caps_cmd.ofldcaps = 0;
-	caps_cmd.iscsicaps = 0;
-	caps_cmd.rdmacaps = 0;
-	caps_cmd.fcoecaps = 0;
-
-	/*
 	 * And now tell the firmware to use the configuration we just loaded.
 	 */
 	caps_cmd.op_to_write =
-- 
1.7.1
