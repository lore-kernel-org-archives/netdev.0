From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH ] dynamic_debug: call __netdev_printk only for CONFIG_NET
Date: Thu, 1 Sep 2011 16:57:02 +0200
Message-ID: <201109011657.02407.arnd@arndb.de>
References: <cover.1313085588.git.jbaron@redhat.com> <5514795fe63ccfd4b3a80283ed04a526abe3c59d.1313085588.git.jbaron@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, joe@perches.com, jim.cromie@gmail.com,
	bvanassche@acm.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, aloisio.almeida@openbossa.org,
	netdev@vger.kernel.org
To: Jason Baron <jbaron@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:60977 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757808Ab1IAO5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 10:57:18 -0400
In-Reply-To: <5514795fe63ccfd4b3a80283ed04a526abe3c59d.1313085588.git.jbaron@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__netdev_printk is only defined when CONFIG_NET is set. Since we only need
__dynamic_netdev_dbg for network drivers, we can make it conditional on the
same Kconfig symbol.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
On Thursday 11 August 2011, Jason Baron wrote:
> 
> From: Jason Baron <jbaron@redhat.com>
> 
> Previously, if dynamic debug was enabled netdev_dbg() was using
> dynamic_dev_dbg() to print out the underlying msg. Fix this by making
> sure netdev_dbg() uses __netdev_printk().
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Jason Baron <jbaron@redhat.com>
> ---

--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -504,6 +504,7 @@ int __dynamic_dev_dbg(struct _ddebug *descriptor,
 }
 EXPORT_SYMBOL(__dynamic_dev_dbg);
 
+#ifdef CONFIG_NET
 int __dynamic_netdev_dbg(struct _ddebug *descriptor,
 		      const struct net_device *dev, const char *fmt, ...)
 {
@@ -527,6 +528,7 @@ int __dynamic_netdev_dbg(struct _ddebug *descriptor,
 	return res;
 }
 EXPORT_SYMBOL(__dynamic_netdev_dbg);
+#endif
 
 static __initdata char ddebug_setup_string[1024];
 static __init int ddebug_setup_query(char *str)
