From: Dominique Martinet <dominique.martinet@cea.fr>
Subject: [PATCH 1/2] net/9p: Initialize opts->privport as it should be.
Date: Fri, 13 Mar 2015 19:04:39 +0100
Message-ID: <1426269880-23860-1-git-send-email-dominique.martinet@cea.fr>
Cc: Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Dominique Martinet <dominique.martinet@cea.fr>
To: Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nautica.notk.org ([91.121.71.147]:41315 "EHLO nautica.notk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945947AbbCMSKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 14:10:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're currently using an uninitialized value if option privport is not set,
thus (almost) always using a privileged port.

Signed-off-by: Dominique Martinet <dominique.martinet@cea.fr>
---
 net/9p/trans_fd.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index c73b894..154479d 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -734,6 +734,7 @@ static int parse_opts(char *params, struct p9_fd_opts *opts)
 	opts->port = P9_PORT;
 	opts->rfd = ~0;
 	opts->wfd = ~0;
+	opts->privport = 0;
 
 	if (!params)
 		return 0;
-- 
1.9.3
