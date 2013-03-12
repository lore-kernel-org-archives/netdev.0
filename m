From: roopa@cumulusnetworks.com
Subject: [PATCH iproute2] Fix -oneline output when alias present
Date: Tue, 12 Mar 2013 15:03:47 -0700
Message-ID: <1363125827-14129-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext.cumulusnetworks.com ([66.175.223.20]:46364 "EHLO
	ext.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933145Ab3CLWK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 18:10:57 -0400
To: shemminger@vyatta.com
To: roopa@cumulusnetworks.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>

This patch removes '\n' in -oneline output when alias
present on interface

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 ip/ipaddress.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index cff503f..fdd2a74 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -468,9 +468,11 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (do_link && tb[IFLA_LINKINFO] && show_details)
 		print_linktype(fp, tb[IFLA_LINKINFO]);
 
-	if (do_link && tb[IFLA_IFALIAS])
-		fprintf(fp,"\n    alias %s", 
+	if (do_link && tb[IFLA_IFALIAS]) {
+		fprintf(fp, "%s", _SL_);
+		fprintf(fp,"    alias %s",
 			rta_getattr_str(tb[IFLA_IFALIAS]));
+	}
 
 	if (do_link && show_stats) {
 		if (tb[IFLA_STATS64])
-- 
1.7.2.5
