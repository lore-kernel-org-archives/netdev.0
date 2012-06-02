From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] e1000: look into the page instead of skb->data for e1000_tbi_adjust_stats()
Date: Sat,  2 Jun 2012 00:16:55 -0700
Message-ID: <1338621416-22425-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1338621416-22425-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20916 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966256Ab2FBHRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Jun 2012 03:17:01 -0400
In-Reply-To: <1338621416-22425-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

This is another fixup where the data is not transfered into buffer
addressed by skb->data but into a page.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 95731c8..7483ca0 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4080,7 +4080,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				spin_lock_irqsave(&adapter->stats_lock,
 				                  irq_flags);
 				e1000_tbi_adjust_stats(hw, &adapter->stats,
-				                       length, skb->data);
+						       length, mapped);
 				spin_unlock_irqrestore(&adapter->stats_lock,
 				                       irq_flags);
 				length--;
-- 
1.7.10.2
