From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net v2 2/6] net:ethernet:aquantia: Fix for number of RSS queues.
Date: Mon, 28 Aug 2017 21:52:09 +0300
Message-ID: <1dfc34c96f77f8c33c9b4bdf48ba6371c81e78c0.1503945861.git.pavel.belous@aquantia.com>
References: <cover.1503945861.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Igor Russkikh <Igor.Russkikh@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0067.outbound.protection.outlook.com ([104.47.32.67]:20407
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751341AbdH1SxI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 14:53:08 -0400
In-Reply-To: <cover.1503945861.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

The number of RSS queues should be not more than numbers of CPU.
Its does not make sense to increase perfomance, and also cause problems on
some motherboards.

Fixes: 94f6c9e4cdf6 ("net: ethernet: aquantia: Support for NIC-specific code")
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 08b7275..d6d8e70 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -103,6 +103,8 @@ int aq_nic_cfg_start(struct aq_nic_s *self)
 	else
 		cfg->vecs = 1U;
 
+	cfg->num_rss_queues = min(cfg->vecs, AQ_CFG_NUM_RSS_QUEUES_DEF);
+
 	cfg->irq_type = aq_pci_func_get_irq_type(self->aq_pci_func);
 
 	if ((cfg->irq_type == AQ_HW_IRQ_LEGACY) ||
-- 
2.7.4
