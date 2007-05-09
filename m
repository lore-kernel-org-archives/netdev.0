From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [IPV6] ROUTE: Assign rt6i_idev for ip6_{prohibit,blk_hole}_entry.
Date: Wed, 09 May 2007 17:05:50 +0900 (JST)
Message-ID: <20070509.170550.81965404.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, snakebyte@gmx.de, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:37412 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754424AbXEIIFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 04:05:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to assign rt6i_idev for ip6_{prohibit,blk_hole}_entry as well
as we are doing for ip6_null_entry.

2.6.20-stable also needs this.

Closes: Bug#8450
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 452a82c..d1a9827 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4060,6 +4060,10 @@ int __init addrconf_init(void)
 		return err;
 
 	ip6_null_entry.rt6i_idev = in6_dev_get(&loopback_dev);
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	ip6_prohibit_entry.rt6i_idev = in6_dev_get(&loopback_dev);
+	ip6_blk_hole_entry.rt6i_idev = in6_dev_get(&loopback_dev);
+#endif
 
 	register_netdevice_notifier(&ipv6_dev_notf);
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
