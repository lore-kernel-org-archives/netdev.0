From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH -next] net: fix compilation NG when !CONFIG_MODULE
Date: Tue, 26 Aug 2008 16:49:48 -0700
Message-ID: <48B4969C.60707@ct.jp.nec.com>
References: <20080826184008.6be39f19.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20080826184008.6be39f19.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

  CC      net/core/dev.o
net/core/dev.c:1001: error: redefinition of 'dev_load'
include/linux/netdevice.h:1645: error: previous definition of 'dev_load' was here
make[2]: *** [net/core/dev.o] Error 1

dev_load() is not used when CONFIG_MODULE disabled.

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
---
 net/core/dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b0a1ee8..bde9790 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -996,7 +996,7 @@ EXPORT_SYMBOL(netdev_bonding_change);
  *	privileges this function loads the module. If module loading is not
  *	available in this kernel then it becomes a nop.
  */
-
+#ifdef CONFIG_MODULES
 void dev_load(struct net *net, const char *name)
 {
 	struct net_device *dev;
@@ -1008,6 +1008,7 @@ void dev_load(struct net *net, const char *name)
 	if (!dev && capable(CAP_SYS_MODULE))
 		request_module("%s", name);
 }
+#endif
 
 /**
  *	dev_open	- prepare an interface for use.
-- 
1.5.6
