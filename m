From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next v2 4/7] qlcnic: Stop traffic before performing loopback test
Date: Wed, 17 Apr 2013 13:05:56 -0400
Message-ID: <1366218359-17701-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1366218359-17701-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:18737 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S965712Ab3DQRaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 13:30:52 -0400
In-Reply-To: <1366218359-17701-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Before conducting loopback test by sending packets, driver should stop transmit
queue and turn off carrier.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index e07aea8..7d0ebae 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1566,6 +1566,12 @@ int qlcnic_83xx_loopback_test(struct net_device *netdev, u8 mode)
 		}
 	} while ((adapter->ahw->linkup && ahw->has_link_events) != 1);
 
+	/* Make sure carrier is off and queue is stopped during loopback */
+	if (netif_running(netdev)) {
+		netif_carrier_off(netdev);
+		netif_stop_queue(netdev);
+	}
+
 	ret = qlcnic_do_lb_test(adapter, mode);
 
 	qlcnic_83xx_clear_lb_mode(adapter, mode);
-- 
1.5.6
