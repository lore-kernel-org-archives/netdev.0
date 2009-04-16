From: Yuta sugiura <ysugiura@miraclelinux.com>
Subject: [IPV6]: ROUTE:read ifname in rt6_info_route()
Date: Thu, 16 Apr 2009 20:05:05 +0900
Message-ID: <49E710E1.3060209@miraclelinux.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060709070904020308030106"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.miraclelinux.com ([122.216.84.157]:56418 "EHLO
	mailgw.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753705AbZDPLbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 07:31:15 -0400
Received: from mailgw.miraclelinux.com (localhost.localdomain [127.0.0.1])
	by localhost (Postfix) with SMTP id C506ED3078
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 20:03:10 +0900 (JST)
Received: from [10.1.1.159] (dhcp-1159.miraclelinux.com [10.1.1.159])
	by mailgw.miraclelinux.com (Postfix) with ESMTP id B2014D3077
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 20:03:10 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060709070904020308030106
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,
I have a suggestion about /proc/net/IPv6_route format.
In rt6_info_route(),  interface name is treated as a maximum 8 characters.
But the type of (struct rt6_inf *)->u.dst.dev->name is char[IFNAMESIZ= 16]
so, I think that it should change "%8s" to "%16s".

Thanks,



--------------060709070904020308030106
Content-Type: text/plain;
 name="ipv6_route_ifnamesiz.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6_route_ifnamesiz.patch"

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1394ddb..9ad58e7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2434,7 +2434,7 @@ static int ip6_route_dev_notify(struct notifier_block *this,
 
 #ifdef CONFIG_PROC_FS
 
-#define RT6_INFO_LEN (32 + 4 + 32 + 4 + 32 + 40 + 5 + 1)
+#define RT6_INFO_LEN (32 + 4 + 32 + 4 + 32 + 48 + 5 + 1)
 
 struct rt6_proc_arg
 {
@@ -2462,7 +2462,7 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 	} else {
 		seq_puts(m, "00000000000000000000000000000000");
 	}
-	seq_printf(m, " %08x %08x %08x %08x %8s\n",
+	seq_printf(m, " %08x %08x %08x %08x %16s\n",
 		   rt->rt6i_metric, atomic_read(&rt->u.dst.__refcnt),
 		   rt->u.dst.__use, rt->rt6i_flags,
 		   rt->rt6i_dev ? rt->rt6i_dev->name : "");

--------------060709070904020308030106--
