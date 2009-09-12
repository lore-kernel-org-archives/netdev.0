From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Make hw->ports the number of ports allocated
Date: Sat, 12 Sep 2009 12:19:23 +0900
Message-ID: <4AAB133B.8070900@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:42435 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbZILDXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 23:23:43 -0400
Received: by pxi27 with SMTP id 27so1212317pxi.15
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2009 20:23:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If allocation of the second ports fails, make sure that hw->ports
 is not 2 otherwise we'll crash trying to access the second port.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 018aa58..c17ee26 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4563,6 +4563,10 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 			free_netdev(dev1);
 		} else
 			sky2_show_addr(dev1);
+
+		/* couldn't allocate the second port */
+		if (!hw->dev[1])
+			--hw->ports;
 	}
 
 	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);
-- 
1.5.6.5

