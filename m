From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 3/7] mfd: core: copy DMA mask and params from parent
Date: Tue, 13 Aug 2013 11:08:38 +0200
Message-ID: <1376384922-8519-5-git-send-email-b.spranger@linutronix.de>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Lee Jones <lee.jones@linaro.org>,
	Holger Dengler <dengler@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:48282 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755580Ab3HMJIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 05:08:53 -0400
In-Reply-To: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The child device intends to perform DMA operations then it needs a dma
mask and params set. This patches copies them from the parent device.

Cc: Samuel Ortiz <sameo@linux.intel.com>
Cc: Lee Jones <lee.jones@linaro.org>
Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
Signed-off-by: Holger Dengler <dengler@linutronix.de>
---
 drivers/mfd/mfd-core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/mfd/mfd-core.c b/drivers/mfd/mfd-core.c
index 7604f4e..f421586 100644
--- a/drivers/mfd/mfd-core.c
+++ b/drivers/mfd/mfd-core.c
@@ -96,6 +96,8 @@ static int mfd_add_device(struct device *parent, int id,
 
 	pdev->dev.parent = parent;
 	pdev->dev.type = &mfd_dev_type;
+	pdev->dev.dma_mask = parent->dma_mask;
+	pdev->dev.dma_parms = parent->dma_parms;
 
 	if (parent->of_node && cell->of_compatible) {
 		for_each_child_of_node(parent->of_node, np) {
-- 
1.8.4.rc2
