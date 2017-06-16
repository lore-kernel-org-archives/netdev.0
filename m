From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 1119/1146] ERROR:
 "tcp_rate_check_app_limited" [net/tls/tls.ko] undefined!
Date: Fri, 16 Jun 2017 11:29:32 -0400 (EDT)
Message-ID: <20170616.112932.1450887873847611693.davem@davemloft.net>
References: <201706160508.cYd5HQKm%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davejwatson@fb.com, kbuild-all@01.org, netdev@vger.kernel.org,
        borisp@mellanox.com, ilyal@mellanox.com, aviadye@mellanox.com
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60044 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdFPP3g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 11:29:36 -0400
In-Reply-To: <201706160508.cYd5HQKm%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Fri, 16 Jun 2017 05:19:10 +0800

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   3715c47bcda8bb56f7e2be27276282a2d0d48c09
> commit: 3c4d7559159bfe1e3b94df3a657b2cda3a34e218 [1119/1146] tls: kernel TLS support
> config: x86_64-randconfig-u0-06160346 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         git checkout 3c4d7559159bfe1e3b94df3a657b2cda3a34e218
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    ERROR: "tcp_prot" [net/tls/tls.ko] undefined!
>>> ERROR: "tcp_rate_check_app_limited" [net/tls/tls.ko] undefined!
>    ERROR: "tcp_register_ulp" [net/tls/tls.ko] undefined!
>    ERROR: "tcp_unregister_ulp" [net/tls/tls.ko] undefined!
>    ERROR: "do_tcp_sendpages" [net/tls/tls.ko] undefined!

I've applied the following to fix this.

David et al, you must be more responsive when you add build regressions
to the tree like this.

Thank you.

====================
>From 54144b4825ea7790cbc32a0f75a1103a97907646 Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem@davemloft.net>
Date: Fri, 16 Jun 2017 11:28:49 -0400
Subject: [PATCH] tls: Depend upon INET not plain NET.

We refer to TCP et al. symbols so have to use INET as
the dependency.

   ERROR: "tcp_prot" [net/tls/tls.ko] undefined!
>> ERROR: "tcp_rate_check_app_limited" [net/tls/tls.ko] undefined!
   ERROR: "tcp_register_ulp" [net/tls/tls.ko] undefined!
   ERROR: "tcp_unregister_ulp" [net/tls/tls.ko] undefined!
   ERROR: "do_tcp_sendpages" [net/tls/tls.ko] undefined!

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/tls/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tls/Kconfig b/net/tls/Kconfig
index 61e5329..b13541f 100644
--- a/net/tls/Kconfig
+++ b/net/tls/Kconfig
@@ -3,7 +3,7 @@
 #
 config TLS
 	tristate "Transport Layer Security support"
-	depends on NET
+	depends on INET
 	default m
 	---help---
 	Enable kernel support for TLS protocol. This allows symmetric
-- 
2.4.11
