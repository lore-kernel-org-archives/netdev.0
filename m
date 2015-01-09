From: Dominique Martinet <dominique.martinet@cea.fr>
Subject: [PATCH] net/9p: Initialize opts->privport as it should be.
Date: Fri,  9 Jan 2015 13:05:56 +0100
Message-ID: <1420805156-16555-1-git-send-email-dominique.martinet@cea.fr>
Cc: v9fs-developer@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Dominique Martinet <dominique.martinet@cea.fr>
To: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We're currently using an uninitialized value if option privport is not set,
thus (almost) always using a privileged port.

Signed-off-by: Dominique Martinet <dominique.martinet@cea.fr>
---
 net/9p/trans_fd.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index 80d08f6..748703e 100644
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
