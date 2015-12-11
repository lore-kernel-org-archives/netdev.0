From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 1/2] ppp: define "ppp" device type
Date: Fri, 11 Dec 2015 19:54:49 +0100
Message-ID: <a88a45cd8b3a37873eef4d09f5adb1ff02a6649a.1449859708.git.g.nault@alphalink.fr>
References: <cover.1449859708.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:38913 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbbLKTAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 14:00:04 -0500
Content-Disposition: inline
In-Reply-To: <cover.1449859708.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let PPP devices be identified as such in /sys/class/net/<iface>/uevent.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 9a863c6..1cd7651 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1138,9 +1138,15 @@ static const struct net_device_ops ppp_netdev_ops = {
 	.ndo_get_stats64 = ppp_get_stats64,
 };
 
+static struct device_type ppp_type = {
+	.name = "ppp",
+};
+
 static void ppp_setup(struct net_device *dev)
 {
 	dev->netdev_ops = &ppp_netdev_ops;
+	SET_NETDEV_DEVTYPE(dev, &ppp_type);
+
 	dev->hard_header_len = PPP_HDRLEN;
 	dev->mtu = PPP_MRU;
 	dev->addr_len = 0;
-- 
2.6.4
