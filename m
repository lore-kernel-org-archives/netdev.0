From: Patrick McHardy <kaber@trash.net>
Subject: [MACVLAN 01/02]: Remove unnecessary IFF_UP check
Date: Thu, 15 Nov 2007 16:54:30 +0100 (MET)
Message-ID: <20071115155429.12874.28112.sendpatchset@localhost.localdomain>
References: <20071115155427.12874.34461.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48713 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757688AbXKOPyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 10:54:32 -0500
In-Reply-To: <20071115155427.12874.34461.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[MACVLAN]: Remove unnecessary IFF_UP check

Only devices that are UP are in the hash, so macvlan_broadcast() doesn't
need to check for IFF_UP.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit e2d06a34b52a999e8c539d1cdef51ff523e2f2c2
tree f95a5eef37c421950ddc7318797909c0031ee948
parent 86aa441a13a474e66d484af38575609d9a0ff8ec
author Patrick McHardy <kaber@trash.net> Thu, 15 Nov 2007 16:33:24 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 15 Nov 2007 16:33:24 +0100

 drivers/net/macvlan.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 2e4bcd5..461149c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -73,8 +73,6 @@ static void macvlan_broadcast(struct sk_buff *skb,
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++) {
 		hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[i], hlist) {
 			dev = vlan->dev;
-			if (unlikely(!(dev->flags & IFF_UP)))
-				continue;
 
 			nskb = skb_clone(skb, GFP_ATOMIC);
 			if (nskb == NULL) {
