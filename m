From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2] bridge: vlan json: skip ports with empty vlans
Date: Sun,  7 Aug 2016 12:37:03 -0700
Message-ID: <1470598623-17215-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33910 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbcHGThI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2016 15:37:08 -0400
Received: by mail-pa0-f51.google.com with SMTP id fi15so107120370pac.1
        for <netdev@vger.kernel.org>; Sun, 07 Aug 2016 12:37:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

The non-json output prints 'None' for such vlans.
And this can garble json output.

Fixes: d82a49ce85f0 ("bridge: add json support for bridge vlan show")
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
saw this when deploying a mix of vlan filtering and non-vlan
filtering bridges.

 bridge/vlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/bridge/vlan.c b/bridge/vlan.c
index 22f32a5..d3505b5 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -212,7 +212,7 @@ static int print_vlan(const struct sockaddr_nl *who,
 
 	/* if AF_SPEC isn't there, vlan table is not preset for this port */
 	if (!tb[IFLA_AF_SPEC]) {
-		if (!filter_vlan)
+		if (!filter_vlan && !jw_global)
 			fprintf(fp, "%s\tNone\n",
 				ll_index_to_name(ifm->ifi_index));
 		return 0;
-- 
2.1.4
