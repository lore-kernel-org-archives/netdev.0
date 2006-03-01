From: Denis Vlasenko <vda@ilport.com.ua>
Subject: [PATCH] wireless.git: update acxsm to 0.4.7
Date: Wed, 1 Mar 2006 15:58:14 +0200
Message-ID: <200603011558.14968.vda@ilport.com.ua>
References: <200602261710.33923.carlos@cmartin.tk> <200602271144.39346.carlos@cmartin.tk> <20060228013415.GD26559@tuxdriver.com>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_2haBEtfkNFFAN5G"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>,
	netdev@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <20060228013415.GD26559@tuxdriver.com>
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

--Boundary-00=_2haBEtfkNFFAN5G
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 28 February 2006 03:34, John W. Linville wrote:
> On Mon, Feb 27, 2006 at 11:44:38AM +0100, Carlos Mart=EDn wrote:
> > On Monday 27 February 2006 11:20, Denis Vlasenko wrote:
> > > > Comments are welcome and I'll split the patch if needed.
>=20
> Denis are you applying this patch to your tree?  If so, I'll rely on
> you to push it to me when you are ready.
>=20
> If not, then I will need Carlos to generate the diffs so that they
> can be applied to the top of the tree with -p1.
>=20
> 	http://linux.yyz.us/patch-format.html

Changelog:

[20060301] 0.4.7
* Carlos Martin <carlos@cmartin.tk>
  - splitted monolithic module into acx-common + acx-pci + acx-usb
    modules

[20060212] 0.4.6
* Carlos Martin <carlos@cmartin.tk>
  - Fix breakage of "Get rid of circular list of adev's"
  - Remove .owner =3D THIS_MODULE

[20060209] 0.4.5
* Get rid of circular list of adev's

[20060208]
* Change the acx_ioctl_{get,set}_encode functions to use
  the 80211 stack in the kernel, so they become mere wrappers.

[20060206]
* Register driver device ids to usb device table

[20060205] 0.4.4
* Andreas Mohr <andi@rhlx01.fht-esslingen.de>
  - implement much more flexible firmware statistics parsing
    (for /proc/driver/acx_wlanX_diag)
    This has the nice effect that we now get output for both the older
    TNETW1100 USB and TNETW1450.
    Since firmware statistics information has non-stable layout depending on
    firmware version, please report if you suspect any parsing mismatch!
    This improved version now uses 2kB more driver space, unfortunately.
  - use "% 8" modulo instead of more complicated "% 5" calculation

Signed-off-by: Denis Vlasenko <vda@ilport.com.ua>
=2D-
vda

--Boundary-00=_2haBEtfkNFFAN5G
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="acx_cmn.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="acx_cmn.patch"

diff -urpN wireless-2.6.git/drivers/net/wireless/Makefile wireless-2.6.git.acx/drivers/net/wireless/Makefile
--- wireless-2.6.git/drivers/net/wireless/Makefile	Wed Mar  1 07:56:14 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/Makefile	Wed Mar  1 12:01:19 2006
@@ -37,7 +37,8 @@ obj-$(CONFIG_PRISM54_USB)	+= prism54usb/
 
 obj-$(CONFIG_HOSTAP)		+= hostap/
 obj-$(CONFIG_BCM43XX)		+= bcm43xx/
-obj-$(CONFIG_ACX)		+= tiacx/
+obj-$(CONFIG_ACX_PCI)		+= tiacx/
+obj-$(CONFIG_ACX_USB)		+= tiacx/
 
 # 16-bit wireless PCMCIA client drivers
 obj-$(CONFIG_PCMCIA_RAYCS)	+= ray_cs.o
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/Changelog wireless-2.6.git.acx/drivers/net/wireless/tiacx/Changelog
--- wireless-2.6.git/drivers/net/wireless/tiacx/Changelog	Wed Mar  1 07:56:14 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/Changelog	Wed Mar  1 15:43:45 2006
@@ -70,6 +70,37 @@ TODO: from Efthym <efthym@gmx.net>:
 13:13:32 wlan0: tx error 0x20, buf 05!
 13:13:32 wlan0: tx error 0x20, buf 06!
 
+[20060301] 0.4.7
+* Carlos Martin <carlos@cmartin.tk>
+  - splitted monolithic module into acx-common + acx-pci + acx-usb
+    modules
+
+[20060212] 0.4.6
+* Carlos Martin <carlos@cmartin.tk>
+  - Fix breakage of "Get rid of circular list of adev's"
+  - Remove .owner = THIS_MODULE
+
+[20060209] 0.4.5
+* Get rid of circular list of adev's
+
+[20060208]
+* Change the acx_ioctl_{get,set}_encode functions to use
+  the 80211 stack in the kernel, so they become mere wrappers.
+
+[20060206]
+* Register driver device ids to usb device table
+
+[20060205] 0.4.4
+* Andreas Mohr <andi@rhlx01.fht-esslingen.de>
+  - implement much more flexible firmware statistics parsing
+    (for /proc/driver/acx_wlanX_diag)
+    This has the nice effect that we now get output for both the older
+    TNETW1100 USB and TNETW1450.
+    Since firmware statistics information has non-stable layout depending on
+    firmware version, please report if you suspect any parsing mismatch!
+    This improved version now uses 2kB more driver space, unfortunately.
+  - use "% 8" modulo instead of more complicated "% 5" calculation
+
 [20060203] 0.4.3
 * merge from acx 0.3.32
 
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/Kconfig wireless-2.6.git.acx/drivers/net/wireless/tiacx/Kconfig
--- wireless-2.6.git/drivers/net/wireless/tiacx/Kconfig	Wed Mar  1 07:56:14 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/Kconfig	Wed Mar  1 12:05:04 2006
@@ -1,20 +1,14 @@
-config ACX
-	tristate
+config ACX_PCI
+	tristate "TI acx100/acx111 802.11b/g PCI"
+	depends on NET_RADIO && EXPERIMENTAL && PCI
 	select FW_LOADER
 	select IEEE80211
 	select IEEE80211_SOFTMAC
-
-config ACX_PCI
-	tristate "TI acx100/acx111 802.11b/g wireless PCI chipsets"
-	depends on NET_RADIO && EXPERIMENTAL && PCI && (USB || ACX_USB=n)
-	select ACX
-	select ACX_PCI_BOOL
 	---help---
-	Include support for PCI and CardBus 802.11b/g wireless cards
-	based on Texas Instruments acx100 and acx111 chipsets.
+	A driver for 802.11b/g wireless cards based on
+	Texas Instruments acx100 and acx111 chipsets.
 
-	This driver supports Host AP mode that allows
-	your computer to act as an IEEE 802.11 access point.
+	This is the PCI code.
 
 	acx chipsets need their firmware loaded at startup.
 	You will need to provide a firmware image via hotplug.
@@ -39,20 +33,20 @@ config ACX_PCI
 	Firmware files are not covered by GPL and are not distributed
 	with this driver for legal reasons.
 
-config ACX_PCI_BOOL
-	bool
+	Texas Instruments did not take part in development of this driver
+	in any way, shape or form.
 
 config ACX_USB
-	tristate "TI acx100/acx111 802.11b/g USB wireless chipsets"
+	tristate "TI acx100/acx111 802.11b/g USB"
 	depends on NET_RADIO && EXPERIMENTAL && USB
-	select ACX
-	select ACX_USB_BOOL
+	select FW_LOADER
+	select IEEE80211
+	select IEEE80211_SOFTMAC
 	---help---
-	Include support for USB 802.11b/g wireless cards
-	based on Texas Instruments acx100 and acx111 chipsets.
+	A driver for 802.11b/g wireless cards based on
+	Texas Instruments acx100 and acx111 chipsets.
 
-	This driver supports Host AP mode that allows
-	your computer to act as an IEEE 802.11 access point.
+	This is the USB code.
 
 	There is only one currently known device in this category,
 	D-Link DWL-120+, but newer devices seem to be on the horizon.
@@ -66,5 +60,6 @@ config ACX_USB
 	Firmware files are not covered by GPL and are not distributed
 	with this driver for legal reasons.
 
-config ACX_USB_BOOL
-	bool
+	Texas Instruments did not take part in development of this driver
+	in any way, shape or form.
+
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/Makefile wireless-2.6.git.acx/drivers/net/wireless/tiacx/Makefile
--- wireless-2.6.git/drivers/net/wireless/tiacx/Makefile	Wed Mar  1 07:56:14 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/Makefile	Wed Mar  1 12:05:04 2006
@@ -1,6 +1,6 @@
-obj-$(CONFIG_ACX) += acx.o
+acx-common-y := wlan.o ioctl.o common.o
+acx-usb-y := usb.o
+acx-pci-y := pci.o
 
-acx-obj-$(CONFIG_ACX_PCI_BOOL) += pci.o
-acx-obj-$(CONFIG_ACX_USB_BOOL) += usb.o
-
-acx-objs := wlan.o ioctl.o common.o $(acx-obj-y)
+obj-$(CONFIG_ACX_PCI) += acx-common.o acx-pci.o
+obj-$(CONFIG_ACX_USB) += acx-common.o acx-usb.o
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/README wireless-2.6.git.acx/drivers/net/wireless/tiacx/README
--- wireless-2.6.git/drivers/net/wireless/tiacx/README	Wed Mar  1 07:56:14 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/README	Wed Mar  1 12:27:48 2006
@@ -1,21 +1,16 @@
-*** Not run tested. Almost certainly won't work. Lots of things are TODO. ***
+*** Barely works. Lots of things are TODO. ***
 
 This tarball contains a port of acx driver to ieee80211softmac
 stack. Broadcom 43xx driver was used as an example.
 See http://bcm43xx.berlios.de/,
 ftp://ftp.berlios.de/pub/bcm43xx/snapshots/
 
-Latest softmac source is in softmac-snapshot/ and net/
-is a symlink to softmac-snapshot/include/net/.
-softmac-snapshot/ is to be replaced regularly with newer
-snapshots from http://softmac.sipsolutions.net/SoftMAC.
-
 grep for '//SM' to see the code added to standalone acx driver code.
 
 Contact:
 netdev@vger.kernel.org
 acx100-devel@lists.sourceforge.net
-softmac-dev@sipsolutions.net 
+softmac-dev@sipsolutions.net
 
 Bug reports:
 
@@ -45,4 +40,22 @@ radio module). For example, my firmware 
 Alternatively, I may remove it and use pair of files 'tiacx111' and
 'tiacx111r16' instead.
 USB driver:
-image is named 'tiacx100usb'
+image is named 'tiacxNNNusbcMM'
+
+Build instructions:
+
+You need to have git and cogito installed.
+
+# Get initial wireless-2.6.git tree (large download - >300MB)
+cg-clone rsync://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git wireless-2.6.git
+cd wireless-2.6.git
+# Get a branch
+cg-branch-add r-softmac 'rsync://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git#softmac'
+cg-fetch r-softmac
+# Switch to it (make it current)
+git-checkout r-softmac
+# Pull updates from remote master tree
+cg-update r-softmac
+
+You will have a complete Linux kernel in wireless-2.6.git/.
+Replace drivers/net/wireless/tiacx/* by files from this tarball.
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/acx_config.h wireless-2.6.git.acx/drivers/net/wireless/tiacx/acx_config.h
--- wireless-2.6.git/drivers/net/wireless/tiacx/acx_config.h	Wed Mar  1 07:56:14 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/acx_config.h	Wed Mar  1 15:43:59 2006
@@ -1,4 +1,4 @@
-#define ACX_RELEASE "v0.4.3"
+#define ACX_RELEASE "v0.4.7"
 
 /* set to 0 if you don't want any debugging code to be compiled in */
 /* set to 1 if you want some debugging */
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/acx_func.h wireless-2.6.git.acx/drivers/net/wireless/tiacx/acx_func.h
--- wireless-2.6.git/drivers/net/wireless/tiacx/acx_func.h	Wed Mar  1 07:56:14 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/acx_func.h	Wed Mar  1 12:31:08 2006
@@ -66,27 +66,27 @@
 */
 #if ACX_DEBUG > 1
 
-void log_fn_enter(const char *funcname);
-void log_fn_exit(const char *funcname);
-void log_fn_exit_v(const char *funcname, int v);
+void acx_log_fn_enter(const char *funcname);
+void acx_log_fn_exit(const char *funcname);
+void acx_log_fn_exit_v(const char *funcname, int v);
 
 #define FN_ENTER \
 	do { \
 		if (unlikely(acx_debug & L_FUNC)) { \
-			log_fn_enter(__func__); \
+			acx_log_fn_enter(__func__); \
 		} \
 	} while (0)
 
 #define FN_EXIT1(v) \
 	do { \
 		if (unlikely(acx_debug & L_FUNC)) { \
-			log_fn_exit_v(__func__, v); \
+			acx_log_fn_exit_v(__func__, v); \
 		} \
 	} while (0)
 #define FN_EXIT0 \
 	do { \
 		if (unlikely(acx_debug & L_FUNC)) { \
-			log_fn_exit(__func__); \
+			acx_log_fn_exit(__func__); \
 		} \
 	} while (0)
 
@@ -257,7 +257,7 @@ has_only_one_bit(u16 v)
 **		but may be run under lock
 **
 ** A small number of local helpers do not have acx_[eisl]_ prefix.
-** They are always close to caller and are to be revieved locally.
+** They are always close to caller and are to be reviewed locally.
 **
 ** Theory of operation:
 **
@@ -417,44 +417,29 @@ void acx_set_status(acx_device_t *adev, 
 #if ACX_DEBUG
 
 /* We want to log cmd names */
-int acxpci_s_issue_cmd_timeo_debug(acx_device_t *adev, unsigned cmd, void *param, unsigned len, unsigned timeout, const char* cmdstr);
-int acxusb_s_issue_cmd_timeo_debug(acx_device_t *adev, unsigned cmd, void *param, unsigned len, unsigned timeout, const char* cmdstr);
-static inline int
-acx_s_issue_cmd_timeo_debug(acx_device_t *adev, unsigned cmd, void *param, unsigned len, unsigned timeout, const char* cmdstr)
-{
-	if (IS_PCI(adev))
-		return acxpci_s_issue_cmd_timeo_debug(adev, cmd, param, len, timeout, cmdstr);
-	return acxusb_s_issue_cmd_timeo_debug(adev, cmd, param, len, timeout, cmdstr);
-}
-#define acx_s_issue_cmd(adev,cmd,param,len) \
-	acx_s_issue_cmd_timeo_debug(adev,cmd,param,len,ACX_CMD_TIMEOUT_DEFAULT,#cmd)
-#define acx_s_issue_cmd_timeo(adev,cmd,param,len,timeo) \
-	acx_s_issue_cmd_timeo_debug(adev,cmd,param,len,timeo,#cmd)
+
+#define acx_s_issue_cmd(adev, cmd, param, len) \
+	(adev)->ops.issue_cmd(adev, cmd, param, len, ACX_CMD_TIMEOUT_DEFAULT, #cmd)
+
+#define acx_s_issue_cmd_timeo(adev,cmd,param,len, timeout)			\
+	(adev)->ops.issue_cmd(adev, cmd, param, len, timeout, #cmd)
+
 int acx_s_configure_debug(acx_device_t *adev, void *pdr, int type, const char* str);
 #define acx_s_configure(adev,pdr,type) \
 	acx_s_configure_debug(adev,pdr,type,#type)
+
 int acx_s_interrogate_debug(acx_device_t *adev, void *pdr, int type, const char* str);
 #define acx_s_interrogate(adev,pdr,type) \
 	acx_s_interrogate_debug(adev,pdr,type,#type)
 
 #else
 
-int acxpci_s_issue_cmd_timeo(acx_device_t *adev, unsigned cmd, void *param, unsigned len, unsigned timeout);
-int acxusb_s_issue_cmd_timeo(acx_device_t *adev, unsigned cmd, void *param, unsigned len, unsigned timeout);
-static inline int
-acx_s_issue_cmd_timeo(acx_device_t *adev, unsigned cmd,	void *param, unsigned len, unsigned timeout)
-{
-	if (IS_PCI(adev))
-		return acxpci_s_issue_cmd_timeo(adev, cmd, param, len, timeout);
-	return acxusb_s_issue_cmd_timeo(adev, cmd, param, len, timeout);
-}
-static inline int
-acx_s_issue_cmd(acx_device_t *adev, unsigned cmd, void *param, unsigned len)
-{
-	if (IS_PCI(adev))
-		return acxpci_s_issue_cmd_timeo(adev, cmd, param, len, ACX_CMD_TIMEOUT_DEFAULT);
-	return acxusb_s_issue_cmd_timeo(adev, cmd, param, len, ACX_CMD_TIMEOUT_DEFAULT);
-}
+#define acx_s_issue_cmd(adev, cmd, param, len) \
+	(adev)->ops.issue_cmd(adev, cmd, param, len, ACX_CMD_TIMEOUT_DEFAULT)
+
+#define acx_s_issue_cmd_timeo(adev, cmd, param, len, timeout)			\
+	(adev)->ops.issue_cmd(adev, cmd, param, len, timeout)
+
 int acx_s_configure(acx_device_t *adev, void *pdr, int type);
 int acx_s_interrogate(acx_device_t *adev, void *pdr, int type);
 
@@ -503,64 +488,23 @@ int acxpci_s_upload_radio(acx_device_t *
 /***********************************************************************
 ** Unsorted yet :)
 */
-int acxpci_s_read_phy_reg(acx_device_t *adev, u32 reg, u8 *charbuf);
-int acxusb_s_read_phy_reg(acx_device_t *adev, u32 reg, u8 *charbuf);
-static inline int
-acx_s_read_phy_reg(acx_device_t *adev, u32 reg, u8 *charbuf)
-{
-	if (IS_PCI(adev))
-		return acxpci_s_read_phy_reg(adev, reg, charbuf);
-	return acxusb_s_read_phy_reg(adev, reg, charbuf);
-}
+#define acx_s_read_phy_reg(adev, reg, charbuf) \
+	(adev)->ops.read_phy_reg(adev, reg, charbuf)
 
-int acxpci_s_write_phy_reg(acx_device_t *adev, u32 reg, u8 value);
-int acxusb_s_write_phy_reg(acx_device_t *adev, u32 reg, u8 value);
-static inline int
-acx_s_write_phy_reg(acx_device_t *adev, u32 reg, u8 value)
-{
-	if (IS_PCI(adev))
-		return acxpci_s_write_phy_reg(adev, reg, value);
-	return acxusb_s_write_phy_reg(adev, reg, value);
-}
+#define acx_s_write_phy_reg(adev, reg, value) \
+	(adev)->ops.write_phy_reg(adev, reg, value)
 
-tx_t* acxpci_l_alloc_tx(acx_device_t *adev);
-tx_t* acxusb_l_alloc_tx(acx_device_t *adev);
-static inline tx_t*
-acx_l_alloc_tx(acx_device_t *adev)
-{
-	if (IS_PCI(adev))
-		return acxpci_l_alloc_tx(adev);
-	return acxusb_l_alloc_tx(adev);
-}
+#define acx_l_alloc_tx(adev) \
+	(adev)->ops.alloc_tx(adev)
 
-void acxusb_l_dealloc_tx(tx_t *tx_opaque);
-static inline void
-acx_l_dealloc_tx(acx_device_t *adev, tx_t *tx_opaque)
-{
-	if (IS_USB(adev))
-		acxusb_l_dealloc_tx(tx_opaque);
-}
+#define acx_l_dealloc_tx(adev, tx_opaque) \
+	(adev)->ops.dealloc_tx(tx_opaque)
 
-void* acxpci_l_get_txbuf(acx_device_t *adev, tx_t *tx_opaque);
-void* acxusb_l_get_txbuf(acx_device_t *adev, tx_t *tx_opaque);
-static inline void*
-acx_l_get_txbuf(acx_device_t *adev, tx_t *tx_opaque)
-{
-	if (IS_PCI(adev))
-		return acxpci_l_get_txbuf(adev, tx_opaque);
-	return acxusb_l_get_txbuf(adev, tx_opaque);
-}
+#define acx_l_get_txbuf(adev, tx_opaque) \
+	(adev)->ops.get_txbuf(adev, tx_opaque)
 
-void acxpci_l_tx_data(acx_device_t *adev, tx_t *tx_opaque, int len);
-void acxusb_l_tx_data(acx_device_t *adev, tx_t *tx_opaque, int len);
-static inline void
-acx_l_tx_data(acx_device_t *adev, tx_t *tx_opaque, int len)
-{
-	if (IS_PCI(adev))
-		acxpci_l_tx_data(adev, tx_opaque, len);
-	else
-		acxusb_l_tx_data(adev, tx_opaque, len);
-}
+#define acx_l_tx_data(adev, tx_opaque, len) \
+	(adev)->ops.tx_data(adev, tx_opaque, len)
 
 static inline wlan_hdr_t*
 acx_get_wlan_hdr(acx_device_t *adev, const rxbuffer_t *rxbuf)
@@ -637,6 +581,9 @@ void acx_display_hardware_details(acx_de
 int acx_e_change_mtu(struct net_device *ndev, int mtu);
 struct net_device_stats* acx_e_get_stats(struct net_device *ndev);
 struct iw_statistics* acx_e_get_wireless_stats(struct net_device *ndev);
+
+int acx100_s_create_dma_regions(acx_device_t *);
+int acx111_s_create_dma_regions(acx_device_t *);
 
 int __init acxpci_e_init_module(void);
 int __init acxusb_e_init_module(void);
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/acx_struct.h wireless-2.6.git.acx/drivers/net/wireless/tiacx/acx_struct.h
--- wireless-2.6.git/drivers/net/wireless/tiacx/acx_struct.h	Wed Mar  1 07:56:14 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/acx_struct.h	Wed Mar  1 12:05:04 2006
@@ -87,6 +87,31 @@ enum { acx_debug = 0 };
 #define SCHEDULE_WORK schedule_work
 #define FLUSH_SCHEDULED_WORK flush_scheduled_work
 
+/***********************************************************************
+** Chip-specific functions get set here.
+*/
+
+struct acx_ops {
+	int (*create_dma_regions)(acx_device_t *);
+	void (*delete_dma_regions)(acx_device_t *);
+
+#if ACX_DEBUG
+	int (*issue_cmd)(acx_device_t *adev, unsigned cmd, void *param,
+			 unsigned len, unsigned cmd_timeout, const char *cmdstr);
+#else
+	int (*issue_cmd)(acx_device_t *adev, unsigned cmd, void *param,
+			 unsigned len, unsigned cmd_timeout);
+#endif /* ACX_DEBUG */
+	tx_t* (*alloc_tx)(acx_device_t *adev);
+	void (*dealloc_tx)(tx_t *tx_opaque);
+
+	void* (*get_txbuf)(acx_device_t *adev, tx_t *tx_opaque);
+	void (*tx_data)(acx_device_t *adev, tx_t *tx_opaque, int len);
+
+	int (*write_phy_reg)(acx_device_t *adev, u32 reg, u8 value);
+	int (*read_phy_reg)(acx_device_t *adev, u32 reg, u8 *charbuf);
+};
+
 
 /***********************************************************************
 ** Constants
@@ -105,8 +130,8 @@ enum { acx_debug = 0 };
 #define DEVTYPE_PCI		0
 #define DEVTYPE_USB		1
 
-#if defined(CONFIG_ACX_PCI_BOOL)
- #if !defined(CONFIG_ACX_USB_BOOL)
+#if defined(CONFIG_ACX_PCI)
+ #if !defined(CONFIG_ACX_USB)
   #define IS_PCI(adev)	1
  #else
   #define IS_PCI(adev)	((adev)->dev_type == DEVTYPE_PCI)
@@ -115,8 +140,8 @@ enum { acx_debug = 0 };
  #define IS_PCI(adev)	0
 #endif
 
-#if defined(CONFIG_ACX_USB_BOOL)
- #if !defined(CONFIG_ACX_PCI_BOOL)
+#if defined(CONFIG_ACX_USB)
+ #if !defined(CONFIG_ACX_PCI)
   #define IS_USB(adev)	1
  #else
   #define IS_USB(adev)	((adev)->dev_type == DEVTYPE_USB)
@@ -578,21 +603,34 @@ typedef struct rxbuffer {
 
 
 /*--- Firmware statistics ----------------------------------------------------*/
-typedef struct fw_stats {
-	u32	val0x0 ACX_PACKED;		/* hdr; */
+
+/* define a random 100 bytes more to catch firmware versions which
+ * provide a bigger struct */
+#define FW_STATS_FUTURE_EXTENSION	100
+
+typedef struct fw_stats_tx {
 	u32	tx_desc_of ACX_PACKED;
+} fw_stats_tx_t;
+
+typedef struct fw_stats_rx {
 	u32	rx_oom ACX_PACKED;
 	u32	rx_hdr_of ACX_PACKED;
-	u32	rx_hdr_use_next ACX_PACKED;
+	u32	rx_hw_stuck ACX_PACKED; /* old: u32	rx_hdr_use_next */
 	u32	rx_dropped_frame ACX_PACKED;
 	u32	rx_frame_ptr_err ACX_PACKED;
 	u32	rx_xfr_hint_trig ACX_PACKED;
+	u32	rx_aci_events ACX_PACKED; /* later versions only */
+	u32	rx_aci_resets ACX_PACKED; /* later versions only */
+} fw_stats_rx_t;
 
+typedef struct fw_stats_dma {
 	u32	rx_dma_req ACX_PACKED;
 	u32	rx_dma_err ACX_PACKED;
 	u32	tx_dma_req ACX_PACKED;
 	u32	tx_dma_err ACX_PACKED;
+} fw_stats_dma_t;
 
+typedef struct fw_stats_irq {
 	u32	cmd_cplt ACX_PACKED;
 	u32	fiq ACX_PACKED;
 	u32	rx_hdrs ACX_PACKED;
@@ -600,23 +638,79 @@ typedef struct fw_stats {
 	u32	rx_mem_of ACX_PACKED;
 	u32	rx_rdys ACX_PACKED;
 	u32	irqs ACX_PACKED;
-	u32	acx_trans_procs ACX_PACKED;
+	u32	tx_procs ACX_PACKED;
 	u32	decrypt_done ACX_PACKED;
 	u32	dma_0_done ACX_PACKED;
 	u32	dma_1_done ACX_PACKED;
 	u32	tx_exch_complet ACX_PACKED;
 	u32	commands ACX_PACKED;
-	u32	acx_rx_procs ACX_PACKED;
+	u32	rx_procs ACX_PACKED;
 	u32	hw_pm_mode_changes ACX_PACKED;
 	u32	host_acks ACX_PACKED;
 	u32	pci_pm ACX_PACKED;
 	u32	acm_wakeups ACX_PACKED;
+} fw_stats_irq_t;
 
+typedef struct fw_stats_wep {
 	u32	wep_key_count ACX_PACKED;
 	u32	wep_default_key_count ACX_PACKED;
 	u32	dot11_def_key_mib ACX_PACKED;
 	u32	wep_key_not_found ACX_PACKED;
 	u32	wep_decrypt_fail ACX_PACKED;
+	u32	wep_pkt_decrypt ACX_PACKED;
+	u32	wep_decrypt_irqs ACX_PACKED;
+} fw_stats_wep_t;
+
+typedef struct fw_stats_pwr {
+	u32	tx_start_ctr ACX_PACKED;
+	u32	no_ps_tx_too_short ACX_PACKED;
+	u32	rx_start_ctr ACX_PACKED;
+	u32	no_ps_rx_too_short ACX_PACKED;
+	u32	lppd_started ACX_PACKED;
+	u32	no_lppd_too_noisy ACX_PACKED;
+	u32	no_lppd_too_short ACX_PACKED;
+	u32	no_lppd_matching_frame ACX_PACKED;
+} fw_stats_pwr_t;
+
+typedef struct fw_stats_mic {
+	u32 mic_rx_pkts ACX_PACKED;
+	u32 mic_calc_fail ACX_PACKED;
+} fw_stats_mic_t;
+
+typedef struct fw_stats_aes {
+	u32 aes_enc_fail ACX_PACKED;
+	u32 aes_dec_fail ACX_PACKED;
+	u32 aes_enc_pkts ACX_PACKED;
+	u32 aes_dec_pkts ACX_PACKED;
+	u32 aes_enc_irq ACX_PACKED;
+	u32 aes_dec_irq ACX_PACKED;
+} fw_stats_aes_t;
+
+typedef struct fw_stats_event {
+	u32 heartbeat ACX_PACKED;
+	u32 calibration ACX_PACKED;
+	u32 rx_mismatch ACX_PACKED;
+	u32 rx_mem_empty ACX_PACKED;
+	u32 rx_pool ACX_PACKED;
+	u32 oom_late ACX_PACKED;
+	u32 phy_tx_err ACX_PACKED;
+	u32 tx_stuck ACX_PACKED;
+} fw_stats_event_t;
+
+/* mainly for size calculation only */
+typedef struct fw_stats {
+	u16			type;
+	u16			len;
+	fw_stats_tx_t		tx;
+	fw_stats_rx_t		rx;
+	fw_stats_dma_t		dma;
+	fw_stats_irq_t		irq;
+	fw_stats_wep_t		wep;
+	fw_stats_pwr_t		pwr;
+	fw_stats_mic_t		mic;
+	fw_stats_aes_t		aes;
+	fw_stats_event_t	evt;
+	u8			_padding[FW_STATS_FUTURE_EXTENSION];
 } fw_stats_t;
 
 /* Firmware version struct */
@@ -1122,14 +1216,12 @@ struct acx_device {
 	unsigned long		lock_time;
 #endif
 
-	/*** Device chain ***/
-	struct acx_device	*next;		/* link for list of devices */
-
 	/*** Linux network device ***/
 	struct net_device	*ndev;		/* pointer to linux netdevice */
-	struct net_device	*prev_nd;	/* FIXME: We should not chain via our
-						 * private struct acx_device _and_
-						 * the struct net_device */
+
+	/* Chip-specific functions */
+	struct acx_ops		ops;
+
 	/*** Device statistics ***/
 	struct net_device_stats	stats;		/* net device statistics */
 #ifdef WIRELESS_EXT
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/common.c wireless-2.6.git.acx/drivers/net/wireless/tiacx/common.c
--- wireless-2.6.git/drivers/net/wireless/tiacx/common.c	Wed Mar  1 07:56:14 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/common.c	Wed Mar  1 12:31:34 2006
@@ -84,6 +84,7 @@ static int acx_l_transmit_assoc_req(acx_
 */
 #if ACX_DEBUG
 unsigned int acx_debug /* will add __read_mostly later */ = ACX_DEFAULT_MSG;
+EXPORT_SYMBOL_GPL(acx_debug);
 /* parameter is 'debug', corresponding var is acx_debug */
 module_param_named(debug, acx_debug, uint, 0);
 MODULE_PARM_DESC(debug, "Debug level mask (see L_xxx constants)");
@@ -94,7 +95,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 #endif
 /* USB had this: MODULE_AUTHOR("Martin Wawro <martin.wawro AT uni-dortmund.de>"); */
 MODULE_AUTHOR("ACX100 Open Source Driver development team");
-MODULE_DESCRIPTION("Driver for TI ACX1xx based wireless cards (CardBus/PCI/USB)");
+MODULE_DESCRIPTION("Driver for TI ACX1xx based wireless cards (common)");
 
 
 /***********************************************************************
@@ -265,7 +266,7 @@ static const char
 spaces[] = "          " "          "; /* Nx10 spaces */
 
 void
-log_fn_enter(const char *funcname)
+acx_log_fn_enter(const char *funcname)
 {
 	int indent;
 	TIMESTAMP(d);
@@ -282,8 +283,11 @@ log_fn_enter(const char *funcname)
 
 	acx_debug_func_indent += FUNC_INDENT_INCREMENT;
 }
+
+EXPORT_SYMBOL_GPL(acx_log_fn_enter);
+
 void
-log_fn_exit(const char *funcname)
+acx_log_fn_exit(const char *funcname)
 {
 	int indent;
 	TIMESTAMP(d);
@@ -300,8 +304,11 @@ log_fn_exit(const char *funcname)
 		funcname
 	);
 }
+
+EXPORT_SYMBOL_GPL(acx_log_fn_exit);
+
 void
-log_fn_exit_v(const char *funcname, int v)
+acx_log_fn_exit_v(const char *funcname, int v)
 {
 	int indent;
 	TIMESTAMP(d);
@@ -319,6 +326,9 @@ log_fn_exit_v(const char *funcname, int 
 		v
 	);
 }
+
+EXPORT_SYMBOL_GPL(acx_log_fn_exit_v);
+
 #endif /* ACX_DEBUG > 1 */
 
 
@@ -333,6 +343,7 @@ acx_s_msleep(int ms)
 	FN_EXIT0;
 }
 
+EXPORT_SYMBOL_GPL(acx_s_msleep);
 
 /***********************************************************************
 ** Not inlined: it's larger than it seems
@@ -413,6 +424,8 @@ acx_get_packet_type_string(u16 fc)
 	}
 	return str;
 }
+
+EXPORT_SYMBOL_GPL(acx_get_packet_type_string);
 #endif
 
 
@@ -482,6 +495,8 @@ acx_cmd_status_str(unsigned int state)
 			cmd_error_strings[state] : "?";
 }
 
+EXPORT_SYMBOL_GPL(acx_cmd_status_str);
+
 
 /***********************************************************************
 ** get_status_string
@@ -573,6 +588,8 @@ acx_dump_bytes(const void *data, int num
 		printk("%02X\n", *ptr);
 	}
 }
+
+EXPORT_SYMBOL_GPL(acx_dump_bytes);
 #endif
 
 
@@ -660,6 +677,7 @@ acx_s_get_firmware_version(acx_device_t 
 	FN_EXIT0;
 }
 
+EXPORT_SYMBOL_GPL(acx_s_get_firmware_version);
 
 /***********************************************************************
 ** acx_display_hardware_details
@@ -730,6 +748,7 @@ acx_display_hardware_details(acx_device_
 	FN_EXIT0;
 }
 
+EXPORT_SYMBOL_GPL(acx_display_hardware_details);
 
 /***********************************************************************
 */
@@ -748,6 +767,7 @@ acx_e_change_mtu(struct net_device *ndev
 	return 0;
 }
 
+EXPORT_SYMBOL_GPL(acx_e_change_mtu);
 
 /***********************************************************************
 ** acx_e_get_stats, acx_e_get_wireless_stats
@@ -759,6 +779,8 @@ acx_e_get_stats(struct net_device *ndev)
 	return &adev->stats;
 }
 
+EXPORT_SYMBOL_GPL(acx_e_get_stats);
+
 struct iw_statistics*
 acx_e_get_wireless_stats(struct net_device *ndev)
 {
@@ -824,6 +846,7 @@ acx_signal_determine_quality(u8 signal, 
 	return qual;
 }
 
+EXPORT_SYMBOL_GPL(acx_signal_determine_quality);
 
 /***********************************************************************
 ** Interrogate/configure commands
@@ -853,7 +876,7 @@ acx100_ie_len[] = {
 	ACX1xx_IE_RXCONFIG_LEN,
 	0,
 	0,
-	ACX1xx_IE_FIRMWARE_STATISTICS_LEN,
+	sizeof(fw_stats_t)-4,
 	0,
 	ACX1xx_IE_FEATURE_CONFIG_LEN,
 	ACX111_IE_KEY_CHOOSE_LEN,
@@ -930,7 +953,7 @@ acx111_ie_len[] = {
 	ACX1xx_IE_RXCONFIG_LEN,
 	0,
 	0,
-	ACX1xx_IE_FIRMWARE_STATISTICS_LEN,
+	sizeof(fw_stats_t)-4,
 	0,
 	ACX1xx_IE_FEATURE_CONFIG_LEN,
 	ACX111_IE_KEY_CHOOSE_LEN,
@@ -992,12 +1015,11 @@ acx111_ie_len_dot11[] = {
 #if !ACX_DEBUG
 int
 acx_s_configure(acx_device_t *adev, void *pdr, int type)
-{
 #else
 int
 acx_s_configure_debug(acx_device_t *adev, void *pdr, int type, const char* typestr)
-{
 #endif
+{
 	u16 len;
 	int res;
 
@@ -1030,13 +1052,12 @@ acx_s_configure_debug(acx_device_t *adev
 #if !ACX_DEBUG
 int
 acx_s_interrogate(acx_device_t *adev, void *pdr, int type)
-{
 #else
 int
 acx_s_interrogate_debug(acx_device_t *adev, void *pdr, int type,
 		const char* typestr)
-{
 #endif
+{
 	u16 len;
 	int res;
 
@@ -1063,6 +1084,12 @@ acx_s_interrogate_debug(acx_device_t *ad
 	return res;
 }
 
+#if ACX_DEBUG
+EXPORT_SYMBOL_GPL(acx_s_interrogate_debug);
+#else
+EXPORT_SYMBOL_GPL(acx_s_interrogate);
+#endif /* ACX_DEBUG */
+
 #if CMD_DISCOVERY
 void
 great_inquisitor(acx_device_t *adev)
@@ -1150,20 +1177,27 @@ static int
 acx_s_proc_diag_output(char *buf, acx_device_t *adev)
 {
 	char *p = buf;
-	fw_stats_t *fw_stats;
 	unsigned long flags;
+	unsigned int len = 0, partlen;
+	u32 temp1, temp2;
+	u8 *st, *st_end;
+#ifdef __BIG_ENDIAN
+	u8 *st2;
+#endif
+	fw_stats_t *fw_stats;
+	char *part_str = NULL;
+	fw_stats_tx_t *tx = NULL;
+	fw_stats_rx_t *rx = NULL;
+	fw_stats_dma_t *dma = NULL;
+	fw_stats_irq_t *irq = NULL;
+	fw_stats_wep_t *wep = NULL;
+	fw_stats_pwr_t *pwr = NULL;
+	fw_stats_mic_t *mic = NULL;
+	fw_stats_aes_t *aes = NULL;
+	fw_stats_event_t *evt = NULL;
 
 	FN_ENTER;
 
-	/* TODO: may replace kmalloc/memset with kzalloc once
-	 * Linux 2.6.14 is widespread */
-	fw_stats = kmalloc(sizeof(*fw_stats), GFP_KERNEL);
-	if (!fw_stats) {
-		FN_EXIT1(0);
-		return 0;
-	}
-	memset(fw_stats, 0, sizeof(*fw_stats));
-
 	acx_lock(adev, flags);
 
 	if (IS_PCI(adev))
@@ -1207,63 +1241,322 @@ acx_s_proc_diag_output(char *buf, acx_de
 
 	acx_unlock(adev, flags);
 
-	if (OK != acx_s_interrogate(adev, fw_stats, ACX1xx_IE_FIRMWARE_STATISTICS))
-		p += sprintf(p,
-			"\n"
-			"** Firmware **\n"
-			"QUERY FAILED!!\n");
-	else {
-		p += sprintf(p,
-			"\n"
-			"** Firmware **\n"
-			"version \"%s\"\n"
-			"tx_desc_overfl %u, rx_OutOfMem %u, rx_hdr_overfl %u, rx_hdr_use_next %u\n"
-			"rx_dropped_frame %u, rx_frame_ptr_err %u, rx_xfr_hint_trig %u, rx_dma_req %u\n"
-			"rx_dma_err %u, tx_dma_req %u, tx_dma_err %u, cmd_cplt %u, fiq %u\n"
-			"rx_hdrs %u, rx_cmplt %u, rx_mem_overfl %u, rx_rdys %u, irqs %u\n"
-			"acx_trans_procs %u, decrypt_done %u, dma_0_done %u, dma_1_done %u\n",
-			adev->firmware_version,
-			le32_to_cpu(fw_stats->tx_desc_of),
-			le32_to_cpu(fw_stats->rx_oom),
-			le32_to_cpu(fw_stats->rx_hdr_of),
-			le32_to_cpu(fw_stats->rx_hdr_use_next),
-			le32_to_cpu(fw_stats->rx_dropped_frame),
-			le32_to_cpu(fw_stats->rx_frame_ptr_err),
-			le32_to_cpu(fw_stats->rx_xfr_hint_trig),
-			le32_to_cpu(fw_stats->rx_dma_req),
-			le32_to_cpu(fw_stats->rx_dma_err),
-			le32_to_cpu(fw_stats->tx_dma_req),
-			le32_to_cpu(fw_stats->tx_dma_err),
-			le32_to_cpu(fw_stats->cmd_cplt),
-			le32_to_cpu(fw_stats->fiq),
-			le32_to_cpu(fw_stats->rx_hdrs),
-			le32_to_cpu(fw_stats->rx_cmplt),
-			le32_to_cpu(fw_stats->rx_mem_of),
-			le32_to_cpu(fw_stats->rx_rdys),
-			le32_to_cpu(fw_stats->irqs),
-			le32_to_cpu(fw_stats->acx_trans_procs),
-			le32_to_cpu(fw_stats->decrypt_done),
-			le32_to_cpu(fw_stats->dma_0_done),
-			le32_to_cpu(fw_stats->dma_1_done));
+	p += sprintf(p,
+		"\n"
+		"** Firmware **\n"
+		"NOTE: version dependent statistics layout, "
+		"please report if you suspect wrong parsing!\n"
+		"\n"
+		"version \"%s\"\n", adev->firmware_version);
+
+	/* TODO: may replace kmalloc/memset with kzalloc once
+	 * Linux 2.6.14 is widespread */
+	fw_stats = kmalloc(sizeof(*fw_stats), GFP_KERNEL);
+	if (!fw_stats) {
+		FN_EXIT1(0);
+		return 0;
+	}
+	memset(fw_stats, 0, sizeof(*fw_stats));
+
+	st = (u8 *)fw_stats;
+
+	part_str = "statistics query command";
+
+	if (OK != acx_s_interrogate(adev, st, ACX1xx_IE_FIRMWARE_STATISTICS))
+		goto fw_stats_end;
+
+	st += sizeof(u16);
+	len = *(u16 *)st;
+
+	if (len > sizeof(*fw_stats)) {
 		p += sprintf(p,
-			"tx_exch_complet %u, commands %u, acx_rx_procs %u\n"
-			"hw_pm_mode_changes %u, host_acks %u, pci_pm %u, acm_wakeups %u\n"
-			"wep_key_count %u, wep_default_key_count %u, dot11_def_key_mib %u\n"
-			"wep_key_not_found %u, wep_decrypt_fail %u\n",
-			le32_to_cpu(fw_stats->tx_exch_complet),
-			le32_to_cpu(fw_stats->commands),
-			le32_to_cpu(fw_stats->acx_rx_procs),
-			le32_to_cpu(fw_stats->hw_pm_mode_changes),
-			le32_to_cpu(fw_stats->host_acks),
-			le32_to_cpu(fw_stats->pci_pm),
-			le32_to_cpu(fw_stats->acm_wakeups),
-			le32_to_cpu(fw_stats->wep_key_count),
-			le32_to_cpu(fw_stats->wep_default_key_count),
-			le32_to_cpu(fw_stats->dot11_def_key_mib),
-			le32_to_cpu(fw_stats->wep_key_not_found),
-			le32_to_cpu(fw_stats->wep_decrypt_fail));
+			"firmware version with bigger fw_stats struct detected\n"
+			"(%u vs. %u), please report\n", len, sizeof(fw_stats_t));
+		if (len > sizeof(*fw_stats)) {
+			p += sprintf(p, "struct size exceeded allocation!\n");
+			len = sizeof(*fw_stats);
+		}
+	}
+	st += sizeof(u16);
+	st_end = st - 2*sizeof(u16) + len;
+
+#ifdef __BIG_ENDIAN
+	/* let's make one bold assumption here:
+	 * (hopefully!) *all* statistics fields are u32 only,
+	 * thus if we need to make endianness corrections
+	 * we can simply do them in one go, in advance */
+	st2 = (u8 *)fw_stats;
+	for (temp1 = 0; temp1 < len; temp1 += 4, st2 += 4)
+		*(u32 *)st2 = le32_to_cpu(*(u32 *)st2);
+#endif
+
+	part_str = "Rx/Tx";
+
+	/* directly at end of a struct part? --> no error! */
+	if (st == st_end)
+		goto fw_stats_end;
+
+	tx = (fw_stats_tx_t *)st;
+	st += sizeof(fw_stats_tx_t);
+	rx = (fw_stats_rx_t *)st;
+	st += sizeof(fw_stats_rx_t);
+	partlen = sizeof(fw_stats_tx_t) + sizeof(fw_stats_rx_t);
+
+	if (IS_ACX100(adev)) {
+		/* at least ACX100 PCI F/W 1.9.8.b
+		 * and ACX100 USB F/W 1.0.7-USB
+		 * don't have those two fields... */
+		st -= 2*sizeof(u32);
+
+		/* our parsing doesn't quite match this firmware yet,
+		 * log failure */
+		if (st > st_end)
+			goto fw_stats_fail;
+		temp1 = temp2 = 999999999;
+	} else {
+		if (st > st_end)
+			goto fw_stats_fail;
+		temp1 = rx->rx_aci_events;
+		temp2 = rx->rx_aci_resets;
 	}
 
+	p += sprintf(p,
+		"%s:\n"
+		"  tx_desc_overfl %u\n"
+		"  rx_OutOfMem %u, rx_hdr_overfl %u, rx_hw_stuck %u\n"
+		"  rx_dropped_frame %u, rx_frame_ptr_err %u, rx_xfr_hint_trig %u\n"
+		"  rx_aci_events %u, rx_aci_resets %u\n",
+		part_str,
+		tx->tx_desc_of,
+		rx->rx_oom,
+		rx->rx_hdr_of,
+		rx->rx_hw_stuck,
+		rx->rx_dropped_frame,
+		rx->rx_frame_ptr_err,
+		rx->rx_xfr_hint_trig,
+		temp1,
+		temp2);
+
+	part_str = "DMA";
+
+	if (st == st_end)
+		goto fw_stats_end;
+
+	dma = (fw_stats_dma_t *)st;
+	partlen = sizeof(fw_stats_dma_t);
+	st += partlen;
+
+	if (st > st_end)
+		goto fw_stats_fail;
+
+	p += sprintf(p,
+		"%s:\n"
+		"  rx_dma_req %u, rx_dma_err %u, tx_dma_req %u, tx_dma_err %u\n",
+		part_str,
+		dma->rx_dma_req,
+		dma->rx_dma_err,
+		dma->tx_dma_req,
+		dma->tx_dma_err);
+
+	part_str = "IRQ";
+
+	if (st == st_end)
+		goto fw_stats_end;
+
+	irq = (fw_stats_irq_t *)st;
+	partlen = sizeof(fw_stats_irq_t);
+	st += partlen;
+
+	if (st > st_end)
+		goto fw_stats_fail;
+
+	p += sprintf(p,
+		"%s:\n"
+		"  cmd_cplt %u, fiq %u\n"
+		"  rx_hdrs %u, rx_cmplt %u, rx_mem_overfl %u, rx_rdys %u\n"
+		"  irqs %u, tx_procs %u, decrypt_done %u\n"
+		"  dma_0_done %u, dma_1_done %u, tx_exch_complet %u\n"
+		"  commands %u, rx_procs %u, hw_pm_mode_changes %u\n"
+		"  host_acks %u, pci_pm %u, acm_wakeups %u\n",
+		part_str,
+		irq->cmd_cplt,
+		irq->fiq,
+		irq->rx_hdrs,
+		irq->rx_cmplt,
+		irq->rx_mem_of,
+		irq->rx_rdys,
+		irq->irqs,
+		irq->tx_procs,
+		irq->decrypt_done,
+		irq->dma_0_done,
+		irq->dma_1_done,
+		irq->tx_exch_complet,
+		irq->commands,
+		irq->rx_procs,
+		irq->hw_pm_mode_changes,
+		irq->host_acks,
+		irq->pci_pm,
+		irq->acm_wakeups);
+
+	part_str = "WEP";
+
+	if (st == st_end)
+		goto fw_stats_end;
+
+	wep = (fw_stats_wep_t *)st;
+	partlen = sizeof(fw_stats_wep_t);
+	st += partlen;
+
+	if (
+	    (IS_PCI(adev) && IS_ACX100(adev))
+	||  (IS_USB(adev) && IS_ACX100(adev))
+	) {
+		/* at least ACX100 PCI F/W 1.9.8.b
+		 * and ACX100 USB F/W 1.0.7-USB
+		 * don't have those two fields... */
+		st -= 2*sizeof(u32);
+		if (st > st_end)
+			goto fw_stats_fail;
+		temp1 = temp2 = 999999999;
+	} else {
+		if (st > st_end)
+			goto fw_stats_fail;
+		temp1 = wep->wep_pkt_decrypt;
+		temp2 = wep->wep_decrypt_irqs;
+	}
+
+	p += sprintf(p,
+		"%s:\n"
+		"  wep_key_count %u, wep_default_key_count %u, dot11_def_key_mib %u\n"
+		"  wep_key_not_found %u, wep_decrypt_fail %u\n"
+		"  wep_pkt_decrypt %u, wep_decrypt_irqs %u\n",
+		part_str,
+		wep->wep_key_count,
+		wep->wep_default_key_count,
+		wep->dot11_def_key_mib,
+		wep->wep_key_not_found,
+		wep->wep_decrypt_fail,
+		temp1,
+		temp2);
+
+	part_str = "power";
+
+	if (st == st_end)
+		goto fw_stats_end;
+
+	pwr = (fw_stats_pwr_t *)st;
+	partlen = sizeof(fw_stats_pwr_t);
+	st += partlen;
+
+	if (st > st_end)
+		goto fw_stats_fail;
+
+	p += sprintf(p,
+		"%s:\n"
+		"  tx_start_ctr %u, no_ps_tx_too_short %u\n"
+		"  rx_start_ctr %u, no_ps_rx_too_short %u\n"
+		"  lppd_started %u\n"
+		"  no_lppd_too_noisy %u, no_lppd_too_short %u, no_lppd_matching_frame %u\n",
+		part_str,
+		pwr->tx_start_ctr,
+		pwr->no_ps_tx_too_short,
+		pwr->rx_start_ctr,
+		pwr->no_ps_rx_too_short,
+		pwr->lppd_started,
+		pwr->no_lppd_too_noisy,
+		pwr->no_lppd_too_short,
+		pwr->no_lppd_matching_frame);
+
+	part_str = "MIC";
+
+	if (st == st_end)
+		goto fw_stats_end;
+
+	mic = (fw_stats_mic_t *)st;
+	partlen = sizeof(fw_stats_mic_t);
+	st += partlen;
+
+	if (st > st_end)
+		goto fw_stats_fail;
+
+	p += sprintf(p,
+		"%s:\n"
+		"  mic_rx_pkts %u, mic_calc_fail %u\n",
+		part_str,
+		mic->mic_rx_pkts,
+		mic->mic_calc_fail);
+
+	part_str = "AES";
+
+	if (st == st_end)
+		goto fw_stats_end;
+
+	aes = (fw_stats_aes_t *)st;
+	partlen = sizeof(fw_stats_aes_t);
+	st += partlen;
+
+	if (st > st_end)
+		goto fw_stats_fail;
+
+	p += sprintf(p,
+		"%s:\n"
+		"  aes_enc_fail %u, aes_dec_fail %u\n"
+		"  aes_enc_pkts %u, aes_dec_pkts %u\n"
+		"  aes_enc_irq %u, aes_dec_irq %u\n",
+		part_str,
+		aes->aes_enc_fail,
+		aes->aes_dec_fail,
+		aes->aes_enc_pkts,
+		aes->aes_dec_pkts,
+		aes->aes_enc_irq,
+		aes->aes_dec_irq);
+
+	part_str = "event";
+
+	if (st == st_end)
+		goto fw_stats_end;
+
+	evt = (fw_stats_event_t *)st;
+	partlen = sizeof(fw_stats_event_t);
+	st += partlen;
+
+	if (st > st_end)
+		goto fw_stats_fail;
+
+	p += sprintf(p,
+		"%s:\n"
+		"  heartbeat %u, calibration %u\n"
+		"  rx_mismatch %u, rx_mem_empty %u, rx_pool %u\n"
+		"  oom_late %u\n"
+		"  phy_tx_err %u, tx_stuck %u\n",
+		part_str,
+		evt->heartbeat,
+		evt->calibration,
+		evt->rx_mismatch,
+		evt->rx_mem_empty,
+		evt->rx_pool,
+		evt->oom_late,
+		evt->phy_tx_err,
+		evt->tx_stuck);
+
+	if (st < st_end)
+		goto fw_stats_bigger;
+
+	goto fw_stats_end;
+
+fw_stats_fail:
+	st -= partlen;
+	p += sprintf(p,
+		"failed at %s part (size %u), offset %u (struct size %u), "
+		"please report\n", part_str, partlen,
+		(int)st - (int)fw_stats, len);
+
+fw_stats_bigger:
+	for (; st < st_end; st += 4)
+		p += sprintf(p,
+			"UNKN%3d: %u\n", (int)st - (int)fw_stats, *(u32 *)st);
+
+fw_stats_end:
 	kfree(fw_stats);
 
 	FN_EXIT1(p - buf);
@@ -1472,11 +1765,15 @@ acx_proc_register_entries(const struct n
 	return manage_proc_entries(ndev, 0);
 }
 
+EXPORT_SYMBOL_GPL(acx_proc_register_entries);
+
 int
 acx_proc_unregister_entries(const struct net_device *ndev)
 {
 	return manage_proc_entries(ndev, 1);
 }
+
+EXPORT_SYMBOL_GPL(acx_proc_unregister_entries);
 #endif /* CONFIG_PROC_FS */
 
 
@@ -1852,7 +2149,7 @@ bad:
 ** Note that this fn messes up heavily with hardware, but we cannot
 ** lock it (we need to sleep). Not a problem since IRQs can't happen
 */
-static int
+int
 acx100_s_create_dma_regions(acx_device_t *adev)
 {
 	acx100_ie_queueconfig_t queueconf;
@@ -1936,6 +2233,7 @@ end:
 	return res;
 }
 
+EXPORT_SYMBOL_GPL(acx100_s_create_dma_regions);
 
 /***********************************************************************
 ** acx111_s_create_dma_regions
@@ -1945,7 +2243,7 @@ end:
 */
 #define ACX111_PERCENT(percent) ((percent)/5)
 
-static int
+int
 acx111_s_create_dma_regions(acx_device_t *adev)
 {
 	struct acx111_ie_memoryconfig memconf;
@@ -2033,6 +2331,7 @@ fail:
 	return NOT_OK;
 }
 
+EXPORT_SYMBOL_GPL(acx111_s_create_dma_regions);
 
 /***********************************************************************
 */
@@ -2298,6 +2597,7 @@ acx_s_set_defaults(acx_device_t *adev)
 	FN_EXIT0;
 }
 
+EXPORT_SYMBOL_GPL(acx_s_set_defaults);
 
 /***********************************************************************
 ** FIXME: this should be solved in a general way for all radio types
@@ -2723,76 +3023,78 @@ acx_l_process_rxbuf(acx_device_t *adev, 
 
 
 //SM: have no dev specific code, should be moved to sm layer
+/* Filter out unrelated packets, call ieee80211_rx[_mgt] */
 static int
-_TODO_wlan_rx(struct ieee80211_device *ieee,
-		struct sk_buff *skb,
-		struct ieee80211_rx_stats *stats)
+_TODO_ieee80211_rx_any(struct ieee80211_device *ieee,
+		     struct sk_buff *skb, struct ieee80211_rx_stats *stats)
 {
 	struct ieee80211_hdr_4addr *hdr;
-	int is_packet_for_us = 0;
+	int is_packet_for_us;
 	u16 fc;
 
 	if (ieee->iw_mode == IW_MODE_MONITOR)
 		return ieee80211_rx(ieee, skb, stats) ? 0 : -EINVAL;
 
 	hdr = (struct ieee80211_hdr_4addr *)skb->data;
+	fc = le16_to_cpu(hdr->frame_ctl);
 
-	switch (ieee->iw_mode) {
-	case IW_MODE_ADHOC:
-		if (memcmp(hdr->addr1, ieee->dev->dev_addr, ETH_ALEN) == 0 ||
-		    memcmp(hdr->addr3, ieee->bssid, ETH_ALEN) == 0 ||
-		    is_broadcast_ether_addr(hdr->addr1) ||
-		    is_multicast_ether_addr(hdr->addr1) ||
-		    ieee->dev->flags & IFF_PROMISC)
-			is_packet_for_us = 1;
+	if ((fc & IEEE80211_FCTL_VERS) != 0)
+		return -EINVAL;
+
+	switch (fc & IEEE80211_FCTL_FTYPE) {
+	case IEEE80211_FTYPE_MGMT:
+		ieee80211_rx_mgt(ieee, hdr, stats);
+		return 0;
+	case IEEE80211_FTYPE_DATA:
 		break;
-	case IW_MODE_INFRA:
+	case IEEE80211_FTYPE_CTL:
+		return 0;
 	default:
-		/* When receiving multicast or broadcast packets, filter out
-		   the packets we send ourself; we shouldn't see those */
-		if (memcmp(hdr->addr3, ieee->bssid, ETH_ALEN) == 0 ||
-		    memcmp(hdr->addr1, ieee->dev->dev_addr, ETH_ALEN) == 0 ||
-		    (memcmp(hdr->addr3, ieee->dev->dev_addr, ETH_ALEN) &&
-		     (is_broadcast_ether_addr(hdr->addr1) ||
-		      is_multicast_ether_addr(hdr->addr1) ||
-		      ieee->dev->flags & IFF_PROMISC)))
-			is_packet_for_us = 1;
-		break;
+		return -EINVAL;
 	}
 
-	fc = hdr->frame_ctl;
-
-	if ((fc & WF_FC_ISWEPi) && !ieee->host_decrypt) {
-		fc &= ~WF_FC_ISWEPi;
-		hdr->frame_ctl = fc;		
-		/* trim IV and ICV */
-		/* FIXME: this must be done only for WEP encrypted packets */
-		if (skb->len < 32) {
-			printk("acx: RX packet dropped: PROTECTED flag "
-				"set and length < 32 (%d)\n", skb->len);
-			return -EINVAL;
-		} else {		
-			memmove(skb->data + 4, skb->data, 24);
-			skb_pull(skb, 4);
-			skb_trim(skb, skb->len - 4);
+	is_packet_for_us = 0;
+	switch (ieee->iw_mode) {
+	case IW_MODE_ADHOC:
+		/* our BSS and not from/to DS */
+		if (memcmp(hdr->addr3, ieee->bssid, ETH_ALEN) == 0)
+		if ((fc & (IEEE80211_FCTL_TODS+IEEE80211_FCTL_FROMDS)) == 0) {
+			/* promisc: get all */
+			if (ieee->dev->flags & IFF_PROMISC)
+				is_packet_for_us = 1;
+			/* to us */
+			else if (memcmp(hdr->addr1, ieee->dev->dev_addr, ETH_ALEN) == 0)
+				is_packet_for_us = 1;
+			/* mcast */
+			else if (is_multicast_ether_addr(hdr->addr1))
+				is_packet_for_us = 1;
 		}
-		hdr = (struct ieee80211_hdr_4addr *)skb->data;
-	}
-
-	switch (fc & WF_FC_FTYPEi) {
-	case WF_FTYPE_MGMTi:
-		ieee80211_rx_mgt(ieee, hdr, stats);
 		break;
-	case WF_FTYPE_DATAi:
-		if (is_packet_for_us)
-			return (ieee80211_rx(ieee, skb, stats) ? 0 : -EINVAL);
-		break;
-	case WF_FTYPE_CTLi:
+	case IW_MODE_INFRA:
+		/* our BSS (== from our AP) and from DS */
+		if (memcmp(hdr->addr2, ieee->bssid, ETH_ALEN) == 0)
+		if ((fc & (IEEE80211_FCTL_TODS+IEEE80211_FCTL_FROMDS)) == IEEE80211_FCTL_FROMDS) {
+			/* promisc: get all */
+			if (ieee->dev->flags & IFF_PROMISC)
+				is_packet_for_us = 1;
+			/* to us */
+			else if (memcmp(hdr->addr1, ieee->dev->dev_addr, ETH_ALEN) == 0)
+				is_packet_for_us = 1;
+			/* mcast */
+			else if (is_multicast_ether_addr(hdr->addr1)) {
+				/* not our own packet bcasted from AP */
+				if (memcmp(hdr->addr3, ieee->dev->dev_addr, ETH_ALEN))
+					is_packet_for_us = 1;
+			}
+		}
 		break;
 	default:
-		return -EINVAL;
+		/* ? */
+		break;
 	}
 
+	if (is_packet_for_us)
+		return (ieee80211_rx(ieee, skb, stats) ? 0 : -EINVAL);
 	return 0;
 }
 
@@ -2862,12 +3164,12 @@ acx_l_softmac_process_rxbuf(acx_device_t
 
 	memset(&stats, 0, sizeof(stats));
 	stats.mac_time = le16_to_cpu(rxbuf->time);
-	//stats.rssi = 
+	//stats.rssi =
 	stats.signal = rxbuf->phy_snr;
 	stats.noise = rxbuf->phy_level;
 	stats.rate = rxbuf->phy_plcp_signal / 5;
 	stats.received_channel = adev->channel;
-	//stats.control = 
+	//stats.control =
 	stats.mask = 0
 		| IEEE80211_STATMASK_SIGNAL
 		| IEEE80211_STATMASK_NOISE
@@ -2877,12 +3179,12 @@ acx_l_softmac_process_rxbuf(acx_device_t
 	stats.freq = IEEE80211_24GHZ_BAND;
 	stats.len = skb->len;
 
-	_TODO_wlan_rx(adev->ieee, skb, &stats);
+	_TODO_ieee80211_rx_any(adev->ieee, skb, &stats);
 end:
 	FN_EXIT0;
 }
 
-
+EXPORT_SYMBOL_GPL(acx_l_softmac_process_rxbuf);
 
 
 
@@ -3035,6 +3337,7 @@ acx_l_handle_txrate_auto(acx_device_t *a
 	}
 }
 
+EXPORT_SYMBOL_GPL(acx_l_handle_txrate_auto);
 
 /***********************************************************************
 ** acx_i_start_xmit
@@ -3147,7 +3450,7 @@ acx_i_ieee80211_start_xmit(struct ieee80
 
 	acx_lock(adev, flags);
 
-        for (i = 0; i < txb->nr_frags; i++) {
+	for (i = 0; i < txb->nr_frags; i++) {
 		tx_t *tx;
 		void *txbuf;
 		struct sk_buff *skb = txb->fragments[i];
@@ -3170,7 +3473,7 @@ acx_i_ieee80211_start_xmit(struct ieee80
 		//ndev->trans_start = jiffies;
 		//adev->stats.tx_packets++;
 		//adev->stats.tx_bytes += skb->len;
-        }
+	}
 	rc = 0;
 
 end:
@@ -3184,6 +3487,7 @@ end_no_unlock:
 	return rc;
 }
 
+EXPORT_SYMBOL_GPL(acx_i_ieee80211_start_xmit);
 
 /***********************************************************************
 ** acx_l_update_ratevector
@@ -3481,6 +3785,7 @@ acx_set_status(acx_device_t *adev, u16 n
 	FN_EXIT0;
 }
 
+EXPORT_SYMBOL_GPL(acx_set_status);
 
 /***********************************************************************
 ** acx_i_timer
@@ -3560,6 +3865,7 @@ acx_i_timer(unsigned long address)
 	FN_EXIT0;
 }
 
+EXPORT_SYMBOL_GPL(acx_i_timer);
 
 /***********************************************************************
 ** acx_set_timer
@@ -5484,6 +5790,7 @@ release_ret:
 	return res;
 }
 
+EXPORT_SYMBOL_GPL(acx_s_read_fw);
 
 /***********************************************************************
 ** acx_s_set_wepkey
@@ -6072,6 +6379,7 @@ fail:
 	return result;
 }
 
+EXPORT_SYMBOL_GPL(acx_s_init_mac);
 
 void
 acx_s_set_sane_reg_domain(acx_device_t *adev, int do_set)
@@ -6704,6 +7012,7 @@ acx_s_update_card_settings(acx_device_t 
 	FN_EXIT0;
 }
 
+EXPORT_SYMBOL_GPL(acx_s_update_card_settings);
 
 /***********************************************************************
 ** acx_e_after_interrupt_task
@@ -6910,6 +7219,7 @@ acx_schedule_task(acx_device_t *adev, un
 	SCHEDULE_WORK(&adev->after_interrupt_task);
 }
 
+EXPORT_SYMBOL_GPL(acx_schedule_task);
 
 /***********************************************************************
 */
@@ -6921,6 +7231,7 @@ acx_init_task_scheduler(acx_device_t *ad
 			adev->ndev);
 }
 
+EXPORT_SYMBOL_GPL(acx_init_task_scheduler);
 
 /***********************************************************************
 ** acx_s_start
@@ -6947,6 +7258,7 @@ acx_s_start(acx_device_t *adev)
 	FN_EXIT0;
 }
 
+EXPORT_SYMBOL_GPL(acx_s_start);
 
 /***********************************************************************
 ** acx_update_capabilities
@@ -7138,59 +7450,7 @@ acx_s_parse_configoption(acx_device_t *a
 */
 }
 
-
-/***********************************************************************
-*/
-static int __init
-acx_e_init_module(void)
-{
-	int r1,r2;
-
-	acx_struct_size_check();
-
-	printk("acx: this driver is still EXPERIMENTAL\n"
-		"acx: reading README file and/or Craig's HOWTO is "
-		"recommended, visit http://acx100.sf.net in case "
-		"of further questions/discussion\n");
-
-#if defined(CONFIG_ACX_PCI_BOOL)
-	r1 = acxpci_e_init_module();
-#else
-	r1 = -EINVAL;
-#endif
-#if defined(CONFIG_ACX_USB_BOOL)
-	r2 = acxusb_e_init_module();
-#else
-	r2 = -EINVAL;
-#endif
-	if (r2 && r1) /* both failed! */
-		return r2 ? r2 : r1;
-	/* return success if at least one succeeded */
-	return 0;
-}
-
-static void __exit
-acx_e_cleanup_module(void)
-{
-#if defined(CONFIG_ACX_PCI_BOOL)
-	acxpci_e_cleanup_module();
-#endif
-#if defined(CONFIG_ACX_USB_BOOL)
-	acxusb_e_cleanup_module();
-#endif
-}
-
-module_init(acx_e_init_module)
-module_exit(acx_e_cleanup_module)
-
-
-
-
-
-
-
-
-
+EXPORT_SYMBOL_GPL(acx_s_parse_configoption);
 
 //SM
 void
@@ -7230,7 +7490,7 @@ acx_e_ieee80211_set_security(struct net_
 			adev->ieee->sec.flags |= SEC_ACTIVE_KEY;
 		} else
 			adev->ieee->sec.flags &= ~SEC_ACTIVE_KEY;
-		
+
 	} else
 		adev->ieee->sec.flags &= ~SEC_ACTIVE_KEY;
 
@@ -7257,13 +7517,14 @@ acx_e_ieee80211_set_security(struct net_
 		adev->ieee->sec.flags |= SEC_LEVEL;
 		SET_BIT(adev->set_mask, GETSET_WEP);
 	}
-	
+
 	acx_unlock(adev, flags);
 	acx_sem_unlock(adev);
 
 	acx_s_update_card_settings(adev);
 }
 
+EXPORT_SYMBOL_GPL(acx_e_ieee80211_set_security);
 
 void
 acx_e_ieee80211_set_chan(struct net_device *ndev, u8 channel)
@@ -7277,3 +7538,5 @@ acx_e_ieee80211_set_chan(struct net_devi
 
 	acx_sem_unlock(adev);
 }
+
+EXPORT_SYMBOL_GPL(acx_e_ieee80211_set_chan);
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/ioctl.c wireless-2.6.git.acx/drivers/net/wireless/tiacx/ioctl.c
--- wireless-2.6.git/drivers/net/wireless/tiacx/ioctl.c	Wed Mar  1 07:56:14 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/ioctl.c	Wed Mar  1 12:05:04 2006
@@ -1007,87 +1007,9 @@ acx_ioctl_set_encode(
 	union iwreq_data *wrqu,
 	char *extra)
 {
-	struct iw_point *dwrq = &wrqu->encoding;
-	acx_device_t *adev = ndev2adev(ndev);
-	int index;
 	int result;
-
 	FN_ENTER;
-
-	log(L_IOCTL, "set encoding flags=0x%04X, size=%d, key: %s\n",
-			dwrq->flags, dwrq->length, extra ? "set" : "No key");
-
-	acx_sem_lock(adev);
-
-	index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
-
-	if (dwrq->length > 0) {
-		/* if index is 0 or invalid, use default key */
-		if ((index < 0) || (index > 3))
-			index = (int)adev->ieee->sec.active_key;
-
-		if (0 == (dwrq->flags & IW_ENCODE_NOKEY)) {
-			if (dwrq->length > 29)
-				dwrq->length = 29; /* restrict it */
-
-			if (dwrq->length > 13) {
-				/* 29*8 == 232, WEP256 */
-				adev->ieee->sec.key_sizes[index] = 29;
-			} else if (dwrq->length > 5) {
-				/* 13*8 == 104bit, WEP128 */
-				adev->ieee->sec.key_sizes[index] = 13;
-			} else if (dwrq->length > 0) {
-				/* 5*8 == 40bit, WEP64 */
-				adev->ieee->sec.key_sizes[index] = 5;
-			} else {
-				/* disable key */
-				adev->ieee->sec.key_sizes[index] = 0;
-			}
-
-			memset(adev->ieee->sec.keys[index], 0,
-				sizeof(adev->ieee->sec.keys[index]));
-			memcpy(adev->ieee->sec.keys[index], extra, dwrq->length);
-		}
-	} else {
-		/* set transmit key */
-		if ((index >= 0) && (index <= 3))
-			adev->ieee->sec.active_key = index;
-		else if (0 == (dwrq->flags & IW_ENCODE_MODE)) {
-			/* complain if we were not just setting
-			 * the key mode */
-			result = -EINVAL;
-			goto end_unlock;
-		}
-	}
-
-	adev->ieee->sec.enabled = !(dwrq->flags & IW_ENCODE_DISABLED);
-
-	if (dwrq->flags & IW_ENCODE_OPEN) {
-		adev->ieee->sec.auth_mode = WLAN_AUTH_OPEN;
-
-	} else if (dwrq->flags & IW_ENCODE_RESTRICTED) {
-	  adev->ieee->sec.auth_mode = WLAN_AUTH_SHARED_KEY;
-	}
-
-	/* set flag to make sure the card WEP settings get updated */
-	SET_BIT(adev->set_mask, GETSET_WEP);
-
-	log(L_IOCTL, "len=%d, key at 0x%p, flags=0x%X\n",
-		dwrq->length, extra, dwrq->flags);
-
-	for (index = 0; index <= 3; index++) {
-		if (adev->ieee->sec.key_sizes[index]) {
-			log(L_IOCTL,	"index=%d, size=%d, key at 0x%p\n",
-				adev->ieee->sec.active_key,
-				(int) adev->ieee->sec.key_sizes[index],
-				adev->ieee->sec.keys[index]);
-		}
-	}
-	result = -EINPROGRESS;
-
-end_unlock:
-	acx_sem_unlock(adev);
-
+	result = ieee80211_wx_set_encode(netdev_priv(ndev), info, wrqu, extra);
 	FN_EXIT1(result);
 	return result;
 }
@@ -1103,38 +1025,45 @@ acx_ioctl_get_encode(
 	union iwreq_data *wrqu,
 	char *extra)
 {
-	struct iw_point *dwrq = &wrqu->encoding;
-	acx_device_t *adev = ndev2adev(ndev);
-	int index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
-
+	int result;
 	FN_ENTER;
-
-	if (adev->ieee->sec.enabled == 0) {
-		dwrq->flags = IW_ENCODE_DISABLED;
-	} else {
-		if ((index < 0) || (index > 3))
-			index = (int)adev->ieee->sec.active_key;
-
-		dwrq->flags = (adev->ieee->sec.auth_mode == WLAN_AUTH_SHARED_KEY) ?
-				IW_ENCODE_RESTRICTED : IW_ENCODE_OPEN;
-		dwrq->length = adev->ieee->sec.key_sizes[index];
-
-		memcpy(extra, adev->ieee->sec.keys[index],
-			      adev->ieee->sec.key_sizes[index]);
-	}
-
-	/* set the current index */
-	SET_BIT(dwrq->flags, index + 1);
-
-	log(L_IOCTL, "len=%d, key=%p, flags=0x%X\n",
-	       dwrq->length, dwrq->pointer,
-	       dwrq->flags);
-
-	FN_EXIT1(OK);
-	return OK;
+	result = ieee80211_wx_get_encode(netdev_priv(ndev), info, wrqu, extra);
+	FN_EXIT1(result);
+	return result;
 }
 
-
+/***********************************************************************
+** acx_ioctl_set_encodeext
+*/
+static int
+acx_ioctl_set_encodeext(
+	struct net_device *ndev,
+	struct iw_request_info *info,
+	union iwreq_data *wrqu,
+	char *extra)
+{
+	int result;
+	FN_ENTER;
+	result = ieee80211_wx_set_encodeext(netdev_priv(ndev), info, wrqu, extra);
+	FN_EXIT1(result);
+	return result;
+}
+/***********************************************************************
+** acx_ioctl_get_encodeext
+*/
+static int
+acx_ioctl_get_encodeext(
+	struct net_device *ndev,
+	struct iw_request_info *info,
+	union iwreq_data *wrqu,
+	char *extra)
+{
+	int result;
+	FN_ENTER;
+	result = ieee80211_wx_get_encodeext(netdev_priv(ndev), info, wrqu, extra);
+	FN_EXIT1(result);
+	return result;
+}
 /***********************************************************************
 */
 static int
@@ -2608,6 +2537,8 @@ static const iw_handler acx_ioctl_handle
 	/* Encoding */
 	WX(SIOCSIWENCODE)	= acx_ioctl_set_encode,
 	WX(SIOCGIWENCODE)	= acx_ioctl_get_encode,
+	WX(SIOCSIWENCODEEXT)    = acx_ioctl_set_encodeext,
+	WX(SIOCGIWENCODEEXT)    = acx_ioctl_get_encodeext,
 	/* Power saving */
 	WX(SIOCSIWPOWER)	= acx_ioctl_set_power,
 	WX(SIOCGIWPOWER)	= acx_ioctl_get_power,
@@ -2803,3 +2734,5 @@ const struct iw_handler_def acx_ioctl_ha
 	.get_wireless_stats = acx_e_get_wireless_stats
 #endif /* IW > 5 */
 };
+
+EXPORT_SYMBOL_GPL(acx_ioctl_handler_def);
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/pci.c wireless-2.6.git.acx/drivers/net/wireless/tiacx/pci.c
--- wireless-2.6.git/drivers/net/wireless/tiacx/pci.c	Wed Mar  1 07:56:14 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/pci.c	Wed Mar  1 12:05:04 2006
@@ -105,6 +105,25 @@ static int acxpci_e_close(struct net_dev
 static void acxpci_s_up(struct net_device *ndev);
 static void acxpci_s_down(struct net_device *ndev);
 
+#if ACX_DEBUG
+static int acxpci_s_issue_cmd_timeo_debug(acx_device_t *adev, unsigned cmd, void *param, unsigned len, unsigned timeout, const char* cmdstr);
+#else
+static int acxpci_s_issue_cmd_timeo(acx_device_t *adev, unsigned cmd, void *param, unsigned len, unsigned timeout);
+#endif
+static int acxpci_s_read_phy_reg(acx_device_t *adev, u32 reg, u8 *charbuf);
+static int acxpci_s_write_phy_reg(acx_device_t *adev, u32 reg, u8 value);
+static tx_t* acxpci_l_alloc_tx(acx_device_t *adev);
+static void acxpci_l_dealloc_tx(tx_t *tx_opaque);
+static void* acxpci_l_get_txbuf(acx_device_t *adev, tx_t *tx_opaque);
+static void acxpci_l_tx_data(acx_device_t *adev, tx_t *tx_opaque, int len);
+
+#ifdef MODULE_LICENSE
+MODULE_LICENSE("Dual MPL/GPL");
+#endif
+/* USB had this: MODULE_AUTHOR("Martin Wawro <martin.wawro AT uni-dortmund.de>"); */
+MODULE_AUTHOR("ACX100 Open Source Driver development team");
+MODULE_DESCRIPTION("Driver for TI ACX1xx based wireless cards (CardBus/PCI)");
+
 
 /***********************************************************************
 ** Register access
@@ -174,11 +193,13 @@ write_flush(acx_device_t *adev)
 	readb(adev->iobase);
 }
 
-
-/***********************************************************************
-*/
-static struct net_device *root_adev_newest = NULL;
-DECLARE_MUTEX(root_adev_sem);
+INLINE_IO int
+adev_present(acx_device_t *adev)
+{
+	/* fast version (accesses the first register, IO_ACX_SOFT_RESET,
+	 * which should be safe): */
+	return readl(adev->iobase) != 0xffffffff;
+}
 
 
 /***********************************************************************
@@ -406,7 +427,7 @@ end:
 ** Messing with rx/tx disabling and enabling here
 ** (write_reg32(adev, IO_ACX_ENABLE, 0b000000xx)) kills traffic
 */
-int
+static int
 acxpci_s_read_phy_reg(acx_device_t *adev, u32 reg, u8 *charbuf)
 {
 	int result = NOT_OK;
@@ -447,7 +468,7 @@ fail:
 
 /***********************************************************************
 */
-int
+static int
 acxpci_s_write_phy_reg(acx_device_t *adev, u32 reg, u8 value)
 {
 	FN_ENTER;
@@ -1001,8 +1022,8 @@ end:
 #undef FUNC
 #define FUNC "issue_cmd"
 
+static int
 #if !ACX_DEBUG
-int
 acxpci_s_issue_cmd_timeo(
 	acx_device_t *adev,
 	unsigned int cmd,
@@ -1011,7 +1032,6 @@ acxpci_s_issue_cmd_timeo(
 	unsigned cmd_timeout)
 {
 #else
-int
 acxpci_s_issue_cmd_timeo_debug(
 	acx_device_t *adev,
 	unsigned cmd,
@@ -1058,13 +1078,13 @@ acxpci_s_issue_cmd_timeo_debug(
 		/* Test for IDLE state */
 		if (!cmd_status)
 			break;
-		if (counter % 5 == 0) {
+		if (counter % 8 == 0) {
 			if (time_after(jiffies, timeout)) {
 				counter = 0;
 				break;
 			}
-			/* we waited 5 iterations, no luck. Sleep 5 ms */
-			acx_s_msleep(5);
+			/* we waited 8 iterations, no luck. Sleep 8 ms */
+			acx_s_msleep(8);
 		}
 	} while (likely(--counter));
 
@@ -1124,13 +1144,13 @@ acxpci_s_issue_cmd_timeo_debug(
 				break;
 		}
 
-		if (counter % 5 == 0) {
+		if (counter % 8 == 0) {
 			if (time_after(jiffies, timeout)) {
 				counter = 0;
 				break;
 			}
-			/* we waited 5 iterations, no luck. Sleep 5 ms */
-			acx_s_msleep(5);
+			/* we waited 8 iterations, no luck. Sleep 8 ms */
+			acx_s_msleep(8);
 		}
 	} while (likely(--counter));
 
@@ -1273,62 +1293,6 @@ acx_show_card_eeprom_id(acx_device_t *ad
 
 
 /***********************************************************************
-*/
-static void
-acxpci_s_device_chain_add(struct net_device *ndev)
-{
-	acx_device_t *adev = ndev2adev(ndev);
-
-	down(&root_adev_sem);
-	adev->prev_nd = root_adev_newest;
-	root_adev_newest = ndev;
-	adev->ndev = ndev;
-	up(&root_adev_sem);
-}
-
-static void
-acxpci_s_device_chain_remove(struct net_device *ndev)
-{
-	struct net_device *querydev;
-	struct net_device *olderdev;
-	struct net_device *newerdev;
-
-	down(&root_adev_sem);
-	querydev = root_adev_newest;
-	newerdev = NULL;
-	while (querydev) {
-		olderdev = ndev2adev(querydev)->prev_nd;
-		if (0 == strcmp(querydev->name, ndev->name)) {
-			if (!newerdev) {
-				/* if we were at the beginning of the
-				 * list, then it's the list head that
-				 * we need to update to point at the
-				 * next older device */
-				root_adev_newest = olderdev;
-			} else {
-				/* it's the device that is newer than us
-				 * that we need to update to point at
-				 * the device older than us */
-				ndev2adev(newerdev)->prev_nd = olderdev;
-			}
-			break;
-		}
-		/* "newerdev" is actually the device of the old iteration,
-		 * but since the list starts (root_adev_newest)
-		 * with the newest devices,
-		 * it's newer than the ones following.
-		 * Oh the joys of iterating from newest to oldest :-\ */
-		newerdev = querydev;
-
-		/* keep checking old devices for matches until we hit the end
-		 * of the list */
-		querydev = olderdev;
-	}
-	up(&root_adev_sem);
-}
-
-
-/***********************************************************************
 ** acxpci_free_desc_queues
 **
 ** Releases the queues that have been allocated, the
@@ -1617,6 +1581,7 @@ acxpci_e_probe(struct pci_dev *pdev, con
 	** just _presume_ that we're under sem (instead of actually taking it): */
 	/* acx_sem_lock(adev); */
 	adev->pdev = pdev;
+	adev->ndev = ndev;
 	adev->dev_type = DEVTYPE_PCI;
 	adev->chip_type = chip_type;
 	adev->chip_name = chip_name;
@@ -1645,6 +1610,24 @@ acxpci_e_probe(struct pci_dev *pdev, con
 	adev->ieee->sec.enabled = 0;
 	adev->ieee->sec.auth_mode = WLAN_AUTH_OPEN;
 
+	if (IS_ACX100(adev)) {
+		adev->ops.create_dma_regions = acx100_s_create_dma_regions;
+	} else {
+		adev->ops.create_dma_regions = acx111_s_create_dma_regions;
+	}
+	adev->ops.delete_dma_regions = acxpci_s_delete_dma_regions;
+#if ACX_DEBUG
+	adev->ops.issue_cmd = acxpci_s_issue_cmd_timeo_debug;
+#else
+	adev->ops.issue_cmd  = acxpci_s_issue_cmd_timeo;
+#endif /* ACX_DEBUG */
+	adev->ops.alloc_tx = acxpci_l_alloc_tx;
+	adev->ops.dealloc_tx = acxpci_l_dealloc_tx;
+	adev->ops.get_txbuf = acxpci_l_get_txbuf;
+	adev->ops.tx_data = acxpci_l_tx_data;
+	adev->ops.write_phy_reg = acxpci_s_write_phy_reg;
+	adev->ops.read_phy_reg = acxpci_s_read_phy_reg;
+
 #ifdef NONESSENTIAL_FEATURES
 	acx_show_card_eeprom_id(adev);
 #endif /* NONESSENTIAL_FEATURES */
@@ -1654,9 +1637,6 @@ acxpci_e_probe(struct pci_dev *pdev, con
 #endif
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
-	/* register new dev in linked list */
-	acxpci_s_device_chain_add(ndev);
-
 	log(L_IRQ|L_INIT, "using IRQ %d\n", pdev->irq);
 
 	/* need to be able to restore PCI state after a suspend */
@@ -1731,7 +1711,6 @@ fail_register_netdev:
 fail_init_mac:
 fail_reset:
 
-	acxpci_s_device_chain_remove(ndev);
 	free_netdev(ndev);
 fail_alloc_netdev:
 fail_irq:
@@ -1765,11 +1744,8 @@ done:
 /***********************************************************************
 ** acxpci_e_remove
 **
-** Deallocate PCI resources for the acx chip.
-**
-** This should NOT execute any other hardware operations on the card,
-** since the card might already be ejected. Instead, that should be done
-** in cleanup_module, since the card is most likely still available there.
+** Shut device down (if not hot unplugged)
+** and deallocate PCI resources for the acx chip.
 **
 ** pdev - ptr to PCI device structure containing info about pci configuration
 */
@@ -1779,6 +1755,7 @@ acxpci_e_remove(struct pci_dev *pdev)
 	struct net_device *ndev;
 	acx_device_t *adev;
 	unsigned long mem_region1, mem_region2;
+	unsigned long flags;
 
 	FN_ENTER;
 
@@ -1791,6 +1768,43 @@ acxpci_e_remove(struct pci_dev *pdev)
 
 	adev = ndev2adev(ndev);
 
+	/* If device wasn't hot unplugged... */
+	if (adev_present(adev)) {
+
+		acx_sem_lock(adev);
+
+		/* disable both Tx and Rx to shut radio down properly */
+		acx_s_issue_cmd(adev, ACX1xx_CMD_DISABLE_TX, NULL, 0);
+		acx_s_issue_cmd(adev, ACX1xx_CMD_DISABLE_RX, NULL, 0);
+
+#ifdef REDUNDANT
+		/* put the eCPU to sleep to save power
+		 * Halting is not possible currently,
+		 * since not supported by all firmware versions */
+		acx_s_issue_cmd(adev, ACX100_CMD_SLEEP, NULL, 0);
+#endif
+		acx_lock(adev, flags);
+		/* disable power LED to save power :-) */
+		log(L_INIT, "switching off power LED to save power\n");
+		acxpci_l_power_led(adev, 0);
+		/* stop our eCPU */
+		if (IS_ACX111(adev)) {
+			/* FIXME: does this actually keep halting the eCPU?
+			 * I don't think so...
+			 */
+			acxpci_l_reset_mac(adev);
+		} else {
+			u16 temp;
+			/* halt eCPU */
+			temp = read_reg16(adev, IO_ACX_ECPU_CTRL) | 0x1;
+			write_reg16(adev, IO_ACX_ECPU_CTRL, temp);
+			write_flush(adev);
+		}
+		acx_unlock(adev, flags);
+
+		acx_sem_unlock(adev);
+	}
+
 	/* unregister the device to not let the kernel
 	 * (e.g. ioctls) access a half-deconfigured device
 	 * NB: this will cause acxpci_e_close() to be called,
@@ -1802,6 +1816,13 @@ acxpci_e_remove(struct pci_dev *pdev)
 	 * For paranoid reasons we continue to follow the rules */
 	acx_sem_lock(adev);
 
+	if (adev->dev_state_mask & ACX_STATE_IFACE_UP) {
+		acxpci_s_down(ndev);
+		CLEAR_BIT(adev->dev_state_mask, ACX_STATE_IFACE_UP);
+	}
+
+	acx_proc_unregister_entries(ndev);
+
 	if (IS_ACX100(adev)) {
 		mem_region1 = PCI_ACX100_REGION1;
 		mem_region2 = PCI_ACX100_REGION2;
@@ -1810,33 +1831,21 @@ acxpci_e_remove(struct pci_dev *pdev)
 		mem_region2 = PCI_ACX111_REGION2;
 	}
 
-	acx_proc_unregister_entries(ndev);
-
-	/* find our PCI device in the global acx list and remove it */
-	acxpci_s_device_chain_remove(ndev);
-
-	if (adev->dev_state_mask & ACX_STATE_IFACE_UP)
-		acxpci_s_down(ndev);
-
-	CLEAR_BIT(adev->dev_state_mask, ACX_STATE_IFACE_UP);
-
-	acxpci_s_delete_dma_regions(adev);
-
 	/* finally, clean up PCI bus state */
+	acxpci_s_delete_dma_regions(adev);
 	if (adev->iobase) iounmap(adev->iobase);
 	if (adev->iobase2) iounmap(adev->iobase2);
-
 	release_mem_region(pci_resource_start(pdev, mem_region1),
 			   pci_resource_len(pdev, mem_region1));
-
 	release_mem_region(pci_resource_start(pdev, mem_region2),
 			   pci_resource_len(pdev, mem_region2));
-
 	pci_disable_device(pdev);
 
 	/* remove dev registration */
 	pci_set_drvdata(pdev, NULL);
 
+	acx_sem_unlock(adev);
+
 	/* Free netdev (quite late,
 	 * since otherwise we might get caught off-guard
 	 * by a netdev timeout handler execution
@@ -2008,10 +2017,10 @@ acxpci_s_up(struct net_device *ndev)
 /***********************************************************************
 ** acxpci_s_down
 **
-** This disables the netdevice
+** NB: device may be already hot unplugged if called from acxpci_e_remove()
 **
-** Side effects:
-** - disables on-card interrupt request
+** Disables on-card interrupt request, stops softirq and timer, stops queue,
+** sets status == STOPPED
 */
 
 static void
@@ -2298,7 +2307,7 @@ static void
 acxpci_l_process_rxdesc(acx_device_t *adev)
 {
 	register rxhostdesc_t *hostdesc;
-	int count, tail;
+	unsigned count, tail;
 
 	FN_ENTER;
 
@@ -3026,11 +3035,11 @@ acx100pci_ioctl_set_phy_amp_bias(
 ** after figuring out how many we need and whether we still have
 ** sufficiently many.
 */
-tx_t*
+static tx_t*
 acxpci_l_alloc_tx(acx_device_t *adev)
 {
 	struct txdesc *txdesc;
-	int head;
+	unsigned head;
 	u8 ctl8;
 
 	FN_ENTER;
@@ -3078,10 +3087,15 @@ end:
 	return (tx_t*)txdesc;
 }
 
+/* Dummy function. */
+static void
+acxpci_l_dealloc_tx(tx_t *tx_opaque)
+{
+}
 
 /***********************************************************************
 */
-void*
+static void*
 acxpci_l_get_txbuf(acx_device_t *adev, tx_t* tx_opaque)
 {
 	return get_txhostdesc(adev, (txdesc_t*)tx_opaque)->data;
@@ -3098,7 +3112,7 @@ acxpci_l_get_txbuf(acx_device_t *adev, t
 ** pre-allocated tx descrs, properly setting up transfer data and
 ** CTL_xxx flags according to fragment number.
 */
-void
+static void
 acxpci_l_tx_data(acx_device_t *adev, tx_t* tx_opaque, int len)
 {
 	txdesc_t *txdesc = (txdesc_t*)tx_opaque;
@@ -3391,7 +3405,7 @@ unsigned int
 acxpci_l_clean_txdesc(acx_device_t *adev)
 {
 	txdesc_t *txdesc;
-	int finger;
+	unsigned finger;
 	int num_cleaned;
 	u16 r111;
 	u8 error, ack_failures, rts_failures, rts_ok, r100;
@@ -4213,70 +4227,12 @@ acxpci_e_init_module(void)
 void __exit
 acxpci_e_cleanup_module(void)
 {
-	struct net_device *ndev;
-	unsigned long flags;
-
 	FN_ENTER;
 
-	/* Since the whole module is about to be unloaded,
-	 * we recursively shutdown all cards we handled instead
-	 * of doing it in acxpci_e_remove() (which will be activated by us
-	 * via pci_unregister_driver at the end).
-	 * acxpci_e_remove() might just get called after a card eject,
-	 * that's why hardware operations have to be done here instead
-	 * when the hardware is available. */
-
-	down(&root_adev_sem);
-
-	ndev = root_adev_newest;
-	while (ndev) {
-		acx_device_t *adev = ndev2adev(ndev);
-
-		acx_sem_lock(adev);
-
-		/* disable both Tx and Rx to shut radio down properly */
-		acx_s_issue_cmd(adev, ACX1xx_CMD_DISABLE_TX, NULL, 0);
-		acx_s_issue_cmd(adev, ACX1xx_CMD_DISABLE_RX, NULL, 0);
-
-#ifdef REDUNDANT
-		/* put the eCPU to sleep to save power
-		 * Halting is not possible currently,
-		 * since not supported by all firmware versions */
-		acx_s_issue_cmd(adev, ACX100_CMD_SLEEP, NULL, 0);
-#endif
-		acx_lock(adev, flags);
-
-		/* disable power LED to save power :-) */
-		log(L_INIT, "switching off power LED to save power\n");
-		acxpci_l_power_led(adev, 0);
-
-		/* stop our eCPU */
-		if (IS_ACX111(adev)) {
-			/* FIXME: does this actually keep halting the eCPU?
-			 * I don't think so...
-			 */
-			acxpci_l_reset_mac(adev);
-		} else {
-			u16 temp;
-
-			/* halt eCPU */
-			temp = read_reg16(adev, IO_ACX_ECPU_CTRL) | 0x1;
-			write_reg16(adev, IO_ACX_ECPU_CTRL, temp);
-			write_flush(adev);
-		}
-
-		acx_unlock(adev, flags);
-
-		acx_sem_unlock(adev);
-
-		ndev = adev->prev_nd;
-	}
-
-	up(&root_adev_sem);
-
-	/* now let the PCI layer recursively remove
-	 * all PCI related things (acxpci_e_remove()) */
 	pci_unregister_driver(&acxpci_drv_id);
 
 	FN_EXIT0;
 }
+
+module_init(acxpci_e_init_module);
+module_exit(acxpci_e_cleanup_module);
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/usb.c wireless-2.6.git.acx/drivers/net/wireless/tiacx/usb.c
--- wireless-2.6.git/drivers/net/wireless/tiacx/usb.c	Wed Mar  1 07:56:14 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/usb.c	Wed Mar  1 12:05:04 2006
@@ -123,10 +123,30 @@ static void acxusb_l_poll_rx(acx_device_
 
 static void acxusb_i_tx_timeout(struct net_device *);
 
+#if ACX_DEBUG
+static int acxusb_s_issue_cmd_timeo_debug(acx_device_t *adev, unsigned cmd, void *param, unsigned len, unsigned timeout, const char* cmdstr);
+#else
+static int acxusb_s_issue_cmd_timeo(acx_device_t *adev, unsigned cmd, void *param, unsigned len, unsigned timeout);
+#endif
+static int acxusb_s_read_phy_reg(acx_device_t *adev, u32 reg, u8 *charbuf);
+static int acxusb_s_write_phy_reg(acx_device_t *adev, u32 reg, u8 value);
+static tx_t* acxusb_l_alloc_tx(acx_device_t *adev);
+static void acxusb_l_dealloc_tx(tx_t *tx_opaque);
+static void* acxusb_l_get_txbuf(acx_device_t *adev, tx_t *tx_opaque);
+static void acxusb_l_tx_data(acx_device_t *adev, tx_t *tx_opaque, int len);
+
 /* static void dump_device(struct usb_device *); */
 /* static void dump_device_descriptor(struct usb_device_descriptor *); */
 /* static void dump_config_descriptor(struct usb_config_descriptor *); */
 
+#ifdef MODULE_LICENSE
+MODULE_LICENSE("Dual MPL/GPL");
+#endif
+/* USB had this: MODULE_AUTHOR("Martin Wawro <martin.wawro AT uni-dortmund.de>"); */
+MODULE_AUTHOR("ACX100 Open Source Driver development team");
+MODULE_DESCRIPTION("Driver for TI ACX1xx based wireless cards (USB)");
+
+
 /***********************************************************************
 ** Module Data
 */
@@ -150,6 +170,7 @@ acxusb_ids[] = {
 	{}
 };
 
+MODULE_DEVICE_TABLE(usb, acxusb_ids);
 
 /* USB driver data structure as required by the kernel's USB core */
 static struct usb_driver
@@ -211,7 +232,7 @@ acxusb_unlink_urb(struct urb* urb)
 /***********************************************************************
 ** acxusb_s_read_phy_reg
 */
-int
+static int
 acxusb_s_read_phy_reg(acx_device_t *adev, u32 reg, u8 *charbuf)
 {
 	/* mem_read_write_t mem; */
@@ -236,7 +257,7 @@ acxusb_s_read_phy_reg(acx_device_t *adev
 
 /***********************************************************************
 */
-int
+static int
 acxusb_s_write_phy_reg(acx_device_t *adev, u32 reg, u8 value)
 {
 	mem_read_write_t mem;
@@ -270,17 +291,15 @@ acxusb_s_write_phy_reg(acx_device_t *ade
 #undef FUNC
 #define FUNC "issue_cmd"
 
+static int
 #if !ACX_DEBUG
-int
 acxusb_s_issue_cmd_timeo(
 	acx_device_t *adev,
 	unsigned cmd,
 	void *buffer,
 	unsigned buflen,
 	unsigned timeout)
-{
 #else
-int
 acxusb_s_issue_cmd_timeo_debug(
 	acx_device_t *adev,
 	unsigned cmd,
@@ -288,8 +307,8 @@ acxusb_s_issue_cmd_timeo_debug(
 	unsigned buflen,
 	unsigned timeout,
 	const char* cmdstr)
-{
 #endif
+{
 	/* USB ignores timeout param */
 
 	struct usb_device *usbdev;
@@ -754,6 +773,11 @@ acxusb_s_fill_configoption(acx_device_t 
 	return OK;
 }
 
+/* Dummy function. */
+static void
+acxusb_s_delete_dma_regions(acx_device_t *adev)
+{
+}
 
 /***********************************************************************
 ** acxusb_e_probe()
@@ -882,6 +906,20 @@ acxusb_e_probe(struct usb_interface *int
 	adev->ieee->sec.encrypt = 0;
 	adev->ieee->sec.auth_mode = WLAN_AUTH_OPEN;
 
+	adev->ops.create_dma_regions = acx100_s_create_dma_regions;
+	adev->ops.delete_dma_regions = acxusb_s_delete_dma_regions;
+#if ACX_DEBUG
+	adev->ops.issue_cmd = acxusb_s_issue_cmd_timeo_debug;
+#else
+	adev->ops.issue_cmd  = acxusb_s_issue_cmd_timeo;
+#endif /* ACX_DEBUG */
+	adev->ops.alloc_tx = acxusb_l_alloc_tx;
+	adev->ops.dealloc_tx = acxusb_l_dealloc_tx;
+	adev->ops.get_txbuf = acxusb_l_get_txbuf;
+	adev->ops.tx_data = acxusb_l_tx_data;
+	adev->ops.write_phy_reg = acxusb_s_write_phy_reg;
+	adev->ops.read_phy_reg = acxusb_s_read_phy_reg;
+
 	/* Check that this is really the hardware we know about.
 	** If not sure, at least notify the user that he
 	** may be in trouble...
@@ -1582,11 +1620,11 @@ end_unlock:
 ** acxusb_l_alloc_tx
 ** Actually returns a usb_tx_t* ptr
 */
-tx_t*
+static tx_t*
 acxusb_l_alloc_tx(acx_device_t *adev)
 {
 	usb_tx_t *tx;
-	int head;
+	unsigned head;
 
 	FN_ENTER;
 
@@ -1620,7 +1658,7 @@ end:
 /***************************************************************
 ** Used if alloc_tx()'ed buffer needs to be cancelled without doing tx
 */
-void
+static void
 acxusb_l_dealloc_tx(tx_t *tx_opaque)
 {
 	usb_tx_t* tx = (usb_tx_t*)tx_opaque;
@@ -1630,7 +1668,7 @@ acxusb_l_dealloc_tx(tx_t *tx_opaque)
 
 /***************************************************************
 */
-void*
+static void*
 acxusb_l_get_txbuf(acx_device_t *adev, tx_t* tx_opaque)
 {
 	usb_tx_t* tx = (usb_tx_t*)tx_opaque;
@@ -1644,7 +1682,7 @@ acxusb_l_get_txbuf(acx_device_t *adev, t
 ** Can be called from IRQ (rx -> (AP bridging or mgmt response) -> tx).
 ** Can be called from acx_i_start_xmit (data frames from net core).
 */
-void
+static void
 acxusb_l_tx_data(acx_device_t *adev, tx_t* tx_opaque, int wlanpkt_len)
 {
 	struct usb_device *usbdev;
@@ -1810,7 +1848,8 @@ acxusb_e_cleanup_module()
 	usb_deregister(&acxusb_driver);
 }
 
-
+module_init(acxusb_e_init_module);
+module_exit(acxusb_e_cleanup_module);
 /***********************************************************************
 ** DEBUG STUFF
 */

--Boundary-00=_2haBEtfkNFFAN5G--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
