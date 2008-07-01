From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v2 [PATCH net-next 4/7] ipv6: Check return of dev_set_allmulti
Date: Tue, 01 Jul 2008 11:26:39 +0800
Message-ID: <4869A3EF.60403@cn.fujitsu.com>
References: <4869A251.108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54358 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751256AbYGADbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2008 23:31:14 -0400
In-Reply-To: <4869A251.108@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check the positive increment for allmulti to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/ipv6/ip6mr.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 1479618..3e2d964 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -603,6 +603,7 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 	int vifi = vifc->mif6c_mifi;
 	struct mif_device *v = &vif6_table[vifi];
 	struct net_device *dev;
+	int err;
 
 	/* Is vif busy ? */
 	if (MIF_EXISTS(vifi))
@@ -632,7 +633,9 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 		return -EINVAL;
 	}
 
-	dev_set_allmulti(dev, 1);
+	err = dev_set_allmulti(dev, 1);
+	if (err)
+		return err;
 
 	/*
 	 *	Fill in the VIF structures
-- 1.5.3.4

