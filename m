From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] NF_CONNTRACK_H323 must depend on (IPV6 || IPV6=n)
Date: Sun, 28 Jan 2007 23:21:37 +0100
Message-ID: <20070128222136.GZ6017@stusta.de>
References: <20070127234928.64d8e437.akpm@osdl.org> <20070128114148.b8067721.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netfilter@lists.netfilter.org, netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:42574 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932921AbXA1WV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jan 2007 17:21:29 -0500
Content-Disposition: inline
In-Reply-To: <20070128114148.b8067721.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 28, 2007 at 11:41:48AM -0800, Randy Dunlap wrote:
>...
> net/built-in.o: In function `q931_help':
> nf_conntrack_h323_main.c:(.text.q931_help+0x6ad): undefined reference to `ip6_route_output'
> nf_conntrack_h323_main.c:(.text.q931_help+0x6c3): undefined reference to `ip6_route_output'
>...

You didn't send your .config, but it seems you had CONFIG_IPV6=m and
CONFIG_NF_CONNTRACK_H323=y.

In this case, the untested patch below should fix it.

> ~Randy

cu
Adrian


<--  snip  -->


CONFIG_IPV6=m, CONFIG_NF_CONNTRACK_H323=y results in a compile error.

Fix this by letting NF_CONNTRACK_H323 depend on (IPV6 || IPV6=n).

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.20-rc6-mm1/net/netfilter/Kconfig.old	2007-01-28 23:06:37.000000000 +0100
+++ linux-2.6.20-rc6-mm1/net/netfilter/Kconfig	2007-01-28 23:06:49.000000000 +0100
@@ -165,7 +165,7 @@
 
 config NF_CONNTRACK_H323
 	tristate "H.323 protocol support (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && NF_CONNTRACK
+	depends on EXPERIMENTAL && NF_CONNTRACK && (IPV6 || IPV6=n)
 	help
 	  H.323 is a VoIP signalling protocol from ITU-T. As one of the most
 	  important VoIP protocols, it is widely used by voice hardware and

