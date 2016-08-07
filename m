From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH] tc/m_gact: Fix action_a2n() return code check
Date: Sun,  7 Aug 2016 13:19:01 +0200
Message-ID: <20160807111621.6D056647E4@mail.nwl.cc>
Cc: Mark Bloch <markb@mellanox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47111 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574AbcHGLQY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Aug 2016 07:16:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function returns zero on success.

Reported-by: Mark Bloch <markb@mellanox.com>
Fixes: 69f5aff63c770b ("tc: use action_a2n() everywhere")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_gact.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/m_gact.c b/tc/m_gact.c
index c0a938c716b6a..2bfd9a7c317e4 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -73,7 +73,7 @@ get_act(char ***argv_p)
 {
 	int n;
 
-	if (!action_a2n(**argv_p, &n, false)) {
+	if (action_a2n(**argv_p, &n, false)) {
 		fprintf(stderr, "bad action type %s\n", **argv_p);
 		return -10;
 	}
-- 
2.9.0
