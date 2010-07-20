From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] net: NET_DSA depends on NET_ETHERNET
Date: Tue, 20 Jul 2010 16:03:32 -0700
Message-ID: <4C462B44.5010107@oracle.com>
References: <20100706190519.93d8b785.sfr@canb.auug.org.au>	<20100706103417.8923b697.randy.dunlap@oracle.com> <20100710.190954.245403400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100710.190954.245403400.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

NET_DSA code selects and uses PHYLIB code, but PHYLIB depends on
NET_ETHERNET.  However, "select" does not follow kconfig dependencies,
so explicitly list that requirement here instead.

Fixes this kconfig warning:

warning: (NET_DSA && NET && EXPERIMENTAL && !S390 ...) selects PHYLIB which has unmet direct dependencies (!S390 && NET_ETHERNET)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
---
 net/dsa/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Is there some reason that NET_DSA is bool instead of tristate?
I.e., net/dsa/ code cannot be built as loadable modules?
--- linux-next-20100713.orig/net/dsa/Kconfig
+++ linux-next-20100713/net/dsa/Kconfig
@@ -1,7 +1,7 @@
 menuconfig NET_DSA
 	bool "Distributed Switch Architecture support"
 	default n
-	depends on EXPERIMENTAL && !S390
+	depends on EXPERIMENTAL && !S390 && NET_ETHERNET
 	select PHYLIB
 	---help---
 	  This allows you to use hardware switch chips that use
