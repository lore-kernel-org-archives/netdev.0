From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 29/51] ss: Use C99 initializer in netlink_show_one()
Date: Sat, 12 Aug 2017 14:04:48 +0200
Message-ID: <20170812120510.28750-30-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:59339 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752026AbdHLMFy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:05:54 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This has the additional benefit of initializing st.ino to zero which is
used later in is_sctp_assoc() function.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index f0d1c22f75cff..b4f89c85c2d52 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3470,17 +3470,18 @@ static int netlink_show_one(struct filter *f,
 				int rq, int wq,
 				unsigned long long sk, unsigned long long cb)
 {
-	struct sockstat st;
+	struct sockstat st = {
+		.state		= SS_CLOSE,
+		.rq		= rq,
+		.wq		= wq,
+		.local.family	= AF_NETLINK,
+		.remote.family	= AF_NETLINK,
+	};
 
 	SPRINT_BUF(prot_buf) = {};
 	const char *prot_name;
 	char procname[64] = {};
 
-	st.state = SS_CLOSE;
-	st.rq	 = rq;
-	st.wq	 = wq;
-	st.local.family = st.remote.family = AF_NETLINK;
-
 	if (f->f) {
 		st.rport = -1;
 		st.lport = pid;
-- 
2.13.1
