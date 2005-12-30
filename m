From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH] hostap: allow flashing firmware
Date: Fri, 30 Dec 2005 18:22:26 -0500
Message-ID: <1135984946.17805.21.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: hostap <hostap@shmoo.com>
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: NetDev <netdev@vger.kernel.org>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

Host AP driver has code to support writing firmware to non-volatile
memory, a.k.a. flash.  This code has been extensively tested when Host
AP was a standalone driver.

Add a configuration option to the kernel to allow enabling this
functionality.  Improve the description of the RAM download option. 
Mention cards that require it.  Remove obsolete scary comment.

Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 drivers/net/wireless/hostap/Kconfig         |   22 ++++++++++++++++++----
 drivers/net/wireless/hostap/hostap_config.h |   13 ++++---------
 2 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/hostap/Kconfig b/drivers/net/wireless/hostap/Kconfig
index 56f41c7..c8f6286 100644
--- a/drivers/net/wireless/hostap/Kconfig
+++ b/drivers/net/wireless/hostap/Kconfig
@@ -26,11 +26,25 @@ config HOSTAP_FIRMWARE
 	depends on HOSTAP
 	---help---
 	Configure Host AP driver to include support for firmware image
-	download. Current version supports only downloading to volatile, i.e.,
-	RAM memory. Flash upgrade is not yet supported.
+	download. This option by itself only enables downloading to the
+	volatile memory, i.e. the card RAM. This option is required to
+	support cards that don't have firmware in flash, such as D-Link
+	DWL-520 rev E and D-Link DWL-650 rev P.
+
+	Firmware image downloading needs a user space tool, prism2_srec.
+	It is available from http://hostap.epitest.fi/.
+
+config HOSTAP_FIRMWARE_NVRAM
+	bool "Support for non-volatile firmware download"
+	depends on HOSTAP_FIRMWARE
+	---help---
+	Allow Host AP driver to write firmware images to the non-volatile
+	card memory, i.e. flash memory that survives power cycling.
+	Enable this option if you want to be able to change card firmware
+	permanently.
 
-	Firmware image downloading needs user space tool, prism2_srec. It is
-	available from http://hostap.epitest.fi/.
+	Firmware image downloading needs a user space tool, prism2_srec.
+	It is available from http://hostap.epitest.fi/.
 
 config HOSTAP_PLX
 	tristate "Host AP driver for Prism2/2.5/3 in PLX9052 PCI adaptors"
diff --git a/drivers/net/wireless/hostap/hostap_config.h b/drivers/net/wireless/hostap/hostap_config.h
index 7ed3425..c090a5a 100644
--- a/drivers/net/wireless/hostap/hostap_config.h
+++ b/drivers/net/wireless/hostap/hostap_config.h
@@ -21,15 +21,10 @@
 #define PRISM2_DOWNLOAD_SUPPORT
 #endif
 
-#ifdef PRISM2_DOWNLOAD_SUPPORT
-/* Allow writing firmware images into flash, i.e., to non-volatile storage.
- * Before you enable this option, you should make absolutely sure that you are
- * using prism2_srec utility that comes with THIS version of the driver!
- * In addition, please note that it is possible to kill your card with
- * non-volatile download if you are using incorrect image. This feature has not
- * been fully tested, so please be careful with it. */
-/* #define PRISM2_NON_VOLATILE_DOWNLOAD */
-#endif /* PRISM2_DOWNLOAD_SUPPORT */
+/* Allow kernel configuration to enable non-volatile download support. */
+#ifdef CONFIG_HOSTAP_FIRMWARE_NVRAM
+#define PRISM2_NON_VOLATILE_DOWNLOAD
+#endif
 
 /* Save low-level I/O for debugging. This should not be enabled in normal use.
  */

-- 
Regards,
Pavel Roskin
