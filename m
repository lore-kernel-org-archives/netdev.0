From: Benjamin Poirier <benjamin.poirier@polymtl.ca>
Subject: [PATCH] bridge: Forward reserved group addresses if !STP
Date: Mon, 18 Oct 2010 22:09:35 -0400
Message-ID: <1287454175-22903-1-git-send-email-benjamin.poirier@polymtl.ca>
References: <20101018093837.26bb149a@nehalam>
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.polymtl.ca ([132.207.4.11]:56477 "EHLO smtp.polymtl.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752682Ab0JSCQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 22:16:33 -0400
In-Reply-To: <20101018093837.26bb149a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make all frames sent to reserved group MAC addresses (01:80:c2:00:00:00 to
01:80:c2:00:00:0f) be forwarded if STP is disabled. This enables
forwarding EAPOL frames, among other things.

Signed-off-by: Benjamin Poirier <benjamin.poirier@polymtl.ca>
---
 net/bridge/br_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 826cd52..436488c 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -159,7 +159,7 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb)
 			goto drop;
 
 		/* If STP is turned off, then forward */
-		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
+		if (p->br->stp_enabled == BR_NO_STP)
 			goto forward;
 
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
-- 
1.7.1

