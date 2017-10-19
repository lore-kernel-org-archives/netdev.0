From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net 5/7] net: aquantia: mmio unmap was not performed on driver removal
Date: Thu, 19 Oct 2017 18:23:57 +0300
Message-ID: <d579b09cc96ab0248d22af62d79f112b54d4edb2.1508159232.git.igor.russkikh@aquantia.com>
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
Received: from mail-sn1nam01on0073.outbound.protection.outlook.com ([104.47.32.73]:35136
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753401AbdJSPYz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 11:24:55 -0400
In-Reply-To: <cover.1508159232.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That may lead to mmio resource leakage.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Signed-off-by: Igor Russkikh <igor.russkikh@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c b/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
index 727f0a4..cadaa64 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
@@ -268,6 +268,9 @@ void aq_pci_func_free(struct aq_pci_func_s *self)
 		aq_nic_ndev_free(self->port[port]);
 	}
 
+	if (self->mmio)
+		iounmap(self->mmio);
+
 	kfree(self);
 
 err_exit:;
-- 
2.7.4
