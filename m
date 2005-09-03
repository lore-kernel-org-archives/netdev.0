From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.13-git3: build failure: sysctl_optmem_max
Date: Sat, 03 Sep 2005 21:49:43 +0900 (JST)
Message-ID: <20050903.214943.64835619.yoshfuji@linux-ipv6.org>
References: <20050903112756.D29708@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751183AbVICMs1@vger.kernel.org>
To: rmk+lkml@arm.linux.org.uk, davem@davemloft.net
In-Reply-To: <20050903112756.D29708@flint.arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20050903112756.D29708@flint.arm.linux.org.uk> (at Sat, 3 Sep 2005 11:27:56 +0100), Russell King <rmk+lkml@arm.linux.org.uk> says:

> While trying to build a kernel with CONFIG_SYSCTL disabled, the following
> error occurs:
> 
>   CC      net/ipv4/ip_sockglue.o
> net/ipv4/ip_sockglue.c: In function `ip_setsockopt':
> net/ipv4/ip_sockglue.c:622: error: `sysctl_optmem_max' undeclared (first use in
> net/ipv4/ip_sockglue.c:622: error: (Each undeclared identifier is reported only
> net/ipv4/ip_sockglue.c:622: error: for each function it appears in.)
> 
> It seems that sysctl_optmem_max is only available if CONFIG_SYSCTL is set.
> However, ip_setsockopt makes unconditional usage of this variable.

This should fix the issue.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1374,8 +1374,8 @@ extern void sk_init(void);
 
 #ifdef CONFIG_SYSCTL
 extern struct ctl_table core_table[];
-extern int sysctl_optmem_max;
 #endif
+extern int sysctl_optmem_max;
 
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
diff --git a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1719,8 +1719,8 @@ EXPORT_SYMBOL(sock_wfree);
 EXPORT_SYMBOL(sock_wmalloc);
 EXPORT_SYMBOL(sock_i_uid);
 EXPORT_SYMBOL(sock_i_ino);
-#ifdef CONFIG_SYSCTL
 EXPORT_SYMBOL(sysctl_optmem_max);
+#ifdef CONFIG_SYSCTL
 EXPORT_SYMBOL(sysctl_rmem_max);
 EXPORT_SYMBOL(sysctl_wmem_max);
 #endif

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
