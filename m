From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] bonding: update documentation section after dev->trans_start removal
Date: Wed,  4 May 2016 22:51:47 +0200
Message-ID: <1462395107-18703-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:53302 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753189AbcEDUvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 16:51:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers that use LLTX need to update trans_start of the netdev_queue.
(Most drivers don't use LLTX; stack does this update if .ndo_start_xmit
 returned TX_OK).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Documentation/networking/bonding.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 334b49e..57f52cd 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -1880,8 +1880,8 @@ or more peers on the local network.
 
 	The ARP monitor relies on the device driver itself to verify
 that traffic is flowing.  In particular, the driver must keep up to
-date the last receive time, dev->last_rx, and transmit start time,
-dev->trans_start.  If these are not updated by the driver, then the
+date the last receive time, dev->last_rx.  Drivers that use NETIF_F_LLTX
+flag must also update netdev_queue->trans_start.  If they do not, then the
 ARP monitor will immediately fail any slaves using that driver, and
 those slaves will stay down.  If networking monitoring (tcpdump, etc)
 shows the ARP requests and replies on the network, then it may be that
-- 
2.7.3
