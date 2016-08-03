From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next] bridge: print_vlan: add missing check for json instance
Date: Tue,  2 Aug 2016 23:07:05 -0700
Message-ID: <1470204425-40078-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35019 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679AbcHCGPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 02:15:37 -0400
Received: by mail-pa0-f47.google.com with SMTP id iw10so70637954pac.2
        for <netdev@vger.kernel.org>; Tue, 02 Aug 2016 23:14:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Also initialize vlan_flags

Fixes: d82a49ce85f0 ("bridge: add json support for bridge vlan show")
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/vlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/bridge/vlan.c b/bridge/vlan.c
index f262cc7..22f32a5 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -188,7 +188,7 @@ static int print_vlan(const struct sockaddr_nl *who,
 	struct ifinfomsg *ifm = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *tb[IFLA_MAX+1];
-	bool vlan_flags;
+	bool vlan_flags = false;
 
 	if (n->nlmsg_type != RTM_NEWLINK) {
 		fprintf(stderr, "Not RTM_NEWLINK: %08x %08x %08x\n",
@@ -276,7 +276,7 @@ static int print_vlan(const struct sockaddr_nl *who,
 					fprintf(fp, " Egress Untagged");
 				}
 			}
-			if (vlan_flags) {
+			if (jw_global && vlan_flags) {
 				jsonw_end_array(jw_global);
 				vlan_flags = false;
 			}
-- 
2.1.4
