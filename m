From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 05/51] iplink_can: Prevent overstepping array bounds
Date: Sat, 12 Aug 2017 14:04:24 +0200
Message-ID: <20170812120510.28750-6-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54863 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752555AbdHLMGv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:06:51 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

can_state_names array contains at most CAN_STATE_MAX fields, so allowing
an index to it to be equal to that number is wrong. While here, also
make sure the array is indeed that big so nothing bad happens if
CAN_STATE_MAX ever increases.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink_can.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/iplink_can.c b/ip/iplink_can.c
index 5df56b2bbbb3b..2954010fefa22 100644
--- a/ip/iplink_can.c
+++ b/ip/iplink_can.c
@@ -251,7 +251,7 @@ static int can_parse_opt(struct link_util *lu, int argc, char **argv,
 	return 0;
 }
 
-static const char *can_state_names[] = {
+static const char *can_state_names[CAN_STATE_MAX] = {
 	[CAN_STATE_ERROR_ACTIVE] = "ERROR-ACTIVE",
 	[CAN_STATE_ERROR_WARNING] = "ERROR-WARNING",
 	[CAN_STATE_ERROR_PASSIVE] = "ERROR-PASSIVE",
@@ -275,7 +275,7 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_CAN_STATE]) {
 		uint32_t state = rta_getattr_u32(tb[IFLA_CAN_STATE]);
 
-		fprintf(f, "state %s ", state <= CAN_STATE_MAX ?
+		fprintf(f, "state %s ", state < CAN_STATE_MAX ?
 			can_state_names[state] : "UNKNOWN");
 	}
 
-- 
2.13.1
