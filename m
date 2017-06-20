From: Arnd Bergmann <arnd@arndb.de>
Subject: [net-next PATCH] tcp: md5: hide unused variable
Date: Tue, 20 Jun 2017 22:11:21 +0200
Message-ID: <20170620201203.121119-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Ivan Delalande <colona@arista.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changing from a memcpy to per-member comparison left the
size variable unused:

net/ipv4/tcp_ipv4.c: In function 'tcp_md5_do_lookup':
net/ipv4/tcp_ipv4.c:910:15: error: unused variable 'size' [-Werror=unused-variable]

This does not show up when CONFIG_IPV6 is enabled, but the
variable can be removed either way, along with the now unused
assignment.

Fixes: 6797318e623d ("tcp: md5: add an address prefix for key lookup")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/ipv4/tcp_ipv4.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index bf407f3e20dd..e20bcf0061af 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -907,7 +907,6 @@ struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_md5sig_key *key;
-	unsigned int size = sizeof(struct in_addr);
 	const struct tcp_md5sig_info *md5sig;
 	__be32 mask;
 	struct tcp_md5sig_key *best_match = NULL;
@@ -918,10 +917,7 @@ struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
 				       lockdep_sock_is_held(sk));
 	if (!md5sig)
 		return NULL;
-#if IS_ENABLED(CONFIG_IPV6)
-	if (family == AF_INET6)
-		size = sizeof(struct in6_addr);
-#endif
+
 	hlist_for_each_entry_rcu(key, &md5sig->head, node) {
 		if (key->family != family)
 			continue;
-- 
2.9.0
