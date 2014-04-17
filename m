From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch iproute2 RFC v3 4/5] iproute2: add support for
	dummyswport
Date: Thu, 17 Apr 2014 14:17:32 +0200
Message-ID: <1397737053-11892-5-git-send-email-jiri@resnulli.us>
References: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
 <1397737053-11892-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
 vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1397737053-11892-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 include/linux/if_link.h |  9 ++++++++
 ip/Makefile             |  3 ++-
 ip/iplink_dummyswport.c | 56 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 67 insertions(+), 1 deletion(-)
 create mode 100644 ip/iplink_dummyswport.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 2932453..f2fdb85 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -544,4 +544,13 @@ enum {
 
 #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
 
+/* DUMMYSWPORT section */
+enum {
+	IFLA_DUMMYSWPORT_UNSPEC,
+	IFLA_DYMMYSWPORT_PHYS_SWITCH_ID,
+	__IFLA_DUMMYSWPORT_MAX,
+};
+
+#define IFLA_DUMMYSWPORT_MAX (__IFLA_DUMMYSWPORT_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/Makefile b/ip/Makefile
index 713adf5..35546e5 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -5,7 +5,8 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
-    link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o
+    link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
+    iplink_dummyswport.o \
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/iplink_dummyswport.c b/ip/iplink_dummyswport.c
new file mode 100644
index 0000000..64f1a02
--- /dev/null
+++ b/ip/iplink_dummyswport.c
@@ -0,0 +1,56 @@
+/*
+ * iplink_dummyswport.c		dummy switch port device support
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/socket.h>
+#include <sys/types.h>
+#include <asm/types.h>
+#include <linux/if_link.h>
+#include <net/if.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+
+static void explain(void)
+{
+	fprintf(stderr, "Usage: ... dummyswport swid SWITCH_ID\n");
+}
+
+static int dummyswport_parse_opt(struct link_util *lu, int argc, char **argv,
+				 struct nlmsghdr *n)
+{
+	while (argc > 0) {
+		if (matches(*argv, "swid") == 0) {
+			__u8 buf[32];
+
+			NEXT_ARG();
+			if (!hexstring_a2n(*argv, buf, sizeof(buf)))
+				invarg("invalid \"swid\" value\n", *argv);
+			addattr_l(n, 1024, IFLA_DYMMYSWPORT_PHYS_SWITCH_ID,
+				  buf, strlen(*argv) / 2);
+		} else {
+			fprintf(stderr, "dummyswport: unknown option \"%s\"?\n", *argv);
+			explain();
+			return -1;
+		}
+		argc--, argv++;
+	}
+	return 0;
+}
+
+struct link_util dummyswport_link_util = {
+	.id		= "dummyswport",
+	.maxattr	= IFLA_DUMMYSWPORT_MAX,
+	.parse_opt	= dummyswport_parse_opt,
+};
-- 
1.9.0
