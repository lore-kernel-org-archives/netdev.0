From: David Miller <davem@davemloft.net>
Subject: Re: [net:master 4/8] net/ipv4/ipconfig.c:130:15: warning:
 'ic_addrservaddr' defined but not used
Date: Sat, 11 Jun 2016 20:40:53 -0700 (PDT)
Message-ID: <20160611.204053.255570617357501184.davem@davemloft.net>
References: <201606111545.01lVcXrw%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	ben.dooks@codethink.co.uk
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629AbcFLDk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 23:40:56 -0400
In-Reply-To: <201606111545.01lVcXrw%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Sat, 11 Jun 2016 15:22:48 +0800

>>> net/ipv4/ipconfig.c:130:15: warning: 'ic_addrservaddr' defined but not used [-Wunused-variable]
>     static __be32 ic_addrservaddr = NONE; /* IP Address of the IP addresses'server */

Should be fixed by:

====================
[PATCH] ipconfig: Protect ic_addrservaddr with IPCONFIG_DYNAMIC.

>> net/ipv4/ipconfig.c:130:15: warning: 'ic_addrservaddr' defined but not used [-Wunused-variable]
    static __be32 ic_addrservaddr = NONE; /* IP Address of the IP addresses'server */

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ipconfig.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index eccf9fd..1d71c40 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -127,7 +127,9 @@ __be32 ic_myaddr = NONE;		/* My IP address */
 static __be32 ic_netmask = NONE;	/* Netmask for local subnet */
 __be32 ic_gateway = NONE;	/* Gateway IP address */
 
+#ifdef IPCONFIG_DYNAMIC
 static __be32 ic_addrservaddr = NONE;	/* IP Address of the IP addresses'server */
+#endif
 
 __be32 ic_servaddr = NONE;	/* Boot server IP address */
 
-- 
2.1.0
