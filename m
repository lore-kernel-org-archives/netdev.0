From: Cong Wang <amwang@redhat.com>
Subject: [Patch iproute2] vxlan: use 8472 as default dst port
Date: Wed, 15 May 2013 19:11:10 +0800
Message-ID: <1368616270-5775-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752229Ab3EOLLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 07:11:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because Linux kernel uses the same default, otherwise
the default config doesn't work.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 2d93ee2..a0c90b3 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -53,7 +53,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 noage = 0;
 	__u32 age = 0;
 	__u32 maxaddr = 0;
-	__u16 dstport = 4789;
+	__u16 dstport = 8472;
 	struct ifla_vxlan_port_range range = { 0, 0 };
 
 	while (argc > 0) {
@@ -188,8 +188,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	if (range.low || range.high)
 		addattr_l(n, 1024, IFLA_VXLAN_PORT_RANGE,
 			  &range, sizeof(range));
-	if (dstport)
-		addattr16(n, 1024, IFLA_VXLAN_PORT, htons(dstport));
+	addattr16(n, 1024, IFLA_VXLAN_PORT, htons(dstport));
 
 	return 0;
 }
