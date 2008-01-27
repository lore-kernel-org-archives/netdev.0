From: Mark Brown <broonie@sirena.org.uk>
Subject: [PATCH] natsemi: Update locking documentation
Date: Sun, 27 Jan 2008 13:58:11 +0000
Message-ID: <1201442291-13668-1-git-send-email-broonie@sirena.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mark Brown <broonie@sirena.org.uk>
To: Jeff Garzik <jeff@garzik.org>, Tim Hockin <thockin@hockin.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757571AbYA0N6u@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The documentation regarding synchronisation at the head of the natsemi
driver was badly bitrotted so replace it with a general statement about
the techniques used which is less likely to bitrot.

Also remove the note saying these chips are uncommon - it makes little
difference but they were used in a number of laptops and at least one mass
market PCI ethernet card.

Signed-off-by: Mark Brown <broonie@sirena.org.uk>
---
 drivers/net/natsemi.c |   18 ++----------------
 1 files changed, 2 insertions(+), 16 deletions(-)

diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index c329a4f..0a3e604 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -203,22 +203,8 @@ skbuff at an offset of "+2", 16-byte aligning the IP header.
 IIId. Synchronization
 
 Most operations are synchronized on the np->lock irq spinlock, except the
-performance critical codepaths:
-
-The rx process only runs in the interrupt handler. Access from outside
-the interrupt handler is only permitted after disable_irq().
-
-The rx process usually runs under the netif_tx_lock. If np->intr_tx_reap
-is set, then access is permitted under spin_lock_irq(&np->lock).
-
-Thus configuration functions that want to access everything must call
-	disable_irq(dev->irq);
-	netif_tx_lock_bh(dev);
-	spin_lock_irq(&np->lock);
-
-IV. Notes
-
-NatSemi PCI network controllers are very uncommon.
+recieve and transmit paths which are synchronised using a combination of
+hardware descriptor ownership, disabling interrupts and NAPI poll scheduling.
 
 IVb. References
 
-- 
1.5.3.8
