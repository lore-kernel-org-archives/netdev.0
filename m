From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] libnetlink: check flag NLM_F_DUMP_INTR during dumps
Date: Fri, 22 Mar 2013 15:45:57 +0100
Message-ID: <1363963557-3888-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56258 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862Ab3CVOqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:46:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When this flag is set, it means that dump was interrupted and result may be
wrong. Ask user to restart.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 lib/libnetlink.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index f262959..91991cf 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -230,6 +230,12 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 				    h->nlmsg_seq != rth->dump)
 					goto skip_it;
 
+				if (h->nlmsg_flags & NLM_F_DUMP_INTR) {
+					fprintf(stderr,
+						"Dump was interrupted, please restart.\n");
+					return -1;
+				}
+
 				if (h->nlmsg_type == NLMSG_DONE) {
 					found_done = 1;
 					break; /* process next filter */
-- 
1.8.0.1
