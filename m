From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 07/13] rocker: introduce OF-DPA world skeleton
Date: Mon,  5 Oct 2015 19:44:00 +0200
Message-ID: <1444067046-27825-8-git-send-email-jiri@resnulli.us>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33576 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbbJERoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:44:18 -0400
Received: by wiclk2 with SMTP id lk2so132054926wic.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:44:17 -0700 (PDT)
In-Reply-To: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce basis for OF-DPA world file. This is the place where all
OF-DPA related code is going to be moved.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/Makefile       |  2 +-
 drivers/net/ethernet/rocker/rocker.h       |  2 ++
 drivers/net/ethernet/rocker/rocker_main.c  |  1 +
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 27 +++++++++++++++++++++++++++
 4 files changed, 31 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/rocker/rocker_ofdpa.c

diff --git a/drivers/net/ethernet/rocker/Makefile b/drivers/net/ethernet/rocker/Makefile
index 47f3492..faa36ac 100644
--- a/drivers/net/ethernet/rocker/Makefile
+++ b/drivers/net/ethernet/rocker/Makefile
@@ -3,4 +3,4 @@
 #
 
 obj-$(CONFIG_ROCKER) += rocker.o
-rocker-y := rocker_main.o rocker_tlv.o
+rocker-y := rocker_main.o rocker_tlv.o rocker_ofdpa.o
diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index d49bc5d..496fe8f 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -80,4 +80,6 @@ struct rocker_world_ops {
 				     __be16 vlan_id);
 };
 
+extern struct rocker_world_ops rocker_ofdpa_ops;
+
 #endif
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 3bfb9e9..d950348 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2171,6 +2171,7 @@ static int rocker_cmd_group_tbl_del(const struct rocker_port *rocker_port,
  **********************/
 
 static struct rocker_world_ops *rocker_world_ops[] = {
+	&rocker_ofdpa_ops,
 };
 
 #define ROCKER_WORLD_OPS_LEN ARRAY_SIZE(rocker_world_ops)
diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
new file mode 100644
index 0000000..e048b8b
--- /dev/null
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -0,0 +1,27 @@
+/*
+ * drivers/net/ethernet/rocker/rocker_ofdpa.c - Rocker switch OF-DPA-like
+ *					        implementation
+ * Copyright (c) 2014 Scott Feldman <sfeldma@gmail.com>
+ * Copyright (c) 2014-2015 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include "rocker.h"
+
+struct ofdpa {
+};
+
+struct ofdpa_port {
+};
+
+struct rocker_world_ops rocker_ofdpa_ops = {
+	.kind = "ofdpa",
+	.priv_size = sizeof(struct ofdpa),
+	.port_priv_size = sizeof(struct ofdpa_port),
+	.mode = ROCKER_PORT_MODE_OF_DPA,
+};
-- 
1.9.3
