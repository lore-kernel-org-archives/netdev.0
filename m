From: roopa@cumulusnetworks.com
Subject: [PATCH iproute2 v2] bridge: Add master device name to bridge fdb show
Date: Fri, 30 May 2014 22:04:45 -0700
Message-ID: <1401512685-29047-1-git-send-email-roopa@cumulusnetworks.com>
Cc: jhs@mojatatu.com, wkok@cumulusnetworks.com,
	sfeldma@cumulusnetworks.com, shm@cumulusnetworks.com
To: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:58968 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbaEaFEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2014 01:04:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

(This patch depends on net-next patch titled
"Add bridge ifindex to bridge fdb notify msgs")

This patch adds bridge dev name from NDA_MASTER netlink attribute
 to bridge fdb show output

Example output:

before this patch:
# bridge fdb show
44:38:39:00:27:ba dev bond2.2003 permanent
44:38:39:00:27:bb dev bond4.2003 permanent
44:38:39:00:27:bc dev bond2.2004 permanent

After this patch:
# bridge fdb show
44:38:39:00:27:ba dev bond2.2003 bridge br-2003 permanent
44:38:39:00:27:bb dev bond4.2003 bridge br-2003 permanent
44:38:39:00:27:bc dev bond2.2004 bridge br-2004 permanent

change from v1 to v2:
    use 'bridge' instead of 'master' in fdb show output

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/fdb.c              |    4 ++++
 include/linux/neighbour.h |    1 +
 2 files changed, 5 insertions(+)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 336cf9d..d7c42f0 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -152,6 +152,10 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (r->ndm_flags & NTF_ROUTER)
 		fprintf(fp, "router ");
 
+	if (tb[NDA_MASTER])
+		fprintf(fp, "bridge %s ",
+			ll_index_to_name(rta_getattr_u32(tb[NDA_MASTER])));
+
 	fprintf(fp, "%s\n", state_n2a(r->ndm_state));
 	return 0;
 }
diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index d3ef583..4a1d7e9 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -24,6 +24,7 @@ enum {
 	NDA_PORT,
 	NDA_VNI,
 	NDA_IFINDEX,
+	NDA_MASTER,
 	__NDA_MAX
 };
 
-- 
1.7.10.4
