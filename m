From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [iproute2] iplink: add support for IFLA_CARRIER attribute
Date: Wed, 26 Apr 2017 15:08:39 +0800
Message-ID: <1493190519-5518-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:14072 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1435197AbdDZHIt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 03:08:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to set IFLA_CARRIER attribute.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/iplink.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/ip/iplink.c b/ip/iplink.c
index 866ad72..263bfdd 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -72,6 +72,7 @@ void iplink_usage(void)
 		"	                  [ allmulticast { on | off } ]\n"
 		"	                  [ promisc { on | off } ]\n"
 		"	                  [ trailers { on | off } ]\n"
+		"	                  [ carrier { on | off } ]\n"
 		"	                  [ txqueuelen PACKETS ]\n"
 		"	                  [ name NEWNAME ]\n"
 		"	                  [ address LLADDR ]\n"
@@ -673,6 +674,17 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				req->i.ifi_flags |= IFF_NOARP;
 			else
 				return on_off("arp", *argv);
+		} else if (strcmp(*argv, "carrier") == 0) {
+			int carrier;
+			NEXT_ARG();
+			if (strcmp(*argv, "on") == 0)
+				carrier = 1;
+			else if (strcmp(*argv, "off") == 0)
+				carrier = 0;
+			else
+				return on_off("carrier", *argv);
+
+			addattr8(&req->n, sizeof(*req), IFLA_CARRIER, carrier);
 		} else if (strcmp(*argv, "vf") == 0) {
 			struct rtattr *vflist;
 
-- 
1.8.3.1
