From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 02/10] sky2: turn of workaround timer
Date: Wed, 11 Oct 2006 14:22:27 -0700
Message-ID: <20061011212310.313242974@osdl.org>
References: <20061011212225.941046083@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:59597 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422640AbWJKV12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 17:27:28 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-no-timer.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The workaround timer is not needed in most systems with proper IRQ
routing and by perodically waking up it adds to laptop power consumption.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2006-10-11 11:43:33.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-11 11:43:40.000000000 -0700
@@ -96,9 +96,9 @@
 module_param(disable_msi, int, 0);
 MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
 
-static int idle_timeout = 100;
+static int idle_timeout = 0;
 module_param(idle_timeout, int, 0);
-MODULE_PARM_DESC(idle_timeout, "Idle timeout workaround for lost interrupts (ms)");
+MODULE_PARM_DESC(idle_timeout, "Watchdog timer for lost interrupts (ms)");
 
 static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) },

--
Stephen Hemminger <shemminger@osdl.org>

