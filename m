From: Sam Ravnborg <sam@ravnborg.org>
Subject: Wimax - Makefile & Kconfig patch
Date: Sun, 21 Dec 2008 22:59:07 +0100
Message-ID: <20081221215907.GA20856@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pqueuea.post.tele.dk ([193.162.153.9]:56358 "EHLO
	pqueuea.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbYLUV6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 16:58:52 -0500
Received: from pfepb.post.tele.dk (pfepb.post.tele.dk [195.41.46.236])
	by pqueuea.post.tele.dk (Postfix) with ESMTP id 4ED5EDC0A2
	for <netdev@vger.kernel.org>; Sun, 21 Dec 2008 22:58:48 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Inaky.

Noticed your wimax patchset when I browsed netdev on marc.info.
A few comments:

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index f19acf8..3ac378f 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -262,3 +262,4 @@ obj-$(CONFIG_NIU) += niu.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_SFC) += sfc/
 
+obj-y += wimax/

There is no reason to visit this directory if WIMAX is
not enabled so change it to:

obj-$(CONFIG_WIMAX) += wimax/

diff --git a/drivers/net/wimax/i2400m/Kconfig b/drivers/net/wimax/i2400m/Kconfig
new file mode 100644
index 0000000..e977c46
--- /dev/null
+++ b/drivers/net/wimax/i2400m/Kconfig
@@ -0,0 +1,49 @@
+
+config WIMAX_I2400M
+        tristate
+	depends on WIMAX
+        select FW_LOADER
+

Above and in several other spots in the Kconfig
file you mix use of spaces and tabs for ident.
Please use tabs consistent and remember to indent
help text with:
<tab><space><space>

diff --git a/drivers/net/wimax/i2400m/Makefile b/drivers/net/wimax/i2400m/Makefile
new file mode 100644
index 0000000..2e8c15b
--- /dev/null
+++ b/drivers/net/wimax/i2400m/Makefile
@@ -0,0 +1,29 @@
+
+obj-$(CONFIG_WIMAX_I2400M) += i2400m.o
+obj-$(CONFIG_WIMAX_I2400M_USB) += i2400m-usb.o
+obj-$(CONFIG_WIMAX_I2400M_SDIO) += i2400m-sdio.o
+
+i2400m-objs :=		\
+	control.o	\
+	driver.o	\
+	fw.o		\
+	op-rfkill.o	\
+	netdev.o	\
+	tx.o		\
+	rx.o


It is recommended to use:

i2400m-y := control.o
i2400m-y += driver.o

The important point here is that -y is preferred over -objs.

If you use '\' or '+=' is more personal preferences.


	Sam
