From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next 5/8] ipv6: Check return of dev_set_allmulti
Date: Fri, 20 Jun 2008 08:55:23 +0800
Message-ID: <485AFFFB.5040901@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	NETDEV <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49402 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754670AbYFTA7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 20:59:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check the positive increment for allmulti to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/ipv6/ip6mr.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 1479618..7a97566 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -603,6 +603,7 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 	int vifi = vifc->mif6c_mifi;
 	struct mif_device *v = &vif6_table[vifi];
 	struct net_device *dev;
+	int err;
 
 	/* Is vif busy ? */
 	if (MIF_EXISTS(vifi))
@@ -632,7 +633,10 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 		return -EINVAL;
 	}
 
-	dev_set_allmulti(dev, 1);
+	/* Check whether allmulti overflow */
+	err = dev_set_allmulti(dev, 1);
+	if (err)
+		return err;
 
 	/*
 	 *	Fill in the VIF structures
-- 
1.5.3.4



