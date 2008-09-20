From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2 net-next 12/15] tcp: remove retransmit_skb_hint clearing from failure
Date: Sun, 21 Sep 2008 00:47:55 +0300
Message-ID: <1221947278-16715-13-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221947278-16715-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-8-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-9-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-10-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-11-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-12-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36807 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbYITVsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 17:48:07 -0400
In-Reply-To: <1221947278-16715-12-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This doesn't much sense here afaict, probably never has. Since
fragmenting and collapsing deal the hints by themselves, there
should be very little reason for the rexmit loop to do that.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cd83713..97873cc 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2094,10 +2094,8 @@ begin_fwd:
 		if (sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))
 			continue;
=20
-		if (tcp_retransmit_skb(sk, skb)) {
-			tp->retransmit_skb_hint =3D NULL;
+		if (tcp_retransmit_skb(sk, skb))
 			return;
-		}
 		NET_INC_STATS_BH(sock_net(sk), mib_idx);
=20
 		if (skb =3D=3D tcp_write_queue_head(sk))
--=20
1.5.2.2

