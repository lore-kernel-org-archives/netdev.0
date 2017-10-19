From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net 3/7] net: aquantia: Fixed transient link up/down/up notification
Date: Thu, 19 Oct 2017 18:23:55 +0300
Message-ID: <b7e75d99d7fd1814dd6bc23c099280d4278f07f7.1508159232.git.igor.russkikh@aquantia.com>
References: <cover.1508159232.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0085.outbound.protection.outlook.com ([104.47.32.85]:56393
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751014AbdJSPYn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 11:24:43 -0400
In-Reply-To: <cover.1508159232.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When doing ifconfig down/up, driver did not reported carrier_off neither
in nic_stop nor in nic_start. That caused link to be visible as "up"
during couple of seconds immediately after "ifconfig up".

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Signed-off-by: Igor Russkikh <igor.russkikh@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 6b49dd6..9378b48 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -337,6 +337,7 @@ struct aq_nic_s *aq_nic_alloc_hot(struct net_device *ndev)
 	}
 	if (netif_running(ndev))
 		netif_tx_disable(ndev);
+	netif_carrier_off(self->ndev);
 
 	for (self->aq_vecs = 0; self->aq_vecs < self->aq_nic_cfg.vecs;
 		self->aq_vecs++) {
@@ -902,6 +903,7 @@ int aq_nic_stop(struct aq_nic_s *self)
 	unsigned int i = 0U;
 
 	netif_tx_disable(self->ndev);
+	netif_carrier_off(self->ndev);
 
 	del_timer_sync(&self->service_timer);
 
-- 
2.7.4
