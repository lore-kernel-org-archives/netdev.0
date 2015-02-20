From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 2/7 linux-next] mISDN: replace current->state by set_current_state()
Date: Fri, 20 Feb 2015 19:12:52 +0100
Message-ID: <1424455977-21903-2-git-send-email-fabf@skynet.be>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be>
Cc: Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Fabian Frederick <fabf@skynet.be>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424455977-21903-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use helper function to access current->state.
Direct assignments are prone to races and therefore buggy.

Thanks to Peter Zijlstra for the exact definition of the problem.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/isdn/hardware/mISDN/hfcpci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 3c92780..ff48da6 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -1755,7 +1755,7 @@ init_card(struct hfc_pci *hc)
 		enable_hwirq(hc);
 		spin_unlock_irqrestore(&hc->lock, flags);
 		/* Timeout 80ms */
-		current->state = TASK_UNINTERRUPTIBLE;
+		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule_timeout((80 * HZ) / 1000);
 		printk(KERN_INFO "HFC PCI: IRQ %d count %d\n",
 		       hc->irq, hc->irqcnt);
-- 
2.1.0
