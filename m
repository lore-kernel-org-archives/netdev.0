From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] vrf: Add support for table names
Date: Tue,  8 Dec 2015 12:24:44 -0800
Message-ID: <1449606284-42134-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, stephen@networkplumber.org,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34246 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547AbbLHUYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 15:24:53 -0500
Received: by pacwq6 with SMTP id wq6so17138713pac.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 12:24:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the table id for VRF devices requires an integer. Convert
it to use rtnl_rttable_a2n which handles table names from the iproute2
directory.

This also fixes a bug in the original commit where table name are not
properly handled.

Fixes: 15faa0a30bed ("add support for VRF device")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/iplink_vrf.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
index 913a2892c95b..9b4b7728cf6f 100644
--- a/ip/iplink_vrf.c
+++ b/ip/iplink_vrf.c
@@ -28,12 +28,6 @@ static void explain(void)
 	vrf_explain(stderr);
 }
 
-static int table_arg(void)
-{
-	fprintf(stderr,"Error: argument of \"table\" must be 0-32767 and currently unused\n");
-	return -1;
-}
-
 static int vrf_parse_opt(struct link_util *lu, int argc, char **argv,
 			    struct nlmsghdr *n)
 {
@@ -43,9 +37,8 @@ static int vrf_parse_opt(struct link_util *lu, int argc, char **argv,
 
 			NEXT_ARG();
 
-			table = atoi(*argv);
-			if (table > 32767)
-				return table_arg();
+			if (rtnl_rttable_a2n(&table, *argv))
+				invarg("invalid table ID\n", *argv);
 			addattr32(n, 1024, IFLA_VRF_TABLE, table);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
-- 
2.1.4
