From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH iproute2 1/3] ip-link: display parentid for netdevs
Date: Fri,  5 Dec 2014 13:02:15 -0500
Message-ID: <1417802537-20020-1-git-send-email-gospo@cumulusnetworks.com>
Cc: sfeldma@gmail.com, jpirko@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48577 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbaLESCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 13:02:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Display parentid for netdev that may actually be associated with device
capable of offloading network forwarding.  Useful to identify which
netdevs are connected device when multiple forwarding elements are on a
system.

Based on patch from Jiri Pirko but with a different name for netlink
attribute.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
---

I did not include definition for IFLA_PHYS_PARENT_ID as Stephen
indicated that patching if_link.h isn't needed since it will get pulled
later.

 ip/ipaddress.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 4d99324..d155085 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -581,6 +581,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		fprintf(fp, "master %s ", ll_idx_n2a(*(int*)RTA_DATA(tb[IFLA_MASTER]), b1));
 	}
 
+	if (tb[IFLA_PHYS_PARENT_ID]) {
+		SPRINT_BUF(b1);
+		fprintf(fp, "parentid %s ",
+			hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_PARENT_ID]),
+				      RTA_PAYLOAD(tb[IFLA_PHYS_PARENT_ID]),
+				      b1, sizeof(b1)));
+	}
+
 	if (tb[IFLA_PHYS_PORT_ID]) {
 		SPRINT_BUF(b1);
 		fprintf(fp, "portid %s ",
-- 
1.9.3
