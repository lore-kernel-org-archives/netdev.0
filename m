From: Kangjie Lu <kangjielu@gmail.com>
Subject: [PATCH] fix infoleak in llc
Date: Tue,  3 May 2016 16:35:05 -0400
Message-ID: <1462307705-5882-1-git-send-email-kjlu@gatech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu, insu@gatech.edu,
	Kangjie Lu <kjlu@gatech.edu>
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:36242 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756337AbcECUcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 16:32:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The stack object =E2=80=9Cinfo=E2=80=9D has a total size of 12 bytes. I=
ts last byte
is padding which is not initialized and leaked via =E2=80=9Cput_cmsg=E2=
=80=9D.

Signed-off-by: Kangjie Lu <kjlu@gatech.edu>
---
 net/llc/af_llc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index b3c52e3..8ae3ed9 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -626,6 +626,7 @@ static void llc_cmsg_rcv(struct msghdr *msg, struct=
 sk_buff *skb)
 	if (llc->cmsg_flags & LLC_CMSG_PKTINFO) {
 		struct llc_pktinfo info;
=20
+		memset(&info, 0, sizeof(info));
 		info.lpi_ifindex =3D llc_sk(skb->sk)->dev->ifindex;
 		llc_pdu_decode_dsap(skb, &info.lpi_sap);
 		llc_pdu_decode_da(skb, info.lpi_mac);
--=20
1.9.1
