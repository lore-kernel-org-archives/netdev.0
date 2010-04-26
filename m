From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH] ieee802154: Fix oops during ieee802154_sock_ioctl
Date: Mon, 26 Apr 2010 18:46:42 +0400
Message-ID: <1272293202-11712-1-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Stefan Schmidt <stefan@datenfreihafen.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Schmidt <stefan@datenfreihafen.org>

Trying to run izlisten (from lowpan-tools tests) on a device that does not
exists I got the oops below. The problem is that we are using get_dev_by_name
without checking if we really get a device back. We don't in this case and
writing to dev->type generates this oops.

[Oops code removed by Dmitry Eremin-Solenikov]

If possible this patch should be applied to the current -rc fixes branch.

Signed-off-by: Stefan Schmidt <stefan@datenfreihafen.org>
Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/af_ieee802154.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index bad1c49..72340dd 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -147,6 +147,9 @@ static int ieee802154_dev_ioctl(struct sock *sk, struct ifreq __user *arg,
 	dev_load(sock_net(sk), ifr.ifr_name);
 	dev = dev_get_by_name(sock_net(sk), ifr.ifr_name);
 
+	if (!dev)
+		return -ENODEV;
+
 	if (dev->type == ARPHRD_IEEE802154 && dev->netdev_ops->ndo_do_ioctl)
 		ret = dev->netdev_ops->ndo_do_ioctl(dev, &ifr, cmd);
 
-- 
1.7.0
