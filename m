From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] net: Fix oops in dev_ifsioc()
Date: Fri, 19 Dec 2008 07:04:31 +0000
Message-ID: <20081219070431.GA7189@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.177]:55720 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752615AbYLSHEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 02:04:38 -0500
Received: by ik-out-1112.google.com with SMTP id c29so180483ika.5
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2008 23:04:35 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A command like this: "brctl addif br1 eth1" issued as a user gave me
an oops when bridge module wasn't loaded. It's caused by using a dev
pointer before checking for NULL.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/core/dev.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 048cf11..daca72e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3745,11 +3745,13 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 {
 	int err;
 	struct net_device *dev = __dev_get_by_name(net, ifr->ifr_name);
-	const struct net_device_ops *ops = dev->netdev_ops;
+	const struct net_device_ops *ops;
 
 	if (!dev)
 		return -ENODEV;
 
+	ops = dev->netdev_ops;
+
 	switch (cmd) {
 		case SIOCSIFFLAGS:	/* Set interface flags */
 			return dev_change_flags(dev, ifr->ifr_flags);
