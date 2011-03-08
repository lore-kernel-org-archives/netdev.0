From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: [PATCH] tcp_cubic: enable TCP timestamps
Date: Tue, 8 Mar 2011 09:09:26 +0100
Message-ID: <20110308080926.GA22641@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sangtae Ha <sha2@ncsu.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:38598 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281Ab1CHIIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 03:08:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Hystart slow start algorithm requires precise RTT delay measurement=
s
to decide when to leave slow start. However, currently, CUBIC doesn't
enable TCP timestamps. This can cause Hystart to mis-estimate the RTT,
and to leave slow start too early, generating bad performance since
convergence to the optimal cwnd is slower.

Timestamps are already used by TCP Illinois, LP, Vegas, Veno and Yeah.

Signed-off-by: Lucas Nussbaum <lucas.nussbaum@loria.fr>

--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 71d5f2f..3a73509 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -406,6 +406,7 @@ static void bictcp_acked(struct sock *sk, u32 cnt, =
s32 rtt_us)
 }
=20
 static struct tcp_congestion_ops cubictcp =3D {
+       .flags          =3D TCP_CONG_RTT_STAMP,
        .init           =3D bictcp_init,
        .ssthresh       =3D bictcp_recalc_ssthresh,
        .cong_avoid     =3D bictcp_cong_avoid,
