From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] netconsole: fix build when CONFIG_NETCONSOLE_DYNAMIC is
 turned on
Date: Mon, 20 Jun 2011 21:25:04 -0700
Message-ID: <20110620212504.e639ad5c.randy.dunlap@oracle.com>
References: <bug-37992-10286@https.bugzilla.kernel.org/>
	<20110620122835.444f16d7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	hilld@binarystorm.net
To: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:27766 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab1FUE1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 00:27:05 -0400
In-Reply-To: <20110620122835.444f16d7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

When NETCONSOLE_DYNAMIC=y and CONFIGFS_FS=m, there are build errors
in netconsole:

drivers/built-in.o: In function `drop_netconsole_target':
netconsole.c:(.text+0x1a100f): undefined reference to `config_item_put'
drivers/built-in.o: In function `make_netconsole_target':
netconsole.c:(.text+0x1a10b9): undefined reference to `config_item_init_type_name'
drivers/built-in.o: In function `write_msg':
netconsole.c:(.text+0x1a11a4): undefined reference to `config_item_get'
netconsole.c:(.text+0x1a1211): undefined reference to `config_item_put'
drivers/built-in.o: In function `netconsole_netdev_event':
netconsole.c:(.text+0x1a12cc): undefined reference to `config_item_put'
netconsole.c:(.text+0x1a12ec): undefined reference to `config_item_get'
netconsole.c:(.text+0x1a1366): undefined reference to `config_item_put'
drivers/built-in.o: In function `init_netconsole':
netconsole.c:(.init.text+0x953a): undefined reference to `config_group_init'
netconsole.c:(.init.text+0x9560): undefined reference to `configfs_register_subsystem'
drivers/built-in.o: In function `dynamic_netconsole_exit':
netconsole.c:(.exit.text+0x809): undefined reference to `configfs_unregister_subsystem'

so make NETCONSOLE_DYNAMIC require CONFIGFS_FS=y to fix the build errors.

This is one possible fix.
Fixes https://bugzilla.kernel.org/show_bug.cgi?id=37992

Reported-by: David Hill <hilld@binarystorm.net>
Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-30-rc3.orig/drivers/net/Kconfig
+++ lnx-30-rc3/drivers/net/Kconfig
@@ -3416,7 +3416,7 @@ config NETCONSOLE
 
 config NETCONSOLE_DYNAMIC
 	bool "Dynamic reconfiguration of logging targets"
-	depends on NETCONSOLE && SYSFS && CONFIGFS_FS
+	depends on NETCONSOLE && SYSFS && CONFIGFS_FS=y
 	help
 	  This option enables the ability to dynamically reconfigure target
 	  parameters (interface, IP addresses, port numbers, MAC addresses)
