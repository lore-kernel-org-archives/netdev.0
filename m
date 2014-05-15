From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 4/4] batman-adv: fix local TT check for outgoing arp requests in DAT
Date: Thu, 15 May 2014 20:50:52 +0200
Message-ID: <1400179852-4064-5-git-send-email-antonio@meshcoding.com>
References: <1400179852-4064-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:37260 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453AbaEOSxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 14:53:15 -0400
In-Reply-To: <1400179852-4064-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Change introduced by 88e48d7b3340ef07b108eb8a8b3813dd093cc7f7
("batman-adv: make DAT drop ARP requests targeting local clients")
implements a check that prevents DAT from using the caching
mechanism when the client that is supposed to provide a reply
to an arp request is local.

However change brought by be1db4f6615b5e6156c807ea8985171c215c2d57
("batman-adv: make the Distributed ARP Table vlan aware")
has not converted the above check into its vlan aware version
thus making it useless when the local client is behind a vlan.

Fix the behaviour by properly specifying the vlan when
checking for a client being local or not.

Reported-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/distributed-arp-table.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index b25fd64..aa5d494 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -940,8 +940,7 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 		 * additional DAT answer may trigger kernel warnings about
 		 * a packet coming from the wrong port.
 		 */
-		if (batadv_is_my_client(bat_priv, dat_entry->mac_addr,
-					BATADV_NO_FLAGS)) {
+		if (batadv_is_my_client(bat_priv, dat_entry->mac_addr, vid)) {
 			ret = true;
 			goto out;
 		}
-- 
1.8.5.5
