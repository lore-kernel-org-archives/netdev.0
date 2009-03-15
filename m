From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 7/7] tcp: make sure xmit goal size never becomes zero
Date: Sun, 15 Mar 2009 02:23:07 +0200
Message-ID: <1237076587156-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12370765872509-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370765871159-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370765873185-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1237076587615-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1237076587514-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370765871746-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44913 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383AbZCOAXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 20:23:11 -0400
In-Reply-To: <12370765871746-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not too likely to happen, would basically require crafted
packets (must hit the max guard in tcp_bound_to_half_wnd()).
It seems that nothing that bad would happen as there's tcp_mems
and congestion window that prevent runaway at some point from
hurting all too much (I'm not that sure what all those zero
sized segments we would generate do though in write queue).
Preventing it regardless is certainly the best way to go.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Evgeniy Polyakov <zbr@ioremap.net>
Cc: Ingo Molnar <mingo@elte.hu>
---
 net/ipv4/tcp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2dc6741..274ab99 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -689,7 +689,7 @@ static unsigned int tcp_xmit_size_goal(struct sock =
*sk, u32 mss_now,
 		}
 	}
=20
-	return xmit_size_goal;
+	return max(xmit_size_goal, mss_now);
 }
=20
 static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
--=20
1.5.6.5

