From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70] tulip/xircom initialization bug
Date: Wed, 4 Jun 2003 11:21:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030604112136.7b8e2cf4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

By inspection of device initialization code, this driver unregister's the net device
in the error path even though the register_netdevice never succeeded.

Compiles, but don't have the hardware.

diff -Nru a/drivers/net/tulip/xircom_tulip_cb.c b/drivers/net/tulip/xircom_tulip_cb.c
--- a/drivers/net/tulip/xircom_tulip_cb.c	Wed Jun  4 11:18:44 2003
+++ b/drivers/net/tulip/xircom_tulip_cb.c	Wed Jun  4 11:18:44 2003
@@ -648,7 +648,6 @@
 	pci_set_drvdata(pdev, NULL);
 	pci_release_regions(pdev);
 err_out_free_netdev:
-	unregister_netdev(dev);
 	kfree(dev);
 	return -ENODEV;
 }
