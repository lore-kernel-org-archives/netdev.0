From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 04/10] batman-adv: Combine two seq_puts() calls into one call in batadv_nc_nodes_seq_print_text()
Date: Tue, 13 Jun 2017 13:36:54 +0200
Message-ID: <20170613113700.31220-5-sw@simonwunderlich.de>
References: <20170613113700.31220-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Markus Elfring <elfring@users.sourceforge.net>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:43816 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753175AbdFMLhJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 07:37:09 -0400
In-Reply-To: <20170613113700.31220-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>

A bit of text was put into a sequence by two separate function calls.
Print the same data by a single function call instead.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/network-coding.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index e1f6fc72fe3e..3604d7899e2c 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1935,9 +1935,7 @@ int batadv_nc_nodes_seq_print_text(struct seq_file *seq, void *offset)
 						list)
 				seq_printf(seq, "%pM ",
 					   nc_node->addr);
-			seq_puts(seq, "\n");
-
-			seq_puts(seq, " Outgoing: ");
+			seq_puts(seq, "\n Outgoing: ");
 			/* For out_nc_node to this orig_node */
 			list_for_each_entry_rcu(nc_node,
 						&orig_node->out_coding_list,
-- 
2.11.0
