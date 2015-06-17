From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net 2/2] bridge: multicast: start querier timer when running user-space stp
Date: Wed, 17 Jun 2015 04:28:31 -0700
Message-ID: <1434540511-648-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1434540511-648-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: stephen@networkplumber.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, sashok@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34873 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545AbbFQL27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 07:28:59 -0400
Received: by pdbnf5 with SMTP id nf5so37905496pdb.2
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 04:28:59 -0700 (PDT)
In-Reply-To: <1434540511-648-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satish Ashok <sashok@cumulusnetworks.com>

When STP is running in user-space and querier is configured, the
querier timer is not started when a port goes to forwarding state.

Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Fixes: eb1d16414339 ("bridge: Add core IGMP snooping support")
---
 net/bridge/br_stp.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index fb3ebe615513..1e2f2f1ff6b0 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -456,6 +456,9 @@ void br_port_state_selection(struct net_bridge *br)
 				p->topology_change_ack = 0;
 				br_make_blocking(p);
 			}
+		} else if (br->stp_enabled == BR_USER_STP &&
+			   p->state == BR_STATE_FORWARDING) {
+			br_multicast_enable_port(p);
 		}
 
 		if (p->state == BR_STATE_FORWARDING)
-- 
2.4.3
