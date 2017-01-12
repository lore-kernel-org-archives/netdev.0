From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: remove unnecessary code
Date: Wed, 11 Jan 2017 17:09:02 -0800
Message-ID: <20170112010902.GA9597@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0070.outbound.protection.outlook.com ([104.47.32.70]:62795
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1761280AbdALBKD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 20:10:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove code that's no longer needed.  It used to serve a purpose, which was
to fix a link-related bug.  For a while now, the NIC firmware has had a
more elegant fix for that bug.

Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index b8b579d..cc825d5 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2693,13 +2693,7 @@ static int liquidio_stop(struct net_device *netdev)
 	lio->linfo.link.s.link_up = 0;
 	lio->link_changes++;
 
-	/* Pause for a moment and wait for Octeon to flush out (to the wire) any
-	 * egress packets that are in-flight.
-	 */
-	set_current_state(TASK_INTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(100));
-
-	/* Now it should be safe to tell Octeon that nic interface is down. */
+	/* Tell Octeon that nic interface is down. */
 	send_rx_ctrl_cmd(lio, 0);
 
 	if (OCTEON_CN23XX_PF(oct)) {
