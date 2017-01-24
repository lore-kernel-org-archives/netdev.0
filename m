From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch net-next] tipc: uninitialized return code in tipc_setsockopt()
Date: Tue, 24 Jan 2017 12:49:35 +0300
Message-ID: <20170124094935.GA19984@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        tipc-discussion@lists.sourceforge.net,
        kernel-janitors@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We shuffled some code around and added some new case statements here and
now "res" isn't initialized on all paths.

Fixes: 01fd12bb189a ("tipc: make replicast a user selectable option")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 5bec8aac5008..103d1fd058c0 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2348,7 +2348,7 @@ static int tipc_setsockopt(struct socket *sock, int lvl, int opt,
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
 	u32 value = 0;
-	int res;
+	int res = 0;
 
 	if ((lvl == IPPROTO_TCP) && (sock->type == SOCK_STREAM))
 		return 0;
@@ -2388,7 +2388,6 @@ static int tipc_setsockopt(struct socket *sock, int lvl, int opt,
 		break;
 	case TIPC_CONN_TIMEOUT:
 		tipc_sk(sk)->conn_timeout = value;
-		/* no need to set "res", since already 0 at this point */
 		break;
 	case TIPC_MCAST_BROADCAST:
 		tsk->mc_method.rcast = false;
