From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 3/8] net/9p/trans_fd.c: Fix unsigned return type
Date: Sun,  5 Sep 2010 21:00:21 +0200
Message-ID: <1283713226-8429-4-git-send-email-julia@diku.dk>
References: <1283713226-8429-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283713226-8429-1-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function has an unsigned return type, but returns a negative constant
to indicate an error condition.  The result of calling the function is
always stored in a variable of type (signed) int, and thus unsigned can be
dropped from the return type.

A sematic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@exists@
identifier f;
constant C;
@@

 unsigned f(...)
 { <+...
*  return -C;
 ...+> }
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/9p/trans_fd.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index c85109d..078eb16 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -222,7 +222,7 @@ static void p9_conn_cancel(struct p9_conn *m, int err)
 	}
 }
 
-static unsigned int
+static int
 p9_fd_poll(struct p9_client *client, struct poll_table_struct *pt)
 {
 	int ret, n;
