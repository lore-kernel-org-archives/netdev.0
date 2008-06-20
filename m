From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH net-next 5/8] ipv6: Check return of dev_set_allmulti
Date: Fri, 20 Jun 2008 11:06:54 +0800
Message-ID: <485B1ECE.7080106@cn.fujitsu.com>
References: <485AFFFB.5040901@cn.fujitsu.com> <20080619.190911.117307969.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60406 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751304AbYFTDKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 23:10:52 -0400
In-Reply-To: <20080619.190911.117307969.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-6-20 10:09:
> Please delete comment.

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
-- 
1.5.3.4

