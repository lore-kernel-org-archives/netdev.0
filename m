From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 1/1] mISDN: Fix handling of receive buffer size in L1oIP
Date: Mon, 27 Jul 2009 19:24:04 +0200
Message-ID: <467d0b871314c60818f541024fcacca686f3e354.1248781021.git.keil@b1-systems.de>
References: <cover.1248781021.git.keil@b1-systems.de>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de,
	Andreas Eversberg <andreas@eversberg.eu>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d112a2.x-mailer.de ([212.162.53.4]:43776 "EHLO
	d112a2.x-mailer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbZG1LuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 07:50:25 -0400
In-Reply-To: <cover.1248781021.git.keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Eversberg <andreas@eversberg.eu>

The size of receive buffer pointer was used to get size of
receive buffer instead of recvbuf_size itself, so only 4/8
bytes could be transfered.

This is a regression to 2.6.30 introduced by commit 8c90e11e3543d7de612194a042a148caeaab5f1d
mISDN: Use kernel_{send,recv}msg instead of open coding

Signed-off-by: Andreas Eversberg <andreas@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/mISDN/l1oip_core.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
index 990e6a7..c3b661a 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -731,10 +731,10 @@ l1oip_socket_thread(void *data)
 	while (!signal_pending(current)) {
 		struct kvec iov = {
 			.iov_base = recvbuf,
-			.iov_len = sizeof(recvbuf),
+			.iov_len = recvbuf_size,
 		};
 		recvlen = kernel_recvmsg(socket, &msg, &iov, 1,
-					 sizeof(recvbuf), 0);
+					 recvbuf_size, 0);
 		if (recvlen > 0) {
 			l1oip_socket_parse(hc, &sin_rx, recvbuf, recvlen);
 		} else {
-- 
1.6.0.2

