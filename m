From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] sctp: jsctp_sf_eat_sack: fix kernel NULL ptr dereference
Date: Fri, 14 Dec 2012 15:27:22 +0100
Message-ID: <2813cf01509e495fee13ff1fab309f1186c0e57a.1355494956.git.dborkman@redhat.com>
References: <cover.1355494956.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24840 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756237Ab2LNO11 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 09:27:27 -0500
In-Reply-To: <cover.1355494956.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During debugging a sctp problem, I hit a kernel NULL pointer
dereference in the jprobes callback jsctp_sf_eat_sack(). This
small patch fixes the panic.

Cc: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/probe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index bc6cd75..0a4e9d6 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -134,7 +134,7 @@ sctp_disposition_t jsctp_sf_eat_sack(const struct sctp_endpoint *ep,
 
 	sp = asoc->peer.primary_path;
 
-	if ((full || sp->cwnd != lcwnd) &&
+	if (sp && (full || sp->cwnd != lcwnd) &&
 	    (!port || asoc->peer.port == port ||
 	     ep->base.bind_addr.port == port)) {
 		lcwnd = sp->cwnd;
-- 
1.7.11.7
