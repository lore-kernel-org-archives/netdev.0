From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [Bugme-new] [Bug 7179] New: Compilation of .tmp_linux1
 fails due to missing declaration in net/netfilter/xt_physdev.c
Date: Fri, 22 Sep 2006 12:15:43 +0200
Message-ID: <4513B7CF.5040209@trash.net>
References: <20060921153701.2c49e331.akpm@osdl.org> <20060922084108.GB6820@ff.dom.local> <20060922092731.GC6820@ff.dom.local> <20060922095556.GA11991@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090004010700030903070808"
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:12794 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750704AbWIVKPs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 06:15:48 -0400
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20060922095556.GA11991@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090004010700030903070808
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Jarek Poplawski wrote:
> On Fri, Sep 22, 2006 at 11:27:31AM +0200, Jarek Poplawski wrote:
> ...
> 
>>There is CONFIG_BRIDGE=m and this is the source of a problem:
>>config shouldn't allow for:
>>
>>CONFIG_NETFILTER_BRIDGE=y 
>>CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y 
> 
>  
> So here is a patch proposal.
> 
> Jarek P.
> 
> diff -Nurp linux-2.6.18-/net/Kconfig linux-2.6.18/net/Kconfig
> --- linux-2.6.18-/net/Kconfig	2006-09-20 05:42:06.000000000 +0200
> +++ linux-2.6.18/net/Kconfig	2006-09-22 11:42:19.000000000 +0200
> @@ -143,7 +143,7 @@ config NETFILTER_DEBUG
>  
>  config BRIDGE_NETFILTER
>  	bool "Bridged IP/ARP packets filtering"
> -	depends on BRIDGE && NETFILTER && INET
> +	depends on BRIDGE=y && NETFILTER && INET

We should fix the physdev dependencies since this is what is causing
problems.


Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------090004010700030903070808
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 0a28d2c..ce94732 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -365,7 +365,7 @@ config NETFILTER_XT_MATCH_MULTIPORT
 
 config NETFILTER_XT_MATCH_PHYSDEV
 	tristate '"physdev" match support'
-	depends on NETFILTER_XTABLES && BRIDGE_NETFILTER
+	depends on NETFILTER_XTABLES && BRIDGE && BRIDGE_NETFILTER
 	help
 	  Physdev packet matching matches against the physical bridge ports
 	  the IP packet arrived on or will leave by.

--------------090004010700030903070808--
