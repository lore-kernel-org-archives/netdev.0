From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/15] batman-adv: fix wrong dhcp option list browsing
Date: Sun, 29 Apr 2012 10:57:41 +0200
Message-ID: <1335689867-8017-10-git-send-email-ordex@autistici.org>
References: <1335689867-8017-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:57909 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458Ab2D2I4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2012 04:56:55 -0400
In-Reply-To: <1335689867-8017-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In is_type_dhcprequest(), while parsing a DHCP message, if the entry we found in
the option list is neither a padding nor the dhcp-type, we have to ignore it and
jump as many bytes as its length + 1. The "+ 1" byte is given by the subtype
field itself that has to be jumped too.

Reported-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/gateway_client.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 6f9b9b7..47f7186 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -558,10 +558,10 @@ static bool is_type_dhcprequest(struct sk_buff *skb, int header_len)
 			p++;
 
 			/* ...and then we jump over the data */
-			if (pkt_len < *p)
+			if (pkt_len < 1 + (*p))
 				goto out;
-			pkt_len -= *p;
-			p += (*p);
+			pkt_len -= 1 + (*p);
+			p += 1 + (*p);
 		}
 	}
 out:
-- 
1.7.9.4
