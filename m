From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv7 1/5] Remove unnecessary locks from rtnetlink (in do_setlink)
Date: Thu, 29 Nov 2007 17:11:42 +0100
Message-ID: <11963527103201-git-send-email-panther@balabit.hu>
References: <11963527094077-git-send-email-panther@balabit.hu>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:50920 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756620AbXK2QL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 11:11:57 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 59C37C160B
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 17:11:56 +0100 (CET)
In-Reply-To: <11963527094077-git-send-email-panther@balabit.hu>
In-Reply-To: <ifgroup-20071129-165736-1196351856-panther@balabit.hu>
References: <ifgroup-20071129-165736-1196351856-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The do_setlink function is protected by rtnl, additional locks are unnecessary,
and the set_operstate() function is called from protected parts. Locks removed
from both functions.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---

 net/core/rtnetlink.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4a07e83..f95c6c5 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -562,9 +562,7 @@ static void set_operstate(struct net_device *dev, unsigned char transition)
 	}
 
 	if (dev->operstate != operstate) {
-		write_lock_bh(&dev_base_lock);
 		dev->operstate = operstate;
-		write_unlock_bh(&dev_base_lock);
 		netdev_state_change(dev);
 	}
 }
@@ -879,9 +877,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 
 	if (tb[IFLA_LINKMODE]) {
-		write_lock_bh(&dev_base_lock);
 		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
-		write_unlock_bh(&dev_base_lock);
 	}
 
 	err = 0;
