From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] pppoe: warning fix
Date: Fri, 20 Jun 2008 16:19:12 -0700
Message-ID: <20080620161912.56f4b557@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Michal Ostrowski <mostrows@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:53416 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756027AbYFTXTO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 19:19:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix warning:
drivers/net/pppoe.c: In function =E2=80=98pppoe_recvmsg=E2=80=99:
drivers/net/pppoe.c:945: warning: comparison of distinct pointer types =
lacks a cast
because skb->len is unsigned int and total_len is size_t

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/pppoe.c	2008-06-20 15:56:46.000000000 -0700
+++ b/drivers/net/pppoe.c	2008-06-20 15:57:04.000000000 -0700
@@ -942,7 +942,7 @@ static int pppoe_recvmsg(struct kiocb *i
 	m->msg_namelen =3D 0;
=20
 	if (skb) {
-		total_len =3D min(total_len, skb->len);
+		total_len =3D min_t(size_t, total_len, skb->len);
 		error =3D skb_copy_datagram_iovec(skb, 0, m->msg_iov, total_len);
 		if (error =3D=3D 0)
 			error =3D total_len;
