From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: 2.6.28-git1 build failure
Date: Mon, 29 Dec 2008 15:44:29 +0800
Message-ID: <49587FDD.5000504@cn.fujitsu.com>
References: <495853C6.6030000@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, sean.hefty@intel.com,
	Aleksey Senin <alekseys@voltaire.com>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753662AbYL2Hoy@vger.kernel.org>
In-Reply-To: <495853C6.6030000@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap said the following on 2008-12-29 12:36:
> drivers/built-in.o: In function `addr_resolve_remote':
> addr.c:(.text+0x12fe75): undefined reference to `ip6_route_output'
> drivers/built-in.o: In function `rdma_translate_ip':
> (.text+0x1301a7): undefined reference to `ipv6_chk_addr'
> drivers/built-in.o: In function `rdma_resolve_ip':
> (.text+0x1303a9): undefined reference to `ipv6_chk_addr'
> drivers/built-in.o: In function `rdma_resolve_ip':
> (.text+0x13051b): undefined reference to `ip6_route_output'
> 
> when CONFIG_IPV6=n.
> 

Aleksey added IPv6 function to it but not change the Kconfig file.
The following patch will temporarily fix this build failure.
But IMHO separating the IPv4/IPv6 parts or using #ifdef would be better.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index a5dc78a..9535e13 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -36,7 +36,7 @@ config INFINIBAND_USER_MEM
 
 config INFINIBAND_ADDR_TRANS
 	bool
-	depends on INET
+	depends on INET && IPV6
 	default y
 
 source "drivers/infiniband/hw/mthca/Kconfig"
