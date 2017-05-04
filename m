From: Leon Romanovsky <leon@kernel.org>
Subject: [RFC iproute2 5/8] rdma: Add memory object
Date: Thu,  4 May 2017 21:02:13 +0300
Message-ID: <20170504180216.7665-6-leon@kernel.org>
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
Received: from mail.kernel.org ([198.145.29.136]:58738 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932291AbdEDSCe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 14:02:34 -0400
In-Reply-To: <20170504180216.7665-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Memory object gives to the user ability to manipulate over general
properties of memory for the specific devices. The memory properties
have broader usage than dev object can provide.

For example, on-demand-paging (ODP) configurations are mostly software related.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 rdma/Makefile |  2 +-
 rdma/memory.c | 30 ++++++++++++++++++++++++++++++
 rdma/rdma.c   |  3 ++-
 rdma/rdma.h   |  1 +
 4 files changed, 34 insertions(+), 2 deletions(-)
 create mode 100644 rdma/memory.c

diff --git a/rdma/Makefile b/rdma/Makefile
index dd702b9f..5cf0d29f 100644
--- a/rdma/Makefile
+++ b/rdma/Makefile
@@ -1,6 +1,6 @@
 include ../Config

-RDMA_OBJ = rdma.o utils.o dev.o link.o ipoib.o
+RDMA_OBJ = rdma.o utils.o dev.o link.o ipoib.o memory.o
 TARGETS=rdma

 all:	$(TARGETS) $(LIBS)
diff --git a/rdma/memory.c b/rdma/memory.c
new file mode 100644
index 00000000..68fd5dd3
--- /dev/null
+++ b/rdma/memory.c
@@ -0,0 +1,30 @@
+/*
+ * memory.c	RDMA tool
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
+static void memory_help(char *filename)
+{
+	pr_out("Usage: %s memory show [ DEV ]\n", filename);
+	pr_out("       %s memory set DEV { odp { off | on } |\n", filename);
+	pr_out("       %s                  memic SIZE }\n", filename);
+}
+
+int obj_memory(struct rdma *rd)
+{
+	if (dev_map_init(rd)) {
+		pr_err("There are no RDMA devices\n");
+		return -ENOENT;
+	}
+
+	memory_help(rd->filename);
+	return 0;
+}
diff --git a/rdma/rdma.c b/rdma/rdma.c
index ffd70899..094d490d 100644
--- a/rdma/rdma.c
+++ b/rdma/rdma.c
@@ -17,7 +17,7 @@
 static void help(char *name)
 {
 	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
-	       "where  OBJECT := { dev | link | ipoib }\n"
+	       "where  OBJECT := { dev | link | ipoib | memory }\n"
 	       "       OPTIONS := { -V[ersion] }\n", name);
 }

@@ -34,6 +34,7 @@ static int rd_cmd(struct rdma *rd)
 		{ "dev",	obj_dev },
 		{ "link",	obj_link },
 		{ "ipoib",	obj_ipoib },
+		{ "memory",	obj_memory },
 		{ "help",	obj_help },
 		{ 0 }
 	};
diff --git a/rdma/rdma.h b/rdma/rdma.h
index 1fef4eb8..dcff066f 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -65,6 +65,7 @@ struct rdma_obj {
 int obj_dev(struct rdma *rd);
 int obj_link(struct rdma *rd);
 int obj_ipoib(struct rdma *rd);
+int obj_memory(struct rdma *rd);

 /*
  * Parser interface
