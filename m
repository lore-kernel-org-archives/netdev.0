From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 11/12] gigaset: allow building without I4L
Date: Sun,  6 Sep 2009 20:58:52 +0200 (CEST)
Message-ID: <20090906-patch-gigaset-11.tilman@imap.cc>
References: <20090906-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758224AbZIFS7j@vger.kernel.org>
In-Reply-To: <20090906-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a dummy LL interface to the Gigaset driver so that it can be
built and, in a limited way, used without the ISDN4Linux subsystem.

Impact: new configuration alternative
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/Kconfig   |   13 +++++++-
 drivers/isdn/gigaset/Makefile  |    4 ++-
 drivers/isdn/gigaset/dummyll.c |   68 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 83 insertions(+), 2 deletions(-)
 create mode 100644 drivers/isdn/gigaset/dummyll.c

diff --git a/drivers/isdn/gigaset/Kconfig b/drivers/isdn/gigaset/Kconfig
index 18ab865..6fd2dc1 100644
--- a/drivers/isdn/gigaset/Kconfig
+++ b/drivers/isdn/gigaset/Kconfig
@@ -1,6 +1,5 @@
 menuconfig ISDN_DRV_GIGASET
 	tristate "Siemens Gigaset support"
-	depends on ISDN_I4L
 	select CRC_CCITT
 	select BITREVERSE
 	help
@@ -11,9 +10,21 @@ menuconfig ISDN_DRV_GIGASET
 	  If you have one of these devices, say M here and for at least
 	  one of the connection specific parts that follow.
 	  This will build a module called "gigaset".
+	  Note: If you build the ISDN4Linux subsystem (ISDN_I4L)
+	  as a module, you have to build this driver as a module too,
+	  otherwise the Gigaset device won't show up as an ISDN device.
 
 if ISDN_DRV_GIGASET
 
+config GIGASET_I4L
+	bool
+	depends on ISDN_I4L='y'||(ISDN_I4L='m'&&ISDN_DRV_GIGASET='m')
+	default y
+
+config GIGASET_DUMMYLL
+	bool
+	default !GIGASET_I4L
+
 config GIGASET_BASE
 	tristate "Gigaset base station support"
 	depends on USB
diff --git a/drivers/isdn/gigaset/Makefile b/drivers/isdn/gigaset/Makefile
index e9d3189..d429202 100644
--- a/drivers/isdn/gigaset/Makefile
+++ b/drivers/isdn/gigaset/Makefile
@@ -1,4 +1,6 @@
-gigaset-y := common.o interface.o proc.o ev-layer.o i4l.o asyncdata.o
+gigaset-y := common.o interface.o proc.o ev-layer.o asyncdata.o
+gigaset-$(CONFIG_GIGASET_I4L) += i4l.o
+gigaset-$(CONFIG_GIGASET_DUMMYLL) += dummyll.o
 usb_gigaset-y := usb-gigaset.o
 ser_gigaset-y := ser-gigaset.o
 bas_gigaset-y := bas-gigaset.o isocdata.o
diff --git a/drivers/isdn/gigaset/dummyll.c b/drivers/isdn/gigaset/dummyll.c
new file mode 100644
index 0000000..5b27c99
--- /dev/null
+++ b/drivers/isdn/gigaset/dummyll.c
@@ -0,0 +1,68 @@
+/*
+ * Dummy LL interface for the Gigaset driver
+ *
+ * Copyright (c) 2009 by Tilman Schmidt <tilman@imap.cc>.
+ *
+ * =====================================================================
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License as
+ *	published by the Free Software Foundation; either version 2 of
+ *	the License, or (at your option) any later version.
+ * =====================================================================
+ */
+
+#include "gigaset.h"
+
+void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *skb)
+{
+}
+EXPORT_SYMBOL_GPL(gigaset_skb_sent);
+
+void gigaset_skb_rcvd(struct bc_state *bcs, struct sk_buff *skb)
+{
+}
+EXPORT_SYMBOL_GPL(gigaset_skb_rcvd);
+
+void gigaset_isdn_rcv_err(struct bc_state *bcs)
+{
+}
+EXPORT_SYMBOL_GPL(gigaset_isdn_rcv_err);
+
+int gigaset_isdn_icall(struct at_state_t *at_state)
+{
+	return ICALL_IGNORE;
+}
+
+void gigaset_isdn_connD(struct bc_state *bcs)
+{
+}
+
+void gigaset_isdn_hupD(struct bc_state *bcs)
+{
+}
+
+void gigaset_isdn_connB(struct bc_state *bcs)
+{
+}
+
+void gigaset_isdn_hupB(struct bc_state *bcs)
+{
+}
+
+void gigaset_isdn_start(struct cardstate *cs)
+{
+}
+
+void gigaset_isdn_stop(struct cardstate *cs)
+{
+}
+
+int gigaset_isdn_register(struct cardstate *cs, const char *isdnid)
+{
+	pr_info("no ISDN subsystem interface\n");
+	return 1;
+}
+
+void gigaset_isdn_unregister(struct cardstate *cs)
+{
+}
-- 
1.6.2.1.214.ge986c
