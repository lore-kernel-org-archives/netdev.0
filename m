From: Stefan Gula <steweg@ynet.sk>
Subject: [patch v1, kernel 3.2.1] RTNETLINK adjusting values of
 min_ifinfo_dump_size
Date: Wed, 25 Jan 2012 09:43:15 +0100 (CET)
Message-ID: <26709175.701327480995351.JavaMail.root@5-MeO-DMT.ynet.sk>
References: <30372884.681327480899559.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <30372884.681327480899559.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@gmail.com>

This patch extends the rtnetlink.c. The problem is that calcit, which
returns the value min_ifinfo_dump_size, is called without ability to
get device info as well (struct net_device *dev is not accessible from
it). This create a problem if required size of struct sk_buff *skb is
not enough big to comply with all data returned by fill_info function
for the interface that required size can vary over time, e.g. some
dynamic structures will be putted to skb like hlists or lists. To do
this patch extends the do_setlink function with recalculating of
min_ifinfo_dump_size accordingly to device type and get_size
functions.

Signed-off-by: Stefan Gula <steweg@gmail.com>

---

code needed to be ok before I can resubmit my macvlan source mode patch

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
