From: William Dauchy <william@gandi.net>
Subject: [PATCH] ixgbevf: Fix handling of napi budget when multiple queues are enabled per vector
Date: Fri, 30 Oct 2015 18:16:30 +0100
Message-ID: <1446225390-19140-1-git-send-email-william@gandi.net>
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	intel-wired-lan@lists.osuosl.org, emil.s.tantilov@intel.com,
	aduyck@mirantis.com, William Dauchy <william@gandi.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33371 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759813AbbJ3RQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 13:16:46 -0400
Received: by padhy1 with SMTP id hy1so73773380pad.0
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 10:16:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the same patch as for ixgbe but applied differently according to
busy polling.
see commit "ixgbe: Fix handling of napi budget when multiple queues are
 enabled per vector"

Signed-off-by: William Dauchy <william@gandi.net>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 149a0b4..ff6e21d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1014,6 +1014,8 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 	ixgbevf_for_each_ring(ring, q_vector->tx)
 		clean_complete &= ixgbevf_clean_tx_irq(q_vector, ring);
 
+	if (budget <= 0)
+		return budget;
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	if (!ixgbevf_qv_lock_napi(q_vector))
 		return budget;
-- 
2.6.1
