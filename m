From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] e1000 -- handle register_netdev errors
Date: Thu, 15 Jan 2004 13:59:20 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115135920.75ab3f0b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeb Cramer <cramer@intel.com>, "Feldman, Scott"
 <scott.feldman@intel.com>,
        Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patch against 2.6.1, but probably applies to 2.4 as well.
E1000 driver was not handling failures of register_netdev

diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c	Thu Jan 15 13:59:07 2004
+++ b/drivers/net/e1000/e1000_main.c	Thu Jan 15 13:59:07 2004
@@ -508,7 +508,9 @@
 	INIT_WORK(&adapter->tx_timeout_task,
 		(void (*)(void *))e1000_tx_timeout_task, netdev);
 
-	register_netdev(netdev);
+	err = register_netdev(netdev);
+	if (err)
+		goto err_register;
 
 	/* we're going to reset, so assume we have no link for now */
 
@@ -553,6 +555,7 @@
 	cards_found++;
 	return 0;
 
+err_register:
 err_sw_init:
 err_eeprom:
 	iounmap(adapter->hw.hw_addr);
