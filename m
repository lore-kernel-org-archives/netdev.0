From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v3] be2net: log link status
Date: Thu, 30 Apr 2015 11:59:49 +0200
Message-ID: <1430387989-3552-1-git-send-email-ivecera@redhat.com>
References: <20150429.150125.1929181206333250804.davem@davemloft.net>
Cc: davem@davemloft.net, Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60709 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077AbbD3J7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 05:59:54 -0400
In-Reply-To: <20150429.150125.1929181206333250804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver unlike other drivers does not log link state changes. It's
better for an user when asynchronous link states are logged to the system
log.

v3: Changes from v2 discarded as "not necessary"

Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index fb0bc3c..e349131 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -662,6 +662,8 @@ void be_link_status_update(struct be_adapter *adapter, u8 link_status)
 		netif_carrier_on(netdev);
 	else
 		netif_carrier_off(netdev);
+
+	netdev_info(netdev, "Link is %s\n", link_status ? "Up" : "Down");
 }
 
 static void be_tx_stats_update(struct be_tx_obj *txo, struct sk_buff *skb)
-- 
2.0.5
