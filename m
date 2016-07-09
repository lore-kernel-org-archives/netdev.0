From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/6] iplink: bond_slave: Add missing help functions
Date: Sat,  9 Jul 2016 11:22:46 +0200
Message-ID: <1468056170-6056-3-git-send-email-phil@nwl.cc>
References: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:34451 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702AbcGIJXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 05:23:06 -0400
In-Reply-To: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink_bond_slave.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/ip/iplink_bond_slave.c b/ip/iplink_bond_slave.c
index d67793237edfc..9c60dea8a2757 100644
--- a/ip/iplink_bond_slave.c
+++ b/ip/iplink_bond_slave.c
@@ -17,6 +17,16 @@
 #include "utils.h"
 #include "ip_common.h"
 
+static void print_explain(FILE *f)
+{
+	fprintf(f, "Usage: ... bond_slave [ queue_id ID ]\n");
+}
+
+static void explain(void)
+{
+	print_explain(stderr);
+}
+
 static const char *slave_states[] = {
 	[BOND_STATE_ACTIVE] = "ACTIVE",
 	[BOND_STATE_BACKUP] = "BACKUP",
@@ -99,6 +109,13 @@ static int bond_slave_parse_opt(struct link_util *lu, int argc, char **argv,
 			if (get_u16(&queue_id, *argv, 0))
 				invarg("queue_id is invalid", *argv);
 			addattr16(n, 1024, IFLA_BOND_SLAVE_QUEUE_ID, queue_id);
+		} else {
+			if (matches(*argv, "help") != 0)
+				fprintf(stderr,
+					"bond_slave: unknown option \"%s\"?\n",
+					*argv);
+			explain();
+			return -1;
 		}
 		argc--, argv++;
 	}
@@ -106,10 +123,17 @@ static int bond_slave_parse_opt(struct link_util *lu, int argc, char **argv,
 	return 0;
 }
 
+static void bond_slave_print_help(struct link_util *lu, int argc, char **argv,
+				  FILE *f)
+{
+	print_explain(f);
+}
+
 struct link_util bond_slave_link_util = {
 	.id		= "bond",
 	.maxattr	= IFLA_BOND_SLAVE_MAX,
 	.print_opt	= bond_slave_print_opt,
 	.parse_opt	= bond_slave_parse_opt,
+	.print_help	= bond_slave_print_help,
 	.slave		= true,
 };
-- 
2.8.2
