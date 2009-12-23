From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] ethtool: add support for at76c50x-usb driver
Date: Wed, 23 Dec 2009 09:29:47 -0500
Message-ID: <1261578587-3547-1-git-send-email-linville@tuxdriver.com>
Cc: Jeff Garzik <jeff@garzik.org>, Kalle Valo <kalle.valo@iki.fi>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37083 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803AbZLWOan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 09:30:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 Makefile.am    |    2 +-
 at76c50x-usb.c |   32 ++++++++++++++++++++++++++++++++
 ethtool-util.h |    2 ++
 ethtool.c      |    1 +
 4 files changed, 36 insertions(+), 1 deletions(-)
 create mode 100644 at76c50x-usb.c

diff --git a/Makefile.am b/Makefile.am
index eac65fe..a384949 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -8,7 +8,7 @@ ethtool_SOURCES = ethtool.c ethtool-copy.h ethtool-util.h	\
 		  amd8111e.c de2104x.c e100.c e1000.c igb.c	\
 		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
-		  smsc911x.c
+		  smsc911x.c at76c50x-usb.c
 
 dist-hook:
 	cp $(top_srcdir)/ethtool.spec $(distdir)
diff --git a/at76c50x-usb.c b/at76c50x-usb.c
new file mode 100644
index 0000000..241618c
--- /dev/null
+++ b/at76c50x-usb.c
@@ -0,0 +1,32 @@
+#include <stdio.h>
+#include "ethtool-util.h"
+
+static char *hw_versions[] = {
+        "503_ISL3861",
+        "503_ISL3863",
+        "        503",
+        "    503_ACC",
+        "        505",
+        "   505_2958",
+        "       505A",
+        "     505AMX",
+};
+
+int
+at76c50x_usb_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	u8 version = (u8)(regs->version >> 24);
+	u8 rev_id = (u8)(regs->version);
+	char *ver_string;
+
+	if(version != 0)
+		return -1;
+
+	ver_string = hw_versions[rev_id];
+	fprintf(stdout,
+		"Hardware Version                    %s\n",
+		ver_string);
+
+	return 0;
+}
+
diff --git a/ethtool-util.h b/ethtool-util.h
index 8ae7e47..bc66df7 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -67,4 +67,6 @@ int vioc_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 /* SMSC LAN911x/LAN921x embedded ethernet controller */
 int smsc911x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
+int at76c50x_usb_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
+
 #endif
diff --git a/ethtool.c b/ethtool.c
index 298b690..4b750a4 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1255,6 +1255,7 @@ static struct {
 	{ "sky2", sky2_dump_regs },
         { "vioc", vioc_dump_regs },
         { "smsc911x", smsc911x_dump_regs },
+        { "at76c50x-usb", at76c50x_usb_dump_regs },
 };
 
 static int dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
-- 
1.6.2.5

