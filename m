From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 7/8] net: xfrm: fix old-style declaration
Date: Thu, 16 Jun 2016 15:59:25 +0200
Message-ID: <12896147.Nph51CCL66@wuerfel>
References: <20160616135020.3154461-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616135020.3154461-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modern C standards expect the '__inline__' keyword to come before the return
type in a declaration, and we get a couple of warnings for this with "make W=1"
in the xfrm{4,6}_policy.c files:

net/ipv6/xfrm6_policy.c:369:1: error: 'inline' is not at beginning of declaration [-Werror=old-style-declaration]
 static int inline xfrm6_net_sysctl_init(struct net *net)
net/ipv6/xfrm6_policy.c:374:1: error: 'inline' is not at beginning of declaration [-Werror=old-style-declaration]
 static void inline xfrm6_net_sysctl_exit(struct net *net)
net/ipv4/xfrm4_policy.c:339:1: error: 'inline' is not at beginning of declaration [-Werror=old-style-declaration]
 static int inline xfrm4_net_sysctl_init(struct net *net)
net/ipv4/xfrm4_policy.c:344:1: error: 'inline' is not at beginning of declaration [-Werror=old-style-declaration]
 static void inline xfrm4_net_sysctl_exit(struct net *net)

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/ipv4/xfrm4_policy.c | 8 ++++----
 net/ipv6/xfrm6_policy.c | 4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 7b0edb37a115..b644a23c3db0 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -295,7 +295,7 @@ static struct ctl_table xfrm4_policy_table[] = {
 	{ }
 };
 
-static int __net_init xfrm4_net_sysctl_init(struct net *net)
+static __net_init int xfrm4_net_sysctl_init(struct net *net)
 {
 	struct ctl_table *table;
 	struct ctl_table_header *hdr;
@@ -323,7 +323,7 @@ err_alloc:
 	return -ENOMEM;
 }
 
-static void __net_exit xfrm4_net_sysctl_exit(struct net *net)
+static __net_exit void xfrm4_net_sysctl_exit(struct net *net)
 {
 	struct ctl_table *table;
 
@@ -336,12 +336,12 @@ static void __net_exit xfrm4_net_sysctl_exit(struct net *net)
 		kfree(table);
 }
 #else /* CONFIG_SYSCTL */
-static int inline xfrm4_net_sysctl_init(struct net *net)
+static inline int xfrm4_net_sysctl_init(struct net *net)
 {
 	return 0;
 }
 
-static void inline xfrm4_net_sysctl_exit(struct net *net)
+static inline void xfrm4_net_sysctl_exit(struct net *net)
 {
 }
 #endif
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index c074771a10f7..6cc97003e4a9 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -366,12 +366,12 @@ static void __net_exit xfrm6_net_sysctl_exit(struct net *net)
 		kfree(table);
 }
 #else /* CONFIG_SYSCTL */
-static int inline xfrm6_net_sysctl_init(struct net *net)
+static inline int xfrm6_net_sysctl_init(struct net *net)
 {
 	return 0;
 }
 
-static void inline xfrm6_net_sysctl_exit(struct net *net)
+static inline void xfrm6_net_sysctl_exit(struct net *net)
 {
 }
 #endif
-- 
2.9.0
