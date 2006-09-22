From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH] [Bugme-new] [Bug 7179] New: Compilation of .tmp_linux1 fails due to missing declaration in net/netfilter/xt_physdev.c
Date: Fri, 22 Sep 2006 11:55:56 +0200
Message-ID: <20060922095556.GA11991@ff.dom.local>
References: <20060921153701.2c49e331.akpm@osdl.org> <20060922084108.GB6820@ff.dom.local> <20060922092731.GC6820@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:15562 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1751146AbWIVJvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 05:51:49 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060922092731.GC6820@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2006 at 11:27:31AM +0200, Jarek Poplawski wrote:
...
> There is CONFIG_BRIDGE=m and this is the source of a problem:
> config shouldn't allow for:
> 
> CONFIG_NETFILTER_BRIDGE=y 
> CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y 
 
So here is a patch proposal.

Jarek P.

diff -Nurp linux-2.6.18-/net/Kconfig linux-2.6.18/net/Kconfig
--- linux-2.6.18-/net/Kconfig	2006-09-20 05:42:06.000000000 +0200
+++ linux-2.6.18/net/Kconfig	2006-09-22 11:42:19.000000000 +0200
@@ -143,7 +143,7 @@ config NETFILTER_DEBUG
 
 config BRIDGE_NETFILTER
 	bool "Bridged IP/ARP packets filtering"
-	depends on BRIDGE && NETFILTER && INET
+	depends on BRIDGE=y && NETFILTER && INET
 	default y
 	---help---
 	  Enabling this option will let arptables resp. iptables see bridged
