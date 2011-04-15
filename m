From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 3/3] net: Adding siloing irqs to cxgb4 driver
Date: Fri, 15 Apr 2011 16:17:57 -0400
Message-ID: <1302898677-3833-4-git-send-email-nhorman@tuxdriver.com>
References: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
Cc: davem@davemloft.net, Neil Horman <nhorman@tuxdriver.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Howells <dhowells@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51341 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754544Ab1DOUTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 16:19:17 -0400
In-Reply-To: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cxgb4 hardware has been tested here and shows correct functionality with
affinity hinting infrastructure

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

CC: Dimitris Michailidis <dm@chelsio.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: David Howells <dhowells@redhat.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Tom Herbert <therbert@google.com>
---
 drivers/net/cxgb4/cxgb4_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 5352c8a..11aeef6 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -562,9 +562,11 @@ static int request_msix_queue_irqs(struct adapter *adap)
 		return err;
 
 	for_each_ethrxq(s, ethqidx) {
-		err = request_irq(adap->msix_info[msi].vec, t4_sge_intr_msix, 0,
+		err = request_net_irq(adap->msix_info[msi].vec, t4_sge_intr_msix, 0,
 				  adap->msix_info[msi].desc,
-				  &s->ethrxq[ethqidx].rspq);
+				  &s->ethrxq[ethqidx].rspq,
+				  adap->port[ethqidx/MAX_NPORTS],
+				  ethqidx % MAX_NPORTS);
 		if (err)
 			goto unwind;
 		msi++;
-- 
1.7.4.2

