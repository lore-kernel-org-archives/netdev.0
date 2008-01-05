From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/4] [CCID3]: Kill some bloat
Date: Sat,  5 Jan 2008 15:39:08 +0200
Message-ID: <11995403493735-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11995403482366-git-send-email-ilpo.jarvinen@helsinki.fi> <11995403481730-git-send-email-ilpo.jarvinen@helsinki.fi> <11995403483512-git-send-email-ilpo.jarvinen@helsinki.fi> <1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47078 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754871AbYAENjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 08:39:13 -0500
In-Reply-To: <1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Without a number of CONFIG.*DEBUG:

net/dccp/ccids/ccid3.c:
  ccid3_hc_tx_update_x          | -170
  ccid3_hc_tx_packet_sent       | -175
  ccid3_hc_tx_packet_recv       | -169
  ccid3_hc_tx_no_feedback_timer | -192
  ccid3_hc_tx_send_packet       | -144
 5 functions changed, 850 bytes removed, diff: -850

net/dccp/ccids/ccid3.c:
  ccid3_update_send_interval | +191
 1 function changed, 191 bytes added, diff: +191

net/dccp/ccids/ccid3.o:
 6 functions changed, 191 bytes added, 850 bytes removed, diff: -659

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/dccp/ccids/ccid3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 00b5f11..8a817dd 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -97,7 +97,7 @@ static inline u64 rfc3390_initial_rate(struct sock *s=
k)
 /*
  * Recalculate t_ipi and delta (should be called whenever X changes)
  */
-static inline void ccid3_update_send_interval(struct ccid3_hc_tx_sock =
*hctx)
+static void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
 {
 	/* Calculate new t_ipi =3D s / X_inst (X_inst is in 64 * bytes/second=
) */
 	hctx->ccid3hctx_t_ipi =3D scaled_div32(((u64)hctx->ccid3hctx_s) << 6,
--=20
1.5.0.6

