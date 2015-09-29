From: Alexander Duyck <aduyck@mirantis.com>
Subject: [PATCH 3/3] fm10k: use napi_schedule_irqoff()
Date: Tue, 29 Sep 2015 15:19:56 -0700
Message-ID: <20150929221956.3388.23153.stgit@ahduyck-vm-fedora22>
References: <20150929215117.3388.48642.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35616 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965174AbbI2WT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:19:58 -0400
Received: by pacfv12 with SMTP id fv12so18392187pac.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:19:58 -0700 (PDT)
In-Reply-To: <20150929215117.3388.48642.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fm10k_msix_clean_rings function runs from hard interrupt context or
with interrupts already disabled in netpoll.

It can use napi_schedule_irqoff() instead of napi_schedule()

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 74be792f3f1b..5fbffbaefe32 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -846,7 +846,7 @@ static irqreturn_t fm10k_msix_clean_rings(int __always_unused irq, void *data)
 	struct fm10k_q_vector *q_vector = data;
 
 	if (q_vector->rx.count || q_vector->tx.count)
-		napi_schedule(&q_vector->napi);
+		napi_schedule_irqoff(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
