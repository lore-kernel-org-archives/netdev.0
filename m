From: Stefan Gula <steweg@ynet.sk>
Subject: [patch v2, kernel 3.2.1] RTNETLINK adjusting values of
 min_ifinfo_dump_size
Date: Thu, 26 Jan 2012 22:01:06 +0100 (CET)
Message-ID: <3280801.2791327611666778.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@gmail.com>

Setting link parameters on a netdevice changes the value
of if_nlmsg_size(), therefore it is necessary to recalculate
min_ifinfo_dump_size.

Signed-off-by: Stefan Gula <steweg@gmail.com>

---
V2-changelog: adjusted commit message

--- linux-3.2.1-orig/net/core/rtnetlink.c	2012-01-12 20:42:45.000000000 +0100
+++ linux/net/core/rtnetlink.c	2012-01-24 14:26:58.083219352 +0100
@@ -1506,6 +1506,9 @@ errout:
 
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	min_ifinfo_dump_size = max_t(u16, if_nlmsg_size(dev),
+					min_ifinfo_dump_size);
+
 	return err;
 }
