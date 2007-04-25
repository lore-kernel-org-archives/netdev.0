From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] [IPV6]: Consolidate common SNMP code
Date: Tue, 24 Apr 2007 22:16:08 -0700 (PDT)
Message-ID: <20070424.221608.84364009.davem@davemloft.net>
References: <20070425.132103.129791594.yoshfuji@linux-ipv6.org>
	<20070424.215429.42460618.davem@davemloft.net>
	<20070424.221239.00772916.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161612AbXDYFQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 01:16:01 -0400
In-Reply-To: <20070424.221239.00772916.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 24 Apr 2007 22:12:39 -0700 (PDT)

> This breaks the build with IPV6 modular:
> 
>   LD      .tmp_vmlinux1
> net/built-in.o: In function `snmp6_seq_show':
> proc.c:(.text+0x68244): undefined reference to `ipv6_statistics'
> proc.c:(.text+0x68250): undefined reference to `ipv6_statistics'

For now I'm fixing it like this so I can push the
changes out:

commit e579f5e28c243a23b43b434699e2399d9fcbbe81
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Tue Apr 24 22:15:40 2007 -0700

    [IPV6]: Fix Makefile thinko.
    
    obj-$(CONFIG_PROC_FS) --> ipv6-$(CONFIG_PROC_FS)
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 0acf64d..bb33309 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -15,6 +15,7 @@ ipv6-$(CONFIG_XFRM) += xfrm6_policy.o xfrm6_state.o xfrm6_input.o \
 ipv6-$(CONFIG_NETFILTER) += netfilter.o
 ipv6-$(CONFIG_IPV6_MULTIPLE_TABLES) += fib6_rules.o
 ipv6-$(CONFIG_IPV6_MIP6) += mip6.o
+ipv6-$(CONFIG_PROC_FS) += proc.o
 
 ipv6-objs += $(ipv6-y)
 
@@ -28,7 +29,6 @@ obj-$(CONFIG_INET6_XFRM_MODE_TUNNEL) += xfrm6_mode_tunnel.o
 obj-$(CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION) += xfrm6_mode_ro.o
 obj-$(CONFIG_INET6_XFRM_MODE_BEET) += xfrm6_mode_beet.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
-obj-$(CONFIG_PROC_FS) += proc.o
 
 obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
