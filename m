From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 3/3] Phonet: do not set POLLOUT in case of send buffer overflow
Date: Tue, 31 Aug 2010 01:57:05 +0300
Message-ID: <1283209025-28658-3-git-send-email-remi.denis-courmont@nokia.com>
References: <1283209025-28658-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-sa02.nokia.com ([147.243.1.48]:47126 "EHLO
	mgw-sa02.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754002Ab0H3W5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 18:57:05 -0400
Received: from localhost.localdomain (sddhcp197215.americas.nokia.com [172.19.197.215])
	by mgw-sa02.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id o7UMv0Aa024246
	for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 01:57:03 +0300
In-Reply-To: <1283209025-28658-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/socket.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 6e9848b..7c91f73 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -281,7 +281,9 @@ static unsigned int pn_socket_poll(struct file *fil=
e, struct socket *sock,
 	if (!mask && sk->sk_state =3D=3D TCP_CLOSE_WAIT)
 		return POLLHUP;
=20
-	if (sk->sk_state =3D=3D TCP_ESTABLISHED && atomic_read(&pn->tx_credit=
s))
+	if (sk->sk_state =3D=3D TCP_ESTABLISHED &&
+		atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf &&
+		atomic_read(&pn->tx_credits))
 		mask |=3D POLLOUT | POLLWRNORM | POLLWRBAND;
=20
 	return mask;
--=20
1.7.0.4

