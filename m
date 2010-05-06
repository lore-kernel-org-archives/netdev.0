From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH 8/8] tehuti: Remove unnecessary memset of netdev private data
Date: Thu,  6 May 2010 17:43:04 +0200
Message-ID: <1273160584-13387-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org, andy@greyhouse.net,
	Tobias Klauser <tklauser@distanz.ch>
To: baum@tehutinetworks.net, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:46991 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932146Ab0EFPnH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 11:43:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory for the private data is allocated using kzalloc in
alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
set it to 0 again.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/tehuti.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index e29f495..20ab161 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -2033,7 +2033,6 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/************** priv ****************/
 		priv = nic->priv[port] = netdev_priv(ndev);
 
-		memset(priv, 0, sizeof(struct bdx_priv));
 		priv->pBdxRegs = nic->regs + port * 0x8000;
 		priv->port = port;
 		priv->pdev = pdev;
-- 
1.6.3.3

