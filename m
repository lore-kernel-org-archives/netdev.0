From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] 2.6: allow CONFIG_NETFILTER=n and CONFIG_XFRM=y
Date: Tue, 27 Apr 2004 17:35:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040427153509.GD6836@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

the following patch should fix a compile error when setting
CONFIG_NETFILTER=n and CONFIG_XFRM=y.

Cheers,
Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=netfilter-config

This patch makes sure the kernel can be compiled with CONFIG_XFRM=y and
CONFIG_NETFILTER off.

--- linux-2.6.5/include/linux/netfilter_ipv4.h.dbg	2004-04-27 13:00:55.000000000 +0200
+++ linux-2.6.5/include/linux/netfilter_ipv4.h	2004-04-27 13:15:24.000000000 +0200
@@ -86,7 +86,7 @@
 extern int skb_ip_make_writable(struct sk_buff **pskb,
 				unsigned int writable_len);
 
-#ifdef CONFIG_XFRM
+#if defined(CONFIG_XFRM) && defined(CONFIG_NETFILTER)
 #include <net/route.h>
 #include <net/xfrm.h>
 

--HlL+5n6rz5pIUxbD--
