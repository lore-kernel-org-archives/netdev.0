From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH -next] net: i40e: fix build, depends on CONFIGFS_FS
Date: Tue, 03 Mar 2015 11:35:38 -0800
Message-ID: <54F60D0A.6020903@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux NICS <linux.nics@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>

i40e uses configfs interfaces so it should depend on CONFIGFS_FS.

Fixes these build errors:

drivers/built-in.o: In function `i40e_cfgfs_group_make_item':
i40e_configfs.c:(.text+0x2fcdca): undefined reference to `config_item_init_type_name'
drivers/built-in.o: In function `i40e_configfs_init':
(.text+0x2fcee6): undefined reference to `config_group_init'
drivers/built-in.o: In function `i40e_configfs_init':
(.text+0x2fcf0c): undefined reference to `configfs_register_subsystem'
drivers/built-in.o: In function `i40e_configfs_exit':
(.text+0x2fcf71): undefined reference to `configfs_unregister_subsystem'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc:	Linux NICS <linux.nics@intel.com>
Cc:	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- linux-next-20150303.orig/drivers/net/ethernet/intel/Kconfig
+++ linux-next-20150303/drivers/net/ethernet/intel/Kconfig
@@ -256,6 +256,7 @@ config I40E
 	tristate "Intel(R) Ethernet Controller XL710 Family support"
 	select PTP_1588_CLOCK
 	depends on PCI
+	depends on CONFIGFS_FS
 	---help---
 	  This driver supports Intel(R) Ethernet Controller XL710 Family of
 	  devices.  For more information on how to identify your adapter, go
