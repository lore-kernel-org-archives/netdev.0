From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [RFC iproute2 4/8] rdma: Add IPoIB object
Date: Thu,  4 May 2017 21:02:12 +0300
Message-ID: <20170504180216.7665-5-leon@kernel.org>
References: <20170504180216.7665-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Ram Amrani <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170504180216.7665-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

IPoIB object allows configuration and presentation of information for
IP-over-Infiniband user level protocol.

Supported commands are show, set and help.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 rdma/Makefile |  2 +-
 rdma/ipoib.c  | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 rdma/rdma.c   |  3 ++-
 rdma/rdma.h   |  1 +
 4 files changed, 58 insertions(+), 2 deletions(-)
 create mode 100644 rdma/ipoib.c

diff --git a/rdma/Makefile b/rdma/Makefile
index cf54ed36..dd702b9f 100644
--- a/rdma/Makefile
+++ b/rdma/Makefile
@@ -1,6 +1,6 @@
 include ../Config

-RDMA_OBJ = rdma.o utils.o dev.o link.o
+RDMA_OBJ = rdma.o utils.o dev.o link.o ipoib.o
 TARGETS=rdma

 all:	$(TARGETS) $(LIBS)
diff --git a/rdma/ipoib.c b/rdma/ipoib.c
new file mode 100644
index 00000000..dd0d0285
--- /dev/null
+++ b/rdma/ipoib.c
@@ -0,0 +1,54 @@
+/*
+ * ipoib.c	RDMA tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
+ */
+
+#include "rdma.h"
+
+static int ipoib_help(struct rdma *rd)
+{
+	pr_out("Usage: %s ipoib show NAME | DEV | DEV/PORT\n", rd->filename);
+	pr_out("       %s ipoib set NAME [ accel { off | on } ]\n", rd->filename);
+	pr_out("       %s ipoib start NAME dev DEV\n", rd->filename);
+	pr_out("       %s ipoib stop NAME\n", rd->filename);
+	return 0;
+}
+
+static int ipoib_show(struct rdma *rd)
+{
+	if (rd_no_arg(rd))
+		ipoib_help(rd);
+
+	return 0;
+}
+
+static int ipoib_set(struct rdma *rd)
+{
+	/* Not supported yet */
+	return 0;
+}
+
+int obj_ipoib(struct rdma *rd)
+{
+	const struct rdma_obj objs[] = {
+		{ NULL,		ipoib_show },
+		{ "show",	ipoib_show },
+		{ "list",	ipoib_show },
+		{ "set",	ipoib_set },
+		{ "help",	ipoib_help },
+		{ 0 }
+	};
+
+	if (dev_map_init(rd)) {
+		pr_err("There are no RDMA devices\n");
+		return -ENOENT;
+	}
+
+	return rdma_exec_cmd(rd, objs, "Uknown ipoib command");
+}
diff --git a/rdma/rdma.c b/rdma/rdma.c
index 55cbf0e3..ffd70899 100644
--- a/rdma/rdma.c
+++ b/rdma/rdma.c
@@ -17,7 +17,7 @@
 static void help(char *name)
 {
 	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
-	       "where  OBJECT := { dev | link }\n"
+	       "where  OBJECT := { dev | link | ipoib }\n"
 	       "       OPTIONS := { -V[ersion] }\n", name);
 }

@@ -33,6 +33,7 @@ static int rd_cmd(struct rdma *rd)
 		{ NULL,		obj_help },
 		{ "dev",	obj_dev },
 		{ "link",	obj_link },
+		{ "ipoib",	obj_ipoib },
 		{ "help",	obj_help },
 		{ 0 }
 	};
diff --git a/rdma/rdma.h b/rdma/rdma.h
index bdb77b5e..1fef4eb8 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -64,6 +64,7 @@ struct rdma_obj {
  */
 int obj_dev(struct rdma *rd);
 int obj_link(struct rdma *rd);
+int obj_ipoib(struct rdma *rd);

 /*
  * Parser interface
--
2.12.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
