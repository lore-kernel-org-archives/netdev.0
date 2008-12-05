From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 10/10] tcp: fix tso_should_defer in 64bit
Date: Fri,  5 Dec 2008 22:58:56 +0200
Message-ID: <1228510736-3655-11-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-8-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-9-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-10-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Bill Fink <billfink@mindspring.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58938 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754276AbYLEU7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 15:59:01 -0500
In-Reply-To: <1228510736-3655-10-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since jiffies is unsigned long, the types get expanded into
that and after long enough time the difference will therefore
always be > 1 (and that probably happens near boot as well as
iirc the first jiffies wrap is scheduler close after boot to
find out problems related to that early).

This was originally noted by Bill Fink in Dec'07 but nobody
never ended fixing it.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Bill Fink <billfink@mindspring.com>
---
 net/ipv4/tcp_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e65c114..dda42f0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1334,7 +1334,7 @@ static int tcp_tso_should_defer(struct sock *sk, =
struct sk_buff *skb)
=20
 	/* Defer for less than two clock ticks. */
 	if (tp->tso_deferred &&
-	    ((jiffies << 1) >> 1) - (tp->tso_deferred >> 1) > 1)
+	    (((u32)jiffies << 1) >> 1) - (tp->tso_deferred >> 1) > 1)
 		goto send_now;
=20
 	in_flight =3D tcp_packets_in_flight(tp);
--=20
1.5.2.2

