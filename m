From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 v2] libnetlink: check flag NLM_F_DUMP_INTR during dumps
Date: Fri, 22 Mar 2013 16:42:24 +0100
Message-ID: <1363966944-4420-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20130322152213.GB11368@casper.infradead.org>
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56331 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933382Ab3CVPmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 11:42:39 -0400
In-Reply-To: <20130322152213.GB11368@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When this flag is set, it means that dump was interrupted and result may be
wrong. Inform the user and let him choose to restart or not.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: do not stop the dump, only display a warning

 lib/libnetlink.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index f262959..1a882b2 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -230,6 +230,10 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 				    h->nlmsg_seq != rth->dump)
 					goto skip_it;
 
+				if (h->nlmsg_flags & NLM_F_DUMP_INTR)
+					fprintf(stderr,
+						"Dump was interrupted and may be wrong.\n");
+
 				if (h->nlmsg_type == NLMSG_DONE) {
 					found_done = 1;
 					break; /* process next filter */
-- 
1.8.0.1
