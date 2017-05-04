From: Leon Romanovsky <leon@kernel.org>
Subject: [RFC iproute2 6/8] rdma: add stubs for future objects
Date: Thu,  4 May 2017 21:02:14 +0300
Message-ID: <20170504180216.7665-7-leon@kernel.org>
References: <20170504180216.7665-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Ram Amrani <ram.amrani@cavium.com>,
        Bart Van Assche <Bart.VanAssche@sandisk.com>,
        Sagi Grimberg <sagi@grimberg.me>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Christoph Hellwig <hch@lst.de>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:58806 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756295AbdEDSCo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 14:02:44 -0400
In-Reply-To: <20170504180216.7665-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

The following objects (monitor, providers, stats and protocols) are not
implemented yet, however it is worth to place their stubs in the code.

This will serve as an initial starting point for other developers to
extend RDMA tool.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 rdma/Makefile    |  2 +-
 rdma/monitor.c   | 22 ++++++++++++++++++++++
 rdma/protocols.c | 22 ++++++++++++++++++++++
 rdma/providers.c | 28 ++++++++++++++++++++++++++++
 rdma/rdma.c      |  6 +++++-
 rdma/rdma.h      |  4 ++++
 rdma/stats.c     | 22 ++++++++++++++++++++++
 7 files changed, 104 insertions(+), 2 deletions(-)
 create mode 100644 rdma/monitor.c
 create mode 100644 rdma/protocols.c
 create mode 100644 rdma/providers.c
 create mode 100644 rdma/stats.c

diff --git a/rdma/Makefile b/rdma/Makefile
index 5cf0d29f..eb71da68 100644
--- a/rdma/Makefile
+++ b/rdma/Makefile
@@ -1,6 +1,6 @@
 include ../Config

-RDMA_OBJ = rdma.o utils.o dev.o link.o ipoib.o memory.o
+RDMA_OBJ = rdma.o utils.o dev.o link.o ipoib.o memory.o stats.o protocols.o providers.o monitor.o
 TARGETS=rdma

 all:	$(TARGETS) $(LIBS)
diff --git a/rdma/monitor.c b/rdma/monitor.c
new file mode 100644
index 00000000..99d4b042
--- /dev/null
+++ b/rdma/monitor.c
@@ -0,0 +1,22 @@
+/*
+ * monitor.c	RDMA tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Leon Romanovsky <leonro@mellanox.com>
+ */
+
+#include "rdma.h"
+
+int obj_monitor(struct rdma *rd)
+{
+	if (dev_map_init(rd)) {
+		pr_err("There are no RDMA devices\n");
+		return -ENOENT;
+	}
+
+	return 0;
+}
diff --git a/rdma/protocols.c b/rdma/protocols.c
new file mode 100644
index 00000000..26de7d2b
--- /dev/null
+++ b/rdma/protocols.c
@@ -0,0 +1,22 @@
+/*
+ * protocols.c	RDMA tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Leon Romanovsky <leonro@mellanox.com>
+ */
+
+#include "rdma.h"
+
+int obj_protocols(struct rdma *rd)
+{
+	if (dev_map_init(rd)) {
+		pr_err("There are no RDMA devices\n");
+		return -ENOENT;
+	}
+
+	return 0;
+}
diff --git a/rdma/providers.c b/rdma/providers.c
new file mode 100644
index 00000000..8d516cca
--- /dev/null
+++ b/rdma/providers.c
@@ -0,0 +1,28 @@
+/*
+ * providers.c	RDMA tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Leon Romanovsky <leonro@mellanox.com>
+ */
+
+#include "rdma.h"
+
+static void providers_help(char *filename)
+{
+	pr_out("Usage: %s providers show [ DEV ]\n", filename);
+}
+
+int obj_providers(struct rdma *rd)
+{
+	if (dev_map_init(rd)) {
+		pr_err("There are no RDMA devices\n");
+		return -ENOENT;
+	}
+
+	providers_help(rd->filename);
+	return 0;
+}
diff --git a/rdma/rdma.c b/rdma/rdma.c
index 094d490d..a0a3ec81 100644
--- a/rdma/rdma.c
+++ b/rdma/rdma.c
@@ -17,7 +17,7 @@
 static void help(char *name)
 {
 	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
-	       "where  OBJECT := { dev | link | ipoib | memory }\n"
+	       "where  OBJECT := { dev | link | ipoib | memory | stats | protocols | providers | monitor }\n"
 	       "       OPTIONS := { -V[ersion] }\n", name);
 }

@@ -35,6 +35,10 @@ static int rd_cmd(struct rdma *rd)
 		{ "link",	obj_link },
 		{ "ipoib",	obj_ipoib },
 		{ "memory",	obj_memory },
+		{ "stats",	obj_stats },
+		{ "providers",	obj_providers },
+		{ "protocols",	obj_protocols },
+		{ "monitor",	obj_monitor },
 		{ "help",	obj_help },
 		{ 0 }
 	};
diff --git a/rdma/rdma.h b/rdma/rdma.h
index dcff066f..11d940d7 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -66,6 +66,10 @@ int obj_dev(struct rdma *rd);
 int obj_link(struct rdma *rd);
 int obj_ipoib(struct rdma *rd);
 int obj_memory(struct rdma *rd);
+int obj_protocols(struct rdma *rd);
+int obj_stats(struct rdma *rd);
+int obj_providers(struct rdma *rd);
+int obj_monitor(struct rdma *rd);

 /*
  * Parser interface
diff --git a/rdma/stats.c b/rdma/stats.c
new file mode 100644
index 00000000..a557e59b
--- /dev/null
+++ b/rdma/stats.c
@@ -0,0 +1,22 @@
+/*
+ * stats.c	RDMA tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Leon Romanovsky <leonro@mellanox.com>
+ */
+
+#include "rdma.h"
+
+int obj_stats(struct rdma *rd)
+{
+	if (dev_map_init(rd)) {
+		pr_err("There are no RDMA devices\n");
+		return -ENOENT;
+	}
+
+	return 0;
+}
