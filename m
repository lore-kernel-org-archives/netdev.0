From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 02/77] atm: cconvert clip driver to net_device_ops
Date: Fri, 20 Mar 2009 22:35:29 -0700
Message-ID: <20090321053712.726058041@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36649 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761000AbZCUFsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:18 -0400
Content-Disposition: inline; filename=atm-clip.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/atm/clip.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

--- a/net/atm/clip.c	2009-03-19 22:40:30.510964125 -0700
+++ b/net/atm/clip.c	2009-03-19 22:42:40.824964180 -0700
@@ -552,10 +552,13 @@ static int clip_setentry(struct atm_vcc 
 	return error;
 }
 
+static const struct net_device_ops clip_netdev_ops = {
+	.ndo_start_xmit = clip_start_xmit,
+};
+
 static void clip_setup(struct net_device *dev)
 {
-	dev->hard_start_xmit = clip_start_xmit;
-	/* sg_xmit ... */
+	dev->netdev_ops = &clip_netdev_ops;
 	dev->type = ARPHRD_ATM;
 	dev->hard_header_len = RFC1483LLC_LEN;
 	dev->mtu = RFC1626_MTU;
@@ -615,7 +618,7 @@ static int clip_device_event(struct noti
 	}
 
 	/* ignore non-CLIP devices */
-	if (dev->type != ARPHRD_ATM || dev->hard_start_xmit != clip_start_xmit)
+	if (dev->type != ARPHRD_ATM || dev->netdev_ops != &clip_netdev_ops)
 		return NOTIFY_DONE;
 
 	switch (event) {

-- 

