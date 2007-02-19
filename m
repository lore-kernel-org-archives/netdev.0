From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 9/18] [TCP] FRTO: Response should reset also snd_cwnd_cnt
Date: Mon, 19 Feb 2007 13:38:03 +0200
Message-ID: <11718850923324-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922604-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921021-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46068 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932134AbXBSLiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:16 -0500
In-Reply-To: <11718850921021-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since purpose is to reduce CWND, we prevent immediate growth. This
is not a major issue nor is "the correct way" specified anywhere.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2679279..9637abd 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2490,6 +2490,7 @@ static int tcp_ack_update_window(struct=20
 static void tcp_conservative_spur_to_response(struct tcp_sock *tp)
 {
 	tp->snd_cwnd =3D min(tp->snd_cwnd, tp->snd_ssthresh);
+	tp->snd_cwnd_cnt =3D 0;
 	tcp_moderate_cwnd(tp);
 }
=20
--=20
1.4.2

