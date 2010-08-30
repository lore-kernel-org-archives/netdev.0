From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 2/3] Phonet: correct sendmsg() error code from sock_alloc_send_skb()
Date: Tue, 31 Aug 2010 01:57:04 +0300
Message-ID: <1283209025-28658-2-git-send-email-remi.denis-courmont@nokia.com>
References: <1283209025-28658-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-sa02.nokia.com ([147.243.1.48]:47095 "EHLO
	mgw-sa02.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753991Ab0H3W5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 18:57:04 -0400
Received: from localhost.localdomain (sddhcp197215.americas.nokia.com [172.19.197.215])
	by mgw-sa02.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id o7UMv0AZ024246
	for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 01:57:02 +0300
In-Reply-To: <1283209025-28658-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 5034f0f..04e3419 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -876,7 +876,7 @@ static int pep_sendmsg(struct kiocb *iocb, struct s=
ock *sk,
 	skb =3D sock_alloc_send_skb(sk, MAX_PNPIPE_HEADER + len,
 					flags & MSG_DONTWAIT, &err);
 	if (!skb)
-		return -ENOBUFS;
+		return err;
=20
 	skb_reserve(skb, MAX_PHONET_HEADER + 3);
 	err =3D memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
--=20
1.7.0.4

