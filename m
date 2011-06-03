From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH] qlcnic: Avoid double free of skb in tx path
Date: Fri,  3 Jun 2011 08:52:18 -0700
Message-ID: <1307116338-1686-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	sucheta.chakraborty@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:36456 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1753417Ab1FCP72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2011 11:59:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

buffer->skb should be marked NULL to avoid double free of the skb.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 3ab7d2c..0f6af5c 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2159,6 +2159,7 @@ qlcnic_unmap_buffers(struct pci_dev *pdev, struct sk_buff *skb,
 
 	nf = &pbuf->frag_array[0];
 	pci_unmap_single(pdev, nf->dma, skb_headlen(skb), PCI_DMA_TODEVICE);
+	pbuf->skb = NULL;
 }
 
 static inline void
-- 
1.7.4.1

