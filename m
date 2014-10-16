From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Identify a lot of netlink protocol names
Date: Thu, 16 Oct 2014 19:46:58 +0300
Message-ID: <1413478018-12373-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:49529 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbaJPQ40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 12:56:26 -0400
Received: by mail-lb0-f176.google.com with SMTP id p9so3118767lbv.21
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 09:56:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were only few Netlink protocol names:

    rtnl, fw, tcpdiag

which were printed on output.
So added the other ones.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 61 +++++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 55 insertions(+), 6 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 2420b51..576db4e 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2960,12 +2960,63 @@ static int packet_show(struct filter *f)
 	return 0;
 }
 
+static char *netlink_proto_name(int proto)
+{
+	switch (proto)
+	{
+	case NETLINK_ROUTE:
+		return "rtnl";
+	case NETLINK_USERSOCK:
+		return "user";
+	case NETLINK_FIREWALL:
+		return "fw";
+	case NETLINK_SOCK_DIAG:
+		return "tcpdiag";
+	case NETLINK_NFLOG:
+		return "nflog";
+	case NETLINK_XFRM:
+		return "xfrm";
+	case NETLINK_SELINUX:
+		return "selinux";
+	case NETLINK_ISCSI:
+		return "iscsi";
+	case NETLINK_AUDIT:
+		return "audit";
+	case NETLINK_FIB_LOOKUP:
+		return "fiblookup";
+	case NETLINK_CONNECTOR:
+		return "conn";
+	case NETLINK_NETFILTER:
+		return "nft";
+	case NETLINK_IP6_FW:
+		return "ip6fw";
+	case NETLINK_DNRTMSG:
+		return "decrt";
+	case NETLINK_KOBJECT_UEVENT:
+		return "uevent";
+	case NETLINK_GENERIC:
+		return "genl";
+	case NETLINK_SCSITRANSPORT:
+		return "scsitrans";
+	case NETLINK_ECRYPTFS:
+		return "ecryptfs";
+	case NETLINK_RDMA:
+		return "rdma";
+	case NETLINK_CRYPTO:
+		return "crypto";
+	}
+
+	return NULL;
+};
+
 static void netlink_show_one(struct filter *f,
 				int prot, int pid, unsigned groups,
 				int state, int dst_pid, unsigned dst_group,
 				int rq, int wq,
 				unsigned long long sk, unsigned long long cb)
 {
+	char *prot_name;
+
 	if (f->f) {
 		struct tcpstat tst;
 		tst.local.family = AF_NETLINK;
@@ -2983,14 +3034,12 @@ static void netlink_show_one(struct filter *f,
 	if (state_width)
 		printf("%-*s ", state_width, "UNCONN");
 	printf("%-6d %-6d ", rq, wq);
-	if (resolve_services && prot == 0)
-		printf("%*s:", addr_width, "rtnl");
-	else if (resolve_services && prot == 3)
-		printf("%*s:", addr_width, "fw");
-	else if (resolve_services && prot == 4)
-		printf("%*s:", addr_width, "tcpdiag");
+
+	if (resolve_services && (prot_name = netlink_proto_name(prot)))
+		printf("%*s:", addr_width, prot_name);
 	else
 		printf("%*d:", addr_width, prot);
+
 	if (pid == -1) {
 		printf("%-*s ", serv_width, "*");
 	} else if (resolve_services) {
-- 
2.1.0
