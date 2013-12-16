From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH v3 2/2] xen/pvhvm: Remove the xen_platform_pci int.
Date: Mon, 16 Dec 2013 10:04:10 -0500
Message-ID: <1387206250-13963-3-git-send-email-konrad.wilk@oracle.com>
References: <1387206250-13963-1-git-send-email-konrad.wilk@oracle.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: axboe@kernel.dk, stefano.stabellini@eu.citrix.com,
	ian.campbell@citrix.com, xen-devel@lists.xenproject.org,
	linux-kernel@vger.kernel.org, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, leosilva@linux.vnet.ibm.com,
	ashley@ashleylai.com, peterhuewe@gmx.de, mail@srajiv.net,
	tpmdd@selhorst.net, dmitry.torokhov@gmail.com, bhelgaas@google.com,
	plagnioj@jcrosoft.com, tomi.valkeinen@ti.com,
	tpmdd-devel@lists.sourceforge.net, linux-input@vger.kernel.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-fbdev@vger.kernel.org
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1387206250-13963-1-git-send-email-konrad.wilk@oracle.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since we have  xen_has_pv_devices,xen_has_pv_disk_devices,
xen_has_pv_nic_devices, and xen_has_pv_and_legacy_disk_devices
to figure out the different 'unplug' behaviors - lets
use those instead of this single int.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 arch/x86/xen/platform-pci-unplug.c | 5 ++---
 include/xen/platform_pci.h         | 2 --
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/arch/x86/xen/platform-pci-unplug.c b/arch/x86/xen/platform-pci-unplug.c
index ab84ac1..a826171 100644
--- a/arch/x86/xen/platform-pci-unplug.c
+++ b/arch/x86/xen/platform-pci-unplug.c
@@ -30,10 +30,9 @@
 #define XEN_PLATFORM_ERR_PROTOCOL -2
 #define XEN_PLATFORM_ERR_BLACKLIST -3
 
-/* store the value of xen_emul_unplug after the unplug is done */
-int xen_platform_pci_unplug;
-EXPORT_SYMBOL_GPL(xen_platform_pci_unplug);
 #ifdef CONFIG_XEN_PVHVM
+/* store the value of xen_emul_unplug after the unplug is done */
+static int xen_platform_pci_unplug;
 static int xen_emul_unplug;
 
 static int check_platform_magic(void)
diff --git a/include/xen/platform_pci.h b/include/xen/platform_pci.h
index b49eeab..5c52b55 100644
--- a/include/xen/platform_pci.h
+++ b/include/xen/platform_pci.h
@@ -46,8 +46,6 @@ static inline int xen_must_unplug_disks(void) {
 #endif
 }
 
-extern int xen_platform_pci_unplug;
-
 #if defined(CONFIG_XEN_PVHVM)
 extern bool xen_has_pv_devices(void);
 extern bool xen_has_pv_disk_devices(void);
-- 
1.8.3.1

