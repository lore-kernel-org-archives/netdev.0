From: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
Subject: [PATCH 1/4] block: xsysace: Don't use NO_IRQ
Date: Wed, 21 Dec 2011 15:32:09 +0100
Message-ID: <1324477932-19262-1-git-send-email-monstr@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ryan Mallon <rmallon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Drivers shouldn't use NO_IRQ. Microblaze and PPC
define NO_IRQ as 0 and this reference will be removed
in near future.

Signed-off-by: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
CC: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
CC: Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
CC: Ryan Mallon <rmallon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/block/xsysace.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/block/xsysace.c b/drivers/block/xsysace.c
index fb1975d..1a17e33 100644
--- a/drivers/block/xsysace.c
+++ b/drivers/block/xsysace.c
@@ -456,7 +456,7 @@ static inline void ace_fsm_yieldirq(struct ace_device *ace)
 {
 	dev_dbg(ace->dev, "ace_fsm_yieldirq()\n");
 
-	if (ace->irq == NO_IRQ)
+	if (!ace->irq)
 		/* No IRQ assigned, so need to poll */
 		tasklet_schedule(&ace->fsm_tasklet);
 	ace->fsm_continue_flag = 0;
@@ -1034,12 +1034,12 @@ static int __devinit ace_setup(struct ace_device *ace)
 		ACE_CTRL_DATABUFRDYIRQ | ACE_CTRL_ERRORIRQ);
 
 	/* Now we can hook up the irq handler */
-	if (ace->irq != NO_IRQ) {
+	if (ace->irq) {
 		rc = request_irq(ace->irq, ace_interrupt, 0, "systemace", ace);
 		if (rc) {
 			/* Failure - fall back to polled mode */
 			dev_err(ace->dev, "request_irq failed\n");
-			ace->irq = NO_IRQ;
+			ace->irq = 0;
 		}
 	}
 
@@ -1086,7 +1086,7 @@ static void __devexit ace_teardown(struct ace_device *ace)
 
 	tasklet_kill(&ace->fsm_tasklet);
 
-	if (ace->irq != NO_IRQ)
+	if (ace->irq)
 		free_irq(ace->irq, ace);
 
 	iounmap(ace->baseaddr);
@@ -1156,7 +1156,7 @@ static int __devinit ace_probe(struct platform_device *dev)
 	resource_size_t physaddr = 0;
 	int bus_width = ACE_BUS_WIDTH_16; /* FIXME: should not be hard coded */
 	u32 id = dev->id;
-	int irq = NO_IRQ;
+	int irq = 0;
 	int i;
 
 	dev_dbg(&dev->dev, "ace_probe(%p)\n", dev);
-- 
1.7.5.4
