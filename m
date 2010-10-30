From: Vasiliy Kulikov <segooon@gmail.com>
Subject: [PATCH] net: core: sock: fix information leak to userland
Date: Sat, 30 Oct 2010 18:26:40 +0400
Message-ID: <1288448801-6303-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Address" variable might be not fully initialized in sock->ops->get_name().
The only current implementation is get_name(), it leaves some padding
fields of sockaddr_tipc uninitialized.  It leads to leaking of contents
of kernel stack memory.

Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
---
 Compile tested.

 net/core/sock.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 3eed542..759dd81 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -930,6 +930,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 	{
 		char address[128];
 
+		memset(&address, 0, sizeof(address));
 		if (sock->ops->getname(sock, (struct sockaddr *)address, &lv, 2))
 			return -ENOTCONN;
 		if (lv < len)
-- 
1.7.0.4
