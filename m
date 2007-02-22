From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] IPv6 Updates for 2.6.21-rc1
Date: Wed, 21 Feb 2007 23:27:35 -0800 (PST)
Message-ID: <20070221.232735.107942036.davem@davemloft.net>
References: <20070221.222400.69214713.davem@davemloft.net>
	<20070222.160515.73902189.yoshfuji@linux-ipv6.org>
	<20070221.232306.51841241.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	yasuyuki.kozakai@toshiba.co.jp
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49948
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1945915AbXBVH1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 02:27:36 -0500
In-Reply-To: <20070221.232306.51841241.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 21 Feb 2007 23:23:06 -0800 (PST)

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Thu, 22 Feb 2007 16:05:15 +0900 (JST)
> 
> > ....fixed.  Please pull from new 2.6.21-rc1-inet6-20070222c branch:
> >   git pull git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git 2.6.21-rc1-inet6-20070222c
> 
> Thank you, it looks much better now.

I spoke too soon :-/  I guess you guys really do not like testing
ipv6 built modular, but it is what %99.9999 of people do.

  Building modules, stage 2.
  MODPOST 137 modules
WARNING: "__ipv6_addr_type" [net/ipv6/ipv6.ko] undefined!
make[1]: *** [__modpost] Error 1
make: *** [modules] Error 2

I'm going to check in the obvious fix myself:

commit be6b5ea03b10021d0afa7f72b4d930904853df0c
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed Feb 21 23:26:56 2007 -0800

    [IPV6]: Fix __ipv6_addr_type() export in correct place.
    
    It needs to be in net/ipv6/addrconf_core.c
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index 644e0c7..faaefb6 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -72,4 +72,5 @@ int __ipv6_addr_type(const struct in6_addr *addr)
 	return (IPV6_ADDR_RESERVED |
 		IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.4 */
 }
+EXPORT_SYMBOL(__ipv6_addr_type);
 
diff --git a/net/ipv6/ipv6_syms.c b/net/ipv6/ipv6_syms.c
index 0e8e067..e12e3d4 100644
--- a/net/ipv6/ipv6_syms.c
+++ b/net/ipv6/ipv6_syms.c
@@ -6,7 +6,6 @@
 #include <net/ip6_route.h>
 #include <net/xfrm.h>
 
-EXPORT_SYMBOL(__ipv6_addr_type);
 EXPORT_SYMBOL(icmpv6_send);
 EXPORT_SYMBOL(icmpv6_statistics);
 EXPORT_SYMBOL(icmpv6_err_convert);
