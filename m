From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 1/4] bna: Clear Driver Config Flags When HW Resets
Date: Fri, 10 May 2013 10:02:14 -0700
Message-ID: <1368205337-4624-2-git-send-email-rmody@brocade.com>
References: <1368205337-4624-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:51162 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755879Ab3EJRax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 May 2013 13:30:53 -0400
In-Reply-To: <1368205337-4624-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

        Driver configuration flags are retained across open/stop operations
        preventing configurations to be set in next open/stop.
        Setting MTU on a 1020 causes network to fail until a reboot is performed
        on the host.

        Clear the flags when configuration resets in hardware.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index ce4a030..a6c16a2 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2624,6 +2624,9 @@ bnad_stop(struct net_device *netdev)
 	bnad_destroy_tx(bnad, 0);
 	bnad_destroy_rx(bnad, 0);
 
+	/* These config flags are cleared in the hardware */
+	bnad->cfg_flags &= ~(BNAD_CF_ALLMULTI | BNAD_CF_PROMISC);
+
 	/* Synchronize mailbox IRQ */
 	bnad_mbox_irq_sync(bnad);
 
-- 
1.7.1
