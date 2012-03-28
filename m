From: Li Yu <bingtian.ly@taobao.com>
Subject: [PATCH] tcp: remove useless update for flag parameter in tcp_enter_frto_loss()
Date: Wed, 28 Mar 2012 12:00:35 +0800
Message-ID: <4F728CE3.9010402@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.alibaba-inc.com ([121.0.29.128]:26267 "EHLO
	CNHZ-ExGW-01.ali.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1749667Ab2C1EPk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 00:15:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It seem that we forget remove below two lines after copying code :)

This update never impacts others.

Signed-off-by Li Yu <bingtian.ly@taobao.com>

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e886e2f..b2f8ada 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2169,8 +2169,6 @@ static void tcp_enter_frto_loss(struct sock *sk,
int allowed_segments, int flag)
                        /* For some reason this R-bit might get cleared=
? */
                        if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETR=
ANS)
                                tp->retrans_out +=3D tcp_skb_pcount(skb=
);
-                       /* ...enter this if branch just for the first s=
egment */
-                       flag |=3D FLAG_DATA_ACKED;
                } else {
                        if (TCP_SKB_CB(skb)->sacked & TCPCB_RETRANS)
                                tp->undo_marker =3D 0;

________________________________

This email (including any attachments) is confidential and may be legal=
ly privileged. If you received this email in error, please delete it im=
mediately and do not copy it or use it for any purpose or disclose its =
contents to any other person. Thank you.

=B1=BE=B5=E7=D3=CA(=B0=FC=C0=A8=C8=CE=BA=CE=B8=BD=BC=FE)=BF=C9=C4=DC=BA=
=AC=D3=D0=BB=FA=C3=DC=D7=CA=C1=CF=B2=A2=CA=DC=B7=A8=C2=C9=B1=A3=BB=A4=A1=
=A3=C8=E7=C4=FA=B2=BB=CA=C7=D5=FD=C8=B7=B5=C4=CA=D5=BC=FE=C8=CB=A3=AC=C7=
=EB=C4=FA=C1=A2=BC=B4=C9=BE=B3=FD=B1=BE=D3=CA=BC=FE=A1=A3=C7=EB=B2=BB=D2=
=AA=BD=AB=B1=BE=B5=E7=D3=CA=BD=F8=D0=D0=B8=B4=D6=C6=B2=A2=D3=C3=D7=F7=C8=
=CE=BA=CE=C6=E4=CB=FB=D3=C3=CD=BE=A1=A2=BB=F2=CD=B8=C2=B6=B1=BE=D3=CA=BC=
=FE=D6=AE=C4=DA=C8=DD=A1=A3=D0=BB=D0=BB=A1=A3
