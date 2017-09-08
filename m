From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 2/3] bridge: dump vlan table information for link
Date: Fri,  8 Sep 2017 17:52:22 -0400
Message-ID: <1504907543-14394-3-git-send-email-mrv@mojatatu.com>
References: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:37045 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932323AbdIHVw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 17:52:58 -0400
Received: by mail-io0-f194.google.com with SMTP id p63so1715413ioe.4
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 14:52:58 -0700 (PDT)
In-Reply-To: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel also reports vlans a port is member of, so print it. Since vlan
table can be quite large, dump it only when detailed information is
requested.

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 bridge/link.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/bridge/link.c b/bridge/link.c
index 93472ad..60200f1 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -213,6 +213,13 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 		if (aftb[IFLA_BRIDGE_MODE])
 			print_hwmode(fp, rta_getattr_u16(aftb[IFLA_BRIDGE_MODE]));
+		if (show_details) {
+			if (aftb[IFLA_BRIDGE_VLAN_INFO]) {
+				fprintf(fp, "\n");
+				print_vlan_info(fp, tb[IFLA_AF_SPEC],
+						ifi->ifi_index);
+			}
+		}
 	}
 
 	fprintf(fp, "\n");
-- 
1.9.1
