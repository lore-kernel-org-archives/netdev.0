From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/4) dlci netdevice event handling
Date: Mon, 8 Sep 2003 14:39:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908143929.4a52fdee.shemminger@osdl.org>
References: <20030908141445.5a5c0d42.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030908141445.5a5c0d42.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

One more patch, found this in testing
 -- need to delete device from list when unregistered
because of callback.

diff -Nru a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
--- a/drivers/net/wan/dlci.c	Mon Sep  8 14:39:14 2003
+++ b/drivers/net/wan/dlci.c	Mon Sep  8 14:39:14 2003
@@ -520,6 +520,7 @@
 
 		list_for_each_entry(dlp, &dlci_devs, list) {
 			if (dlp->slave == dev) {
+				list_del(&dlp->list);
 				unregister_netdevice(dlp->master);
 				dev_put(dlp->slave);
 				break;
