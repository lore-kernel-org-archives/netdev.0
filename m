From: Eric Dumazet <erdnetdev@gmail.com>
Subject: [PATCH net-next] macvlan: broadcast addr should be part of mc_filter
Date: Thu, 07 Feb 2013 18:02:57 -0800
Message-ID: <1360288977.28557.77.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:52270 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab3BHCDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 21:03:01 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so1802908pab.33
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 18:03:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

commit cd431e738509e (macvlan: add multicast filter) forgot
the broadcast case.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 drivers/net/macvlan.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index f494da8..ce7c926 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -426,6 +426,9 @@ static void macvlan_set_mac_lists(struct net_device=
 *dev)
 		netdev_for_each_mc_addr(ha, dev) {
 			__set_bit(mc_hash(ha->addr), filter);
 		}
+
+		__set_bit(mc_hash(dev->broadcast), filter);
+
 		bitmap_copy(vlan->mc_filter, filter, MACVLAN_MC_FILTER_SZ);
 	}
 	dev_uc_sync(vlan->lowerdev, dev);
