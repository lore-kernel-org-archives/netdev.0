From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 04/13] net-caif: add CAIF header files
Date: Wed, 20 Jan 2010 23:55:21 +0100
Message-ID: <1264028130-14364-5-git-send-email-sjur.brandeland@stericsson.com>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:52371 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754273Ab0ATX43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:56:29 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00DPYIDGDL70@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:04 +0100 (CET)
Received: from localhost.localdomain ([84.49.71.7]) by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00LQBICIDUE0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:04 +0100 (CET)
In-reply-to: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Header files for CAIF Socket, Net Device,
and link-layer registration.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/caif_dev.h    |   29 +++++++++++++++++++++++++++++
 include/net/caif/caif_device.h |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 63 insertions(+), 0 deletions(-)

diff --git a/include/net/caif/caif_dev.h b/include/net/caif/caif_dev.h
new file mode 100644
index 0000000..eee7f3a
--- /dev/null
+++ b/include/net/caif/caif_dev.h
@@ -0,0 +1,29 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_DEV_H_
+#define CAIF_DEV_H_
+
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfcnfg.h>
+#include <linux/caif/caif_config.h>
+#include <linux/if.h>
+
+struct caif_service_config;
+int caifdev_adapt_register(struct caif_channel_config *config,
+			   struct layer *adap_layer);
+int caifdev_adapt_unregister(struct layer *adap_layer);
+struct cfcnfg *get_caif_conf(void);
+void caif_register_ioctl(int (*ioctl)(unsigned int cmd,
+				      unsigned long arg,
+				      bool));
+int caif_ioctl(unsigned int cmd, unsigned long arg, bool from_use_land);
+void caif_unregister_netdev(void);
+int channel_config_2_link_param(struct cfcnfg *cnfg,
+				struct caif_channel_config *s,
+				struct cfctrl_link_param *l);
+
+#endif /* CAIF_DEV_H_ */
diff --git a/include/net/caif/caif_device.h b/include/net/caif/caif_device.h
new file mode 100644
index 0000000..6752bb7
--- /dev/null
+++ b/include/net/caif/caif_device.h
@@ -0,0 +1,34 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_DEVICE_H_
+#define CAIF_DEVICE_H_
+#include <linux/kernel.h>
+#include <linux/net.h>
+#include <linux/netdevice.h>
+#include <linux/caif/caif_socket.h>
+#include <net/caif/caif_device.h>
+
+/**
+ * struct caif_dev_common - shared between CAIF drivers and stack .
+ * @flowctrl:		Flow Control callback function.
+ * @link_select:	Indicate bandwidth and latency of device.
+ * @use_frag:		CAIF Frames may be framented.
+ * @use_fcs:		Indicate if Frame CheckSum (fcs) is used.
+ * @use_stx:		Indicate STart of frame eXtension (stx) in use.
+ *
+ * This structure is shared between the CAIF drivers and the CAIF stack.
+ */
+struct caif_dev_common {
+	void (*flowctrl)(struct net_device *net, int on);
+	enum caif_link_selector link_select;
+	int use_frag;
+	int use_fcs;
+	int use_stx;
+};
+
+#endif	/* CAIF_DEVICE_H_ */
+
-- 
1.6.3.3

