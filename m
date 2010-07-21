From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: NET_DSA depends on NET_ETHERNET
Date: Tue, 20 Jul 2010 17:45:30 -0700 (PDT)
Message-ID: <20100720.174530.139530021.davem@davemloft.net>
References: <20100706103417.8923b697.randy.dunlap@oracle.com>
	<20100710.190954.245403400.davem@davemloft.net>
	<4C462B44.5010107@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	buytenh@wantstofly.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4C462B44.5010107@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 20 Jul 2010 16:03:32 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> NET_DSA code selects and uses PHYLIB code, but PHYLIB depends on
> NET_ETHERNET.  However, "select" does not follow kconfig dependencies,
> so explicitly list that requirement here instead.
> 
> Fixes this kconfig warning:
> 
> warning: (NET_DSA && NET && EXPERIMENTAL && !S390 ...) selects PHYLIB which has unmet direct dependencies (!S390 && NET_ETHERNET)
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Randy, this has been fixed in net-2.6 for some time now.

And I'm pretty sure I sent a copy of this to you when I
checked it in :-)

--------------------
>From 336a283b9cbe47748ccd68fd8c5158f67cee644b Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@davemloft.net>
Date: Mon, 12 Jul 2010 20:03:42 -0700
Subject: [PATCH 09/24] dsa: Fix Kconfig dependencies.

Based upon a report by Randy Dunlap.

DSA needs PHYLIB, but PHYLIB needs NET_ETHERNET.  So, in order
to select PHYLIB we have to make DSA depend upon NET_ETHERNET.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/dsa/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index c51b554..1120178 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -1,7 +1,7 @@
 menuconfig NET_DSA
 	bool "Distributed Switch Architecture support"
 	default n
-	depends on EXPERIMENTAL && !S390
+	depends on EXPERIMENTAL && NET_ETHERNET && !S390
 	select PHYLIB
 	---help---
 	  This allows you to use hardware switch chips that use
-- 
1.7.1.1
