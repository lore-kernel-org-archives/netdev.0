From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv7 1/5][RESEND] Remove unnecessary locks from rtnetlink
Date: Tue, 18 Dec 2007 13:29:54 +0100
Message-ID: <11979809963141-git-send-email-panther@balabit.hu>
References: <11963527103201-git-send-email-panther@balabit.hu>
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:51449 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754112AbXLRM37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 07:29:59 -0500
In-Reply-To: <11963527103201-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The do_setlink() function is protected by rtnl, additional locks are unnecessary.
and the set_operstate() function is called from protected parts. Locks removed
from both functions.

The set_operstate() is also called from rtnl_create_link() and from no other places.
In rtnl_create_link() none of the changes is protected by set_lock_bh() except
inside set_operstate(), different locking scheme is not necessary
for the operstate.

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
