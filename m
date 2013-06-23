From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH iproute2 1/2] vxlan: introduce vxlan_parse_opt_create
Date: Sun, 23 Jun 2013 19:24:02 +0300
Message-ID: <1372004643-24718-1-git-send-email-mike.rapoport@ravellosystems.com>
References: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog107.obsmtp.com ([74.125.245.82]:48023 "HELO
	na3sys010aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751764Ab3FWQYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 12:24:10 -0400
Received: by mail-ea0-f178.google.com with SMTP id l15so5500743eak.37
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 09:24:08 -0700 (PDT)
In-Reply-To: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for addition of vxlan_parse_opt_change, which is required to
differentiate between create time only settings and the settings that
can be changed with 'ip link set'

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 ip/iplink_vxlan.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 1025326..92ddfb4 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -35,8 +35,8 @@ static void explain(void)
 	fprintf(stderr, "       TTL  := { 1..255 | inherit }\n");
 }
 
-static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
-			  struct nlmsghdr *n)
+static int vxlan_parse_opt_create(struct link_util *lu, int argc, char **argv,
+				  struct nlmsghdr *n)
 {
 	__u32 vni = 0;
 	int vni_set = 0;
@@ -187,6 +187,12 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	return 0;
 }
 
+static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
+			  struct nlmsghdr *n)
+{
+	return vxlan_parse_opt_create(lu, argc, argv, n);
+}
+
 static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 {
 	__u32 vni;
-- 
1.8.1.5
