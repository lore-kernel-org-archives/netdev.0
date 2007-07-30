From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [git patches] net driver fixes
Date: Tue, 31 Jul 2007 04:27:32 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0707310425360.17287@enigma.security.iitk.ac.in>
References: <20070730212333.GA8049@havoc.gtf.org>
 <alpine.LFD.0.999.0707310349460.17287@enigma.security.iitk.ac.in>
 <46AE6861.50004@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Petko Manolov <petkan@users.sourceforge.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34684 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145AbXG3WpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 18:45:16 -0400
In-Reply-To: <46AE6861.50004@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 30 Jul 2007, Jeff Garzik wrote:

> true, we should just remove the dev==NULL check

Patch below:

[PATCH] nmclan_cs: Remove bogus (dev==NULL) check in mace_interrupt()

The (dev == NULL) check in drivers/net/pcmcia/nmclan_cs.c:mace_interrupt()
handler is always false, so let's remove it.

Signed-off-by: Satyam Sharma <satyam@infradead.org>

---

 drivers/net/pcmcia/nmclan_cs.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 73da611..3446be9 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -1000,12 +1000,6 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
   int status;
   int IntrCnt = MACE_MAX_IR_ITERATIONS;
 
-  if (dev == NULL) {
-    DEBUG(2, "mace_interrupt(): irq 0x%X for unknown device.\n",
-	  irq);
-    return IRQ_NONE;
-  }
-
   if (lp->tx_irq_disabled) {
     printk(
       (lp->tx_irq_disabled?
