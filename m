From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] tiacx sparse cleanups
Date: Mon, 7 Aug 2006 11:20:33 -0700
Message-ID: <20060807112033.193f03d0.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vda.linux@googlemail.com, akpm <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:15784 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S932084AbWHGSRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 14:17:53 -0400
Received: from midway.site ([71.117.253.75]) by xenotime.net for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 11:17:49 -0700
To: acx100-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

tiacx sparse cleanups:
- use NULL instead of 0 for pointer value
- use C99 struct initializers
- use ANSI function declaration

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/net/wireless/tiacx/common.c |    2 
 drivers/net/wireless/tiacx/ioctl.c  |  202 ++++++++++++++++++------------------
 drivers/net/wireless/tiacx/pci.c    |    2 
 drivers/net/wireless/tiacx/usb.c    |    2 
 4 files changed, 104 insertions(+), 104 deletions(-)


--- linux-2618-rc3mm2.orig/drivers/net/wireless/tiacx/common.c
+++ linux-2618-rc3mm2/drivers/net/wireless/tiacx/common.c
@@ -1396,7 +1396,7 @@ manage_proc_entries(const struct net_dev
 		log(L_INIT, "%sing /proc entry %s\n",
 			remove ? "remov" : "creat", procbuf);
 		if (!remove) {
-			if (!create_proc_read_entry(procbuf, 0, 0, proc_funcs[i], adev)) {
+			if (!create_proc_read_entry(procbuf, 0, NULL, proc_funcs[i], adev)) {
 				printk("acx: cannot register /proc entry %s\n", procbuf);
 				return NOT_OK;
 			}
--- linux-2618-rc3mm2.orig/drivers/net/wireless/tiacx/ioctl.c
+++ linux-2618-rc3mm2/drivers/net/wireless/tiacx/ioctl.c
@@ -2163,7 +2163,7 @@ acx_ioctl_set_rates(struct net_device *n
 
 	log(L_IOCTL, "set_rates %s\n", extra);
 	result = fill_ratemasks(extra, &brate, &orate,
-				acx111_supported, acx111_gen_mask, 0);
+				acx111_supported, acx111_gen_mask, NULL);
 	if (result) goto end;
 	SET_BIT(orate, brate);
 	log(L_IOCTL, "brate %08X orate %08X\n", brate, orate);
@@ -2615,107 +2615,107 @@ static const iw_handler acx_ioctl_privat
 
 static const struct iw_priv_args acx_ioctl_private_args[] = {
 #if ACX_DEBUG
-{ cmd : ACX100_IOCTL_DEBUG,
-	set_args : IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	get_args : 0,
-	name : "SetDebug" },
+{	.cmd = ACX100_IOCTL_DEBUG,
+	.set_args = IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	.get_args = 0,
+	.name = "SetDebug" },
 #endif
-{ cmd : ACX100_IOCTL_SET_PLED,
-	set_args : IW_PRIV_TYPE_BYTE | 2,
-	get_args : 0,
-	name : "SetLEDPower" },
-{ cmd : ACX100_IOCTL_GET_PLED,
-	set_args : 0,
-	get_args : IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 2,
-	name : "GetLEDPower" },
-{ cmd : ACX100_IOCTL_SET_RATES,
-	set_args : IW_PRIV_TYPE_CHAR | 256,
-	get_args : 0,
-	name : "SetRates" },
-{ cmd : ACX100_IOCTL_LIST_DOM,
-	set_args : 0,
-	get_args : 0,
-	name : "ListRegDomain" },
-{ cmd : ACX100_IOCTL_SET_DOM,
-	set_args : IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
-	get_args : 0,
-	name : "SetRegDomain" },
-{ cmd : ACX100_IOCTL_GET_DOM,
-	set_args : 0,
-	get_args : IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
-	name : "GetRegDomain" },
-{ cmd : ACX100_IOCTL_SET_SCAN_PARAMS,
-	set_args : IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 4,
-	get_args : 0,
-	name : "SetScanParams" },
-{ cmd : ACX100_IOCTL_GET_SCAN_PARAMS,
-	set_args : 0,
-	get_args : IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 4,
-	name : "GetScanParams" },
-{ cmd : ACX100_IOCTL_SET_PREAMB,
-	set_args : IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
-	get_args : 0,
-	name : "SetSPreamble" },
-{ cmd : ACX100_IOCTL_GET_PREAMB,
-	set_args : 0,
-	get_args : IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
-	name : "GetSPreamble" },
-{ cmd : ACX100_IOCTL_SET_ANT,
-	set_args : IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
-	get_args : 0,
-	name : "SetAntenna" },
-{ cmd : ACX100_IOCTL_GET_ANT,
-	set_args : 0,
-	get_args : 0,
-	name : "GetAntenna" },
-{ cmd : ACX100_IOCTL_RX_ANT,
-	set_args : IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
-	get_args : 0,
-	name : "SetRxAnt" },
-{ cmd : ACX100_IOCTL_TX_ANT,
-	set_args : IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
-	get_args : 0,
-	name : "SetTxAnt" },
-{ cmd : ACX100_IOCTL_SET_PHY_AMP_BIAS,
-	set_args : IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
-	get_args : 0,
-	name : "SetPhyAmpBias"},
-{ cmd : ACX100_IOCTL_GET_PHY_CHAN_BUSY,
-	set_args : 0,
-	get_args : 0,
-	name : "GetPhyChanBusy" },
-{ cmd : ACX100_IOCTL_SET_ED,
-	set_args : IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	get_args : 0,
-	name : "SetED" },
-{ cmd : ACX100_IOCTL_SET_CCA,
-	set_args : IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
-	get_args : 0,
-	name : "SetCCA" },
-{ cmd : ACX100_IOCTL_MONITOR,
-	set_args : IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 2,
-	get_args : 0,
-	name : "monitor" },
-{ cmd : ACX100_IOCTL_TEST,
-	set_args : 0,
-	get_args : 0,
-	name : "Test" },
-{ cmd : ACX100_IOCTL_DBG_SET_MASKS,
-	set_args : IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 2,
-	get_args : 0,
-	name : "DbgSetMasks" },
-{ cmd : ACX111_IOCTL_INFO,
-	set_args : 0,
-	get_args : 0,
-	name : "GetAcx111Info" },
-{ cmd : ACX100_IOCTL_DBG_SET_IO,
-	set_args : IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 4,
-	get_args : 0,
-	name : "DbgSetIO" },
-{ cmd : ACX100_IOCTL_DBG_GET_IO,
-	set_args : IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 3,
-	get_args : 0,
-	name : "DbgGetIO" },
+{	.cmd = ACX100_IOCTL_SET_PLED,
+	.set_args = IW_PRIV_TYPE_BYTE | 2,
+	.get_args = 0,
+	.name = "SetLEDPower" },
+{	.cmd = ACX100_IOCTL_GET_PLED,
+	.set_args = 0,
+	.get_args = IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 2,
+	.name = "GetLEDPower" },
+{	.cmd = ACX100_IOCTL_SET_RATES,
+	.set_args = IW_PRIV_TYPE_CHAR | 256,
+	.get_args = 0,
+	.name = "SetRates" },
+{	.cmd = ACX100_IOCTL_LIST_DOM,
+	.set_args = 0,
+	.get_args = 0,
+	.name = "ListRegDomain" },
+{	.cmd = ACX100_IOCTL_SET_DOM,
+	.set_args = IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
+	.get_args = 0,
+	.name = "SetRegDomain" },
+{	.cmd = ACX100_IOCTL_GET_DOM,
+	.set_args = 0,
+	.get_args = IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
+	.name = "GetRegDomain" },
+{	.cmd = ACX100_IOCTL_SET_SCAN_PARAMS,
+	.set_args = IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 4,
+	.get_args = 0,
+	.name = "SetScanParams" },
+{	.cmd = ACX100_IOCTL_GET_SCAN_PARAMS,
+	.set_args = 0,
+	.get_args = IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 4,
+	.name = "GetScanParams" },
+{	.cmd = ACX100_IOCTL_SET_PREAMB,
+	.set_args = IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
+	.get_args = 0,
+	.name = "SetSPreamble" },
+{	.cmd = ACX100_IOCTL_GET_PREAMB,
+	.set_args = 0,
+	.get_args = IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
+	.name = "GetSPreamble" },
+{	.cmd = ACX100_IOCTL_SET_ANT,
+	.set_args = IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
+	.get_args = 0,
+	.name = "SetAntenna" },
+{	.cmd = ACX100_IOCTL_GET_ANT,
+	.set_args = 0,
+	.get_args = 0,
+	.name = "GetAntenna" },
+{	.cmd = ACX100_IOCTL_RX_ANT,
+	.set_args = IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
+	.get_args = 0,
+	.name = "SetRxAnt" },
+{	.cmd = ACX100_IOCTL_TX_ANT,
+	.set_args = IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
+	.get_args = 0,
+	.name = "SetTxAnt" },
+{	.cmd = ACX100_IOCTL_SET_PHY_AMP_BIAS,
+	.set_args = IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
+	.get_args = 0,
+	.name = "SetPhyAmpBias"},
+{	.cmd = ACX100_IOCTL_GET_PHY_CHAN_BUSY,
+	.set_args = 0,
+	.get_args = 0,
+	.name = "GetPhyChanBusy" },
+{	.cmd = ACX100_IOCTL_SET_ED,
+	.set_args = IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	.get_args = 0,
+	.name = "SetED" },
+{	.cmd = ACX100_IOCTL_SET_CCA,
+	.set_args = IW_PRIV_TYPE_BYTE | IW_PRIV_SIZE_FIXED | 1,
+	.get_args = 0,
+	.name = "SetCCA" },
+{	.cmd = ACX100_IOCTL_MONITOR,
+	.set_args = IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 2,
+	.get_args = 0,
+	.name = "monitor" },
+{	.cmd = ACX100_IOCTL_TEST,
+	.set_args = 0,
+	.get_args = 0,
+	.name = "Test" },
+{	.cmd = ACX100_IOCTL_DBG_SET_MASKS,
+	.set_args = IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 2,
+	.get_args = 0,
+	.name = "DbgSetMasks" },
+{	.cmd = ACX111_IOCTL_INFO,
+	.set_args = 0,
+	.get_args = 0,
+	.name = "GetAcx111Info" },
+{	.cmd = ACX100_IOCTL_DBG_SET_IO,
+	.set_args = IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 4,
+	.get_args = 0,
+	.name = "DbgSetIO" },
+{	.cmd = ACX100_IOCTL_DBG_GET_IO,
+	.set_args = IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 3,
+	.get_args = 0,
+	.name = "DbgGetIO" },
 };
 
 
--- linux-2618-rc3mm2.orig/drivers/net/wireless/tiacx/pci.c
+++ linux-2618-rc3mm2/drivers/net/wireless/tiacx/pci.c
@@ -1351,7 +1351,7 @@ acxpci_free_desc_queues(acx_device_t *ad
 {
 #define ACX_FREE_QUEUE(size, ptr, phyaddr) \
 	if (ptr) { \
-		free_coherent(0, size, ptr, phyaddr); \
+		free_coherent(NULL, size, ptr, phyaddr); \
 		ptr = NULL; \
 		size = 0; \
 	}
--- linux-2618-rc3mm2.orig/drivers/net/wireless/tiacx/usb.c
+++ linux-2618-rc3mm2/drivers/net/wireless/tiacx/usb.c
@@ -1587,7 +1587,7 @@ acxusb_e_init_module(void)
 ** deregisters this module at the kernel's USB subsystem.
 */
 void __exit
-acxusb_e_cleanup_module()
+acxusb_e_cleanup_module(void)
 {
 	usb_deregister(&acxusb_driver);
 }


---
