From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 15/26] e100: reduce time under spinlock
Date: Tue, 29 Aug 2006 09:44:48 -0700
Message-ID: <20060829164448.6872.18583.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:45834 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965089AbWH2Qge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:34 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We're waiting for a write flush to finish before unlocking, which
is not needed. Release the spinlock after the write command.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index e12cc68..eb467f8 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -597,8 +597,8 @@ static void e100_enable_irq(struct nic *
 
 	spin_lock_irqsave(&nic->cmd_lock, flags);
 	writeb(irq_mask_none, &nic->csr->scb.cmd_hi);
-	e100_write_flush(nic);
 	spin_unlock_irqrestore(&nic->cmd_lock, flags);
+	e100_write_flush(nic);
 }
 
 static void e100_disable_irq(struct nic *nic)
@@ -607,8 +607,8 @@ static void e100_disable_irq(struct nic 
 
 	spin_lock_irqsave(&nic->cmd_lock, flags);
 	writeb(irq_mask_all, &nic->csr->scb.cmd_hi);
-	e100_write_flush(nic);
 	spin_unlock_irqrestore(&nic->cmd_lock, flags);
+	e100_write_flush(nic);
 }
 
 static void e100_hw_reset(struct nic *nic)



---
Auke Kok <auke-jan.h.kok@intel.com>
