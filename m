From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 7/8] staging: et131x: Fix ET_INTR_TXDMA_ISR register name typo
Date: Wed, 20 Aug 2014 23:17:57 +0100
Message-ID: <1408573078-9320-8-git-send-email-mark.einon@gmail.com>
References: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

We actually mean to clear the ET_INTR_TXDMA_ISR reg after handling
a completed transfer, not the ET_INTR_TXDMA_ERR reg, which should
get handled immediately after.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 drivers/staging/et131x/et131x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index df83ea3..bf9ac15 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -3891,7 +3891,7 @@ static void et131x_isr_handler(struct work_struct *work)
 	if (status & ET_INTR_RXDMA_XFR_DONE)
 		et131x_handle_recv_interrupt(adapter);
 
-	status &= ~(ET_INTR_TXDMA_ERR | ET_INTR_RXDMA_XFR_DONE);
+	status &= ~(ET_INTR_TXDMA_ISR | ET_INTR_RXDMA_XFR_DONE);
 
 	if (!status)
 		goto out;
-- 
2.1.0
