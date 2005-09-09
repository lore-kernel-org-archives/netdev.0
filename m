From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 3/3] orinoco: Remove conditionals that are useless in the
 kernel
Date: Fri, 09 Sep 2005 18:46:07 -0400
Message-ID: <1126305967.16739.3.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

diff-tree 2f9196a9a825b97b2b9b3471da22682cf2720def (from ec36f4b4e7671a87861d06b5a86143c9e9152eaa)
Author: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Date:   Fri Sep 9 18:29:50 2005 -0400

    Remove conditionals that are useless in the kernel.
    
    We are not compiling the drivers against pcmcia-cs package.
    We are not embedding any firmware.

diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -14,9 +14,6 @@
 #define PFX DRIVER_NAME ": "
 
 #include <linux/config.h>
-#ifdef  __IN_PCMCIA_PACKAGE__
-#include <pcmcia/k_compat.h>
-#endif /* __IN_PCMCIA_PACKAGE__ */
 
 #include <linux/module.h>
 #include <linux/kernel.h>
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -22,9 +22,6 @@
 #define PFX DRIVER_NAME ": "
 
 #include <linux/config.h>
-#ifdef  __IN_PCMCIA_PACKAGE__
-#include <pcmcia/k_compat.h>
-#endif /* __IN_PCMCIA_PACKAGE__ */
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -38,6 +35,7 @@
 #include <linux/if_arp.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
+#include <linux/firmware.h>
 
 #include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
@@ -51,29 +49,10 @@
 
 #include "orinoco.h"
 
-/*
- * If SPECTRUM_FW_INCLUDED is defined, the firmware is hardcoded into
- * the driver.  Use get_symbol_fw script to generate spectrum_fw.h and
- * copy it to the same directory as spectrum_cs.c.
- *
- * If SPECTRUM_FW_INCLUDED is not defined, the firmware is loaded at the
- * runtime using hotplug.  Use the same get_symbol_fw script to generate
- * files symbol_sp24t_prim_fw symbol_sp24t_sec_fw, copy them to the
- * hotplug firmware directory (typically /usr/lib/hotplug/firmware) and
- * make sure that you have hotplug installed and enabled in the kernel.
- */
-/* #define SPECTRUM_FW_INCLUDED 1 */
-
-#ifdef SPECTRUM_FW_INCLUDED
-/* Header with the firmware */
-#include "spectrum_fw.h"
-#else	/* !SPECTRUM_FW_INCLUDED */
-#include <linux/firmware.h>
 static unsigned char *primsym;
 static unsigned char *secsym;
 static const char primary_fw_name[] = "symbol_sp24t_prim_fw";
 static const char secondary_fw_name[] = "symbol_sp24t_sec_fw";
-#endif	/* !SPECTRUM_FW_INCLUDED */
 
 /********************************************************************/
 /* Module stuff							    */
@@ -571,8 +550,6 @@ spectrum_dl_firmware(hermes_t *hw, dev_l
 {
 	int ret;
 	client_handle_t handle = link->handle;
-
-#ifndef SPECTRUM_FW_INCLUDED
 	const struct firmware *fw_entry;
 
 	if (request_firmware(&fw_entry, primary_fw_name,
@@ -592,7 +569,6 @@ spectrum_dl_firmware(hermes_t *hw, dev_l
 		       secondary_fw_name);
 		return -ENOENT;
 	}
-#endif
 
 	/* Load primary firmware */
 	ret = spectrum_dl_image(hw, link, primsym);

-- 
Regards,
Pavel Roskin



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
