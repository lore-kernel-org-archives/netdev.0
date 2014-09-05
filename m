From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2] bond_slave: add help and fail on unknown opt
Date: Fri,  5 Sep 2014 09:45:25 +0200
Message-ID: <1409903125-21200-1-git-send-email-jiri@resnulli.us>
References: <1409759850-15812-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, stephen@networkplumber.org, nikolay@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:48486 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbaIEHp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 03:45:29 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so324689wib.10
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 00:45:28 -0700 (PDT)
In-Reply-To: <1409759850-15812-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 ip/iplink_bond_slave.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/ip/iplink_bond_slave.c b/ip/iplink_bond_slave.c
index aacba14..3c26f08 100644
--- a/ip/iplink_bond_slave.c
+++ b/ip/iplink_bond_slave.c
@@ -17,6 +17,13 @@
 #include "utils.h"
 #include "ip_common.h"
 
+static void explain(void)
+{
+	fprintf(stderr,
+		"Usage: ... bond_slave [ queue_id QUEUE_ID ]\n"
+	);
+}
+
 static const char *slave_states[] = {
 	[BOND_STATE_ACTIVE] = "ACTIVE",
 	[BOND_STATE_BACKUP] = "BACKUP",
@@ -91,6 +98,14 @@ static int bond_slave_parse_opt(struct link_util *lu, int argc, char **argv,
 			if (get_u16(&queue_id, *argv, 0))
 				invarg("queue_id is invalid", *argv);
 			addattr16(n, 1024, IFLA_BOND_SLAVE_QUEUE_ID, queue_id);
+		} else if (matches(*argv, "help") == 0) {
+			explain();
+			return -1;
+		} else {
+			fprintf(stderr, "bond_slave: unknown option \"%s\"?\n",
+				*argv);
+			explain();
+			return -1;
 		}
 		argc--, argv++;
 	}
-- 
1.9.3
