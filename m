From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] ambassador: use setup_timer
Date: Sat, 11 Mar 2017 08:46:56 +0800
Message-ID: <964049df314453bb891ce71df7cd7a63540e6210.1489061130.git.geliangtang@gmail.com>
References: <3afa5498142ef68256023257dad37b9f8352e65e.1489060803.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Chas Williams <3chas3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34138 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933434AbdCKArP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 19:47:15 -0500
In-Reply-To: <3afa5498142ef68256023257dad37b9f8352e65e.1489060803.git.geliangtang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use setup_timer() instead of init_timer() to simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/atm/ambassador.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 4a61079..906705e 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -2267,9 +2267,8 @@ static int amb_probe(struct pci_dev *pci_dev,
 	dev->atm_dev->ci_range.vpi_bits = NUM_VPI_BITS;
 	dev->atm_dev->ci_range.vci_bits = NUM_VCI_BITS;
 
-	init_timer(&dev->housekeeping);
-	dev->housekeeping.function = do_housekeeping;
-	dev->housekeeping.data = (unsigned long) dev;
+	setup_timer(&dev->housekeeping, do_housekeeping,
+		    (unsigned long)dev);
 	mod_timer(&dev->housekeeping, jiffies);
 
 	// enable host interrupts
-- 
2.9.3
