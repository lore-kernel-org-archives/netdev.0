From: Carlos Martin <carlos@cmartin.tk>
Subject: [PATCH 1/7] acxsm: Change Kconfig and Makefile to be modular
Date: Tue, 28 Feb 2006 17:30:13 +0100
Message-ID: <11411442131219-git-send-email-carlos@cmartin.tk>
References: <1141144213577-git-send-email-carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Denis Vlasenko <vda@ilport.com.ua>,
	acx100-devel@lists.sourceforge.net,
	Christoph Hellwig <hch@infradead.org>,
	Carlos Martin <carlos@kiopa. (none)>,
	Carlos Martin <carlos@cmartin.tk>
Return-path: <acx100-devel-admin@lists.sourceforge.net>
In-Reply-To: <1141144213577-git-send-email-carlos@cmartin.tk>
To: netdev@vger.kernel.org
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

We now only expose ACX_PCI and ACX_USB and the Makefile creates
acx-usb.ko, acx-pci.ko and acx-common.ko

Signed-off-by: Carlos Martin <carlos@cmartin.tk>

---

 Kconfig  |   40 ++++++++++++++++++++--------------------
 Makefile |   15 +++++++++++----
 2 files changed, 31 insertions(+), 24 deletions(-)

66c1585df6e0969806b9608fb3f006eb1eb02637
diff --git a/Kconfig b/Kconfig
index 8ec3879..ba7889e 100644
--- a/Kconfig
+++ b/Kconfig
@@ -1,6 +1,6 @@
-config ACX
-	tristate "TI acx100/acx111 802.11b/g wireless chipsets"
-	depends on NET_RADIO && EXPERIMENTAL && (USB || PCI)
+config ACX_PCI
+	tristate "TI acx100/acx111 802.11b/g PCI"
+	depends on NET_RADIO && EXPERIMENTAL && PCI
 	select FW_LOADER
 	select IEEE80211
 	select IEEE80211_SOFTMAC
@@ -8,20 +8,7 @@ config ACX
 	A driver for 802.11b/g wireless cards based on
 	Texas Instruments acx100 and acx111 chipsets.
=20
-	This driver supports Host AP mode that allows
-	your computer to act as an IEEE 802.11 access point.
-	This driver is new and experimental.
-
-	Texas Instruments did not take part in development of this driver
-	in any way, shape or form.
-
-	The driver can be compiled as a module and will be named "acx".
-
-config ACX_PCI
-	bool "TI acx100/acx111 802.11b/g PCI"
-	depends on ACX && PCI
-	---help---
-	Include PCI and CardBus support in acx.
+	This is the PCI code.
=20
 	acx chipsets need their firmware loaded at startup.
 	You will need to provide a firmware image via hotplug.
@@ -46,11 +33,20 @@ config ACX_PCI
 	Firmware files are not covered by GPL and are not distributed
 	with this driver for legal reasons.
=20
+	Texas Instruments did not take part in development of this driver
+	in any way, shape or form.
+
 config ACX_USB
-	bool "TI acx100/acx111 802.11b/g USB"
-	depends on ACX && (USB=3Dy || USB=3DACX)
+	tristate "TI acx100/acx111 802.11b/g USB"
+	depends on NET_RADIO && EXPERIMENTAL && USB
+	select FW_LOADER
+	select IEEE80211
+	select IEEE80211_SOFTMAC
 	---help---
-	Include USB support in acx.
+	A driver for 802.11b/g wireless cards based on
+	Texas Instruments acx100 and acx111 chipsets.
+
+	This is the USB code.
=20
 	There is only one currently known device in this category,
 	D-Link DWL-120+, but newer devices seem to be on the horizon.
@@ -63,3 +59,7 @@ config ACX_USB
=20
 	Firmware files are not covered by GPL and are not distributed
 	with this driver for legal reasons.
+
+	Texas Instruments did not take part in development of this driver
+	in any way, shape or form.
+
diff --git a/Makefile b/Makefile
index 192e6d3..8aa56af 100644
--- a/Makefile
+++ b/Makefile
@@ -1,6 +1,13 @@
-obj-$(CONFIG_ACX) +=3D acx.o
+acx-common-y +=3D wlan.o ioctl.o common.o
+acx-usb-y +=3D usb.o
+acx-pci-y +=3D pci.o
=20
-acx-obj-$(CONFIG_ACX_PCI) +=3D pci.o
-acx-obj-$(CONFIG_ACX_USB) +=3D usb.o
+obj-$(CONFIG_ACX_PCI) +=3D acx-common.o acx-pci.o
+obj-$(CONFIG_ACX_USB) +=3D acx-common.o acx-usb.o
=20
-acx-objs :=3D wlan.o ioctl.o common.o $(acx-obj-y)
+#obj-$(CONFIG_ACX) +=3D acx.o
+#
+#acx-obj-$(CONFIG_ACX_PCI) +=3D pci.o
+#acx-obj-$(CONFIG_ACX_USB) +=3D usb.o
+#
+#acx-objs :=3D wlan.o ioctl.o common.o $(acx-obj-y)
--=20
1.2.1.g62a4




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
