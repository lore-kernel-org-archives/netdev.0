From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] Phonet: fix aligned-mode pipe socket buffer header reserve
Date: Tue, 15 Mar 2011 10:37:02 +0200
Message-ID: <1300178222-2877-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.47]:53884 "EHLO mgw-sa01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754952Ab1COIhA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 04:37:00 -0400
Received: from leon.remlab.com (helruo-dhcp021156.ntc.nokia.com [172.21.21.156])
	by mgw-sa01.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p2F8audt025124
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 10:36:56 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the pipe uses aligned-mode data packets, we must reserve 4 bytes
instead of 3 for the pipe protocol header. Otherwise the Phonet header
would not be aligned, resulting in potentially corrupted headers with
later unaligned memory writes.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 68e635f..f17fd84 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -1055,7 +1055,7 @@ static int pep_sendmsg(struct kiocb *iocb, struct=
 sock *sk,
 	if (!skb)
 		return err;
=20
-	skb_reserve(skb, MAX_PHONET_HEADER + 3);
+	skb_reserve(skb, MAX_PHONET_HEADER + 3 + pn->aligned);
 	err =3D memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
 	if (err < 0)
 		goto outfree;
--=20
1.7.1

