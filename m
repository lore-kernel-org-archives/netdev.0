From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] IPV6: Call inet6addr_chain notifiers on link down
Date: Tue, 03 Jul 2007 10:57:32 -0400
Message-ID: <468A63DC.2090500@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:52693 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755143AbXGCO56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 10:57:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently if the link is brought down via ip link or ifconfig down,
the inet6addr_chain notifiers are not called even though all
the addresses are removed from the interface.  This caused SCTP
to add duplicate addresses to it's list.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/ipv6/addrconf.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f96ed76..6496e03 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2472,6 +2472,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		write_unlock_bh(&idev->lock);
 
 		__ipv6_ifa_notify(RTM_DELADDR, ifa);
+		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifp);
 		in6_ifa_put(ifa);
 
 		write_lock_bh(&idev->lock);
-- 
1.5.0.3.438.gc49b2

