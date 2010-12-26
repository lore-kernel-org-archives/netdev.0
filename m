From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Mon, 27 Dec 2010 10:41:44 +1100
Message-ID: <20101227104144.cedc2d63.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/ipv4/fib_frontend.c between commit
e058464990c2ef1f3ecd6b83a154913c3c06f02a ("Revert "ipv4: Allow
configuring subnets as local addresses"") from Linus' tree and commit
5811662b15db018c740c57d037523683fd3e6123 ("net: use the macros defined
for the members of flowi") from the net tree.

Just context changes (I think).  I fixed it up (see below) and can carry
the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/fib_frontend.c
index c19c1f7,9f8bb68..0000000
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@@ -158,11 -158,8 +158,7 @@@ static void fib_flush(struct net *net
  struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
  {
  	struct flowi fl = {
- 		.nl_u = {
- 			.ip4_u = {
- 				.daddr = addr
- 			}
- 		},
+ 		.fl4_dst = addr,
 -		.flags = FLOWI_FLAG_MATCH_ANY_IIF
  	};
  	struct fib_result res = { 0 };
  	struct net_device *dev = NULL;
