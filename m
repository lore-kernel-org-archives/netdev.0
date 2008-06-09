From: akpm@linux-foundation.org
Subject: [patch 05/13] ipg: fix receivemode IPG_RM_RECEIVEMULTICAST{,HASH} in ipg_nic_set_multicast_list()
Date: Mon, 09 Jun 2008 16:33:50 -0700
Message-ID: <200806092333.m59NXoog014679@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	roel.kluin@gmail.com, romieu@fr.zoreil.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52795 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756444AbYFIXeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 19:34:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

The branches are dead code.  even when dev->flag IFF_MULTICAST (defined
0x1000) is set, dev->flags & IFF_MULTICAST & [boolean] always evaluates to
0.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ipg.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/ipg.c~ipg-fix-receivemode-ipg_rm_receivemulticasthash-in-ipg_nic_set_multicast_list drivers/net/ipg.c
--- a/drivers/net/ipg.c~ipg-fix-receivemode-ipg_rm_receivemulticasthash-in-ipg_nic_set_multicast_list
+++ a/drivers/net/ipg.c
@@ -577,12 +577,12 @@ static void ipg_nic_set_multicast_list(s
 		/* NIC to be configured in promiscuous mode. */
 		receivemode = IPG_RM_RECEIVEALLFRAMES;
 	} else if ((dev->flags & IFF_ALLMULTI) ||
-		   (dev->flags & IFF_MULTICAST &
+		   ((dev->flags & IFF_MULTICAST) &&
 		    (dev->mc_count > IPG_MULTICAST_HASHTABLE_SIZE))) {
 		/* NIC to be configured to receive all multicast
 		 * frames. */
 		receivemode |= IPG_RM_RECEIVEMULTICAST;
-	} else if (dev->flags & IFF_MULTICAST & (dev->mc_count > 0)) {
+	} else if ((dev->flags & IFF_MULTICAST) && (dev->mc_count > 0)) {
 		/* NIC to be configured to receive selected
 		 * multicast addresses. */
 		receivemode |= IPG_RM_RECEIVEMULTICASTHASH;
_
