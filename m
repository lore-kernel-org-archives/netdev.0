From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH] ip: Showing peer of veth type dev in ip link (ip cmd side)
Date: Fri,  4 Oct 2013 11:35:55 +0900
Message-ID: <1380854155-30174-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h219-110-095-248.catv01.itscom.jp ([219.110.95.248]:34287 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751161Ab3JDS2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 14:28:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement print_opt method to veth to show peer ifindex
as ethtool -S does.

A patch submitted with following subject is needed:

   veth: Showing peer of veth type dev in ip link (kernel side)

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 ip/link_veth.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/ip/link_veth.c b/ip/link_veth.c
index 7730f39..bd84815 100644
--- a/ip/link_veth.c
+++ b/ip/link_veth.c
@@ -11,6 +11,7 @@
  */
 
 #include <string.h>
+#include <inttypes.h>
 #include <net/if.h>
 #include <linux/veth.h>
 
@@ -57,7 +58,22 @@ static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 	return argc - 1 - err;
 }
 
+static void veth_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	if (!tb)
+		return;
+
+	if (tb[VETH_INFO_PEER] &&
+	    RTA_PAYLOAD(tb[VETH_INFO_PEER]) < sizeof(__u64))
+		return;
+
+	fprintf(f, "peer_ifindex %"PRIu64,
+		(uint64_t)rta_getattr_u64(tb[VETH_INFO_PEER]));
+}
+
 struct link_util veth_link_util = {
 	.id = "veth",
+	.maxattr	= VETH_INFO_MAX,
 	.parse_opt = veth_parse_opt,
+	.print_opt = veth_print_opt,
 };
-- 
1.8.3.1
