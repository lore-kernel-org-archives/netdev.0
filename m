From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 2/3] bna: Set Ring Param Fix
Date: Fri, 16 Sep 2011 18:06:47 -0700
Message-ID: <1316221608-21392-2-git-send-email-rmody@brocade.com>
References: <1316221608-21392-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:55775 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932145Ab1IQBH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 21:07:56 -0400
In-Reply-To: <1316221608-21392-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When Rx queue size is changed, queues are torn down and setup with the new queue
size. During this operation, clear promiscuous mode and restore the original
VLAN filter.

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 4842224..ac6b495 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -471,16 +471,17 @@ bnad_set_ringparam(struct net_device *netdev,
 			current_err = bnad_setup_rx(bnad, i);
 			if (current_err && !err)
 				err = current_err;
-			if (!err)
-				bnad_restore_vlans(bnad, i);
 		}
 
 		if (!err && bnad->rx_info[0].rx) {
 			/* restore rx configuration */
+			bnad_restore_vlans(bnad, 0);
 			bnad_enable_default_bcast(bnad);
 			spin_lock_irqsave(&bnad->bna_lock, flags);
 			bnad_mac_addr_set_locked(bnad, netdev->dev_addr);
 			spin_unlock_irqrestore(&bnad->bna_lock, flags);
+			bnad->cfg_flags &= ~(BNAD_CF_ALLMULTI |
+					     BNAD_CF_PROMISC);
 			bnad_set_rx_mode(netdev);
 		}
 	}
-- 
1.7.1
