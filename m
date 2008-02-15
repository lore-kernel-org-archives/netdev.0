From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [PATCH] netconsole: avoid null pointer dereference at show_local_mac()
Date: Fri, 15 Feb 2008 18:45:48 +0900
Message-ID: <47B55F4C.5080703@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Satyam Sharma <satyam.sharma@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:41898 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754509AbYBOJqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 04:46:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

This patch avoids a null pointer dereference when we read local_mac 
for netconsole in configfs and shows default local mac address
value.

A null pointer dereference occurs when we call show_local_mac() via 
local_mac entry in configfs before we setup the content of netpoll
using netpoll_setup().

This patch is for 2.6.25-rc1.
Your comments are very welcome.

Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
---
Index: pre-release/drivers/net/netconsole.c
===================================================================
--- pre-release.orig/drivers/net/netconsole.c
+++ pre-release/drivers/net/netconsole.c
@@ -309,8 +309,8 @@ static ssize_t show_local_mac(struct net
 	struct net_device *dev = nt->np.dev;
 
 	DECLARE_MAC_BUF(mac);
-	return snprintf(buf, PAGE_SIZE, "%s\n",
-			print_mac(mac, dev->dev_addr));
+	return snprintf(buf, PAGE_SIZE, "%s\n", dev ?
+			print_mac(mac, dev->dev_addr) : "ff:ff:ff:ff:ff:ff");
 }
 
 static ssize_t show_remote_mac(struct netconsole_target *nt, char *buf)

-- 
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com

