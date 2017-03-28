From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 4/4] ip: link: Add missing link type help texts
Date: Tue, 28 Mar 2017 23:19:39 +0200
Message-ID: <20170328211939.17922-5-phil@nwl.cc>
References: <20170328211939.17922-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54153 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932396AbdC1VUR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 17:20:17 -0400
In-Reply-To: <20170328211939.17922-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are basically stubs: The types which lacked their own help text
simply don't accept any options (yet). Still it might be a bit confusing
to users if they are presented with the generic 'ip link' help text
instead of something saying there are no type specific options.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/Makefile       |  3 ++-
 ip/iplink_dummy.c | 16 ++++++++++++++++
 ip/iplink_ifb.c   | 16 ++++++++++++++++
 ip/iplink_nlmon.c | 16 ++++++++++++++++
 ip/iplink_team.c  | 25 +++++++++++++++++++++++++
 ip/iplink_vcan.c  | 16 ++++++++++++++++
 6 files changed, 91 insertions(+), 1 deletion(-)
 create mode 100644 ip/iplink_dummy.c
 create mode 100644 ip/iplink_ifb.c
 create mode 100644 ip/iplink_nlmon.c
 create mode 100644 ip/iplink_team.c
 create mode 100644 ip/iplink_vcan.c

diff --git a/ip/Makefile b/ip/Makefile
index 4276a34b529e3..035d42c74f90b 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -1,7 +1,8 @@
 IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     rtm_map.o iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o iplink.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o iptoken.o \
-    ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
+    ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o iplink_dummy.o \
+    iplink_ifb.o iplink_nlmon.o iplink_team.o iplink_vcan.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o iplink_xdp.o \
     iplink_macvlan.o ipl2tp.o link_vti.o link_vti6.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
diff --git a/ip/iplink_dummy.c b/ip/iplink_dummy.c
new file mode 100644
index 0000000000000..cf78ea5bca926
--- /dev/null
+++ b/ip/iplink_dummy.c
@@ -0,0 +1,16 @@
+#include <stdio.h>
+#include <stdlib.h>
+
+#include "utils.h"
+#include "ip_common.h"
+
+static void dummy_print_help(struct link_util *lu,
+			    int argc, char **argv, FILE *f)
+{
+	fprintf(f, "Usage: ... dummy\n");
+}
+
+struct link_util dummy_link_util = {
+	.id		= "dummy",
+	.print_help	= dummy_print_help,
+};
diff --git a/ip/iplink_ifb.c b/ip/iplink_ifb.c
new file mode 100644
index 0000000000000..d7dc8f987d120
--- /dev/null
+++ b/ip/iplink_ifb.c
@@ -0,0 +1,16 @@
+#include <stdio.h>
+#include <stdlib.h>
+
+#include "utils.h"
+#include "ip_common.h"
+
+static void ifb_print_help(struct link_util *lu,
+			    int argc, char **argv, FILE *f)
+{
+	fprintf(f, "Usage: ... ifb\n");
+}
+
+struct link_util ifb_link_util = {
+	.id		= "ifb",
+	.print_help	= ifb_print_help,
+};
diff --git a/ip/iplink_nlmon.c b/ip/iplink_nlmon.c
new file mode 100644
index 0000000000000..51d5919a75d3d
--- /dev/null
+++ b/ip/iplink_nlmon.c
@@ -0,0 +1,16 @@
+#include <stdio.h>
+#include <stdlib.h>
+
+#include "utils.h"
+#include "ip_common.h"
+
+static void nlmon_print_help(struct link_util *lu,
+			    int argc, char **argv, FILE *f)
+{
+	fprintf(f, "Usage: ... nlmon\n");
+}
+
+struct link_util nlmon_link_util = {
+	.id		= "nlmon",
+	.print_help	= nlmon_print_help,
+};
diff --git a/ip/iplink_team.c b/ip/iplink_team.c
new file mode 100644
index 0000000000000..6225268dda2dc
--- /dev/null
+++ b/ip/iplink_team.c
@@ -0,0 +1,25 @@
+#include <stdio.h>
+#include <stdlib.h>
+
+#include "utils.h"
+#include "ip_common.h"
+
+static void team_print_help(struct link_util *lu,
+			    int argc, char **argv, FILE *f)
+{
+	fprintf(f, "Usage: ... team\n");
+}
+
+static void team_slave_print_help(struct link_util *lu,
+				  int argc, char **argv, FILE *f)
+{
+	fprintf(f, "Usage: ... team_slave\n");
+}
+
+struct link_util team_link_util = {
+	.id		= "team",
+	.print_help	= team_print_help,
+}, team_slave_link_util = {
+	.id		= "team_slave",
+	.print_help	= team_slave_print_help,
+};
diff --git a/ip/iplink_vcan.c b/ip/iplink_vcan.c
new file mode 100644
index 0000000000000..b7ae15f072a4e
--- /dev/null
+++ b/ip/iplink_vcan.c
@@ -0,0 +1,16 @@
+#include <stdio.h>
+#include <stdlib.h>
+
+#include "utils.h"
+#include "ip_common.h"
+
+static void vcan_print_help(struct link_util *lu,
+			    int argc, char **argv, FILE *f)
+{
+	fprintf(f, "Usage: ... vcan\n");
+}
+
+struct link_util vcan_link_util = {
+	.id		= "vcan",
+	.print_help	= vcan_print_help,
+};
-- 
2.11.0
