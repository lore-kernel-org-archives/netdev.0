From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 5/10] hostap: Fix procfs rmdir after ifname change
Date: Sat, 12 Mar 2005 16:32:12 -0800
Message-ID: <20050313003212.GF8253@jm.kir.nu>
References: <20050313001706.GA8253@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050313001706.GA8253@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixed /proc/net/hostap/wlan# removing to use name from the procfs
instead of from the netdevice. This allows the procfs entry be removed
nicely even if the network interface has been renamed.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_proc.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_proc.c	2005-03-12 16:10:40.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_proc.c	2005-03-12 16:10:55.000000000 -0800
@@ -456,8 +456,8 @@
 #ifndef PRISM2_NO_PROCFS_DEBUG
 		remove_proc_entry("debug", local->proc);
 #endif /* PRISM2_NO_PROCFS_DEBUG */
-		if (local->ddev != NULL && hostap_proc != NULL)
-			remove_proc_entry(local->ddev->name, hostap_proc);
+		if (hostap_proc != NULL)
+			remove_proc_entry(local->proc->name, hostap_proc);
 	}
 }
 

-- 
Jouni Malinen                                            PGP id EFC895FA
