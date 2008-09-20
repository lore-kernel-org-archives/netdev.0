From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 05/15] tcp: Kill precaution that's very likely obsolete
Date: Sat, 20 Sep 2008 20:52:23 +0300
Message-ID: <1221933153-11874-6-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221933153-11874-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37645 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbYITRwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 13:52:38 -0400
In-Reply-To: <1221933153-11874-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I suspect it might have been related to the changed amount
of lost skbs, which was counted by retransmit_cnt_hint that
got dropped.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 84935cf..d7544ec 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2385,10 +2385,6 @@ static void tcp_undo_cwr(struct sock *sk, const =
int undo)
 	}
 	tcp_moderate_cwnd(tp);
 	tp->snd_cwnd_stamp =3D tcp_time_stamp;
-
-	/* There is something screwy going on with the retrans hints after
-	   an undo */
-	tcp_clear_all_retrans_hints(tp);
 }
=20
 static inline int tcp_may_undo(struct tcp_sock *tp)
--=20
1.5.2.2

