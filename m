From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Sat,  5 Jan 2008 15:39:07 +0200
Message-ID: <1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11995403482366-git-send-email-ilpo.jarvinen@helsinki.fi> <11995403481730-git-send-email-ilpo.jarvinen@helsinki.fi> <11995403483512-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59521 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754852AbYAENjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 08:39:11 -0500
In-Reply-To: <11995403483512-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

net/xfrm/xfrm_state.c:
  xfrm_audit_state_delete          | -589
  xfrm_replay_check                | -542
  xfrm_audit_state_icvfail         | -520
  xfrm_audit_state_add             | -589
  xfrm_audit_state_replay_overflow | -523
  xfrm_audit_state_notfound_simple | -509
  xfrm_audit_state_notfound        | -521
 7 functions changed, 3793 bytes removed, diff: -3793

net/xfrm/xfrm_state.c:
  xfrm_audit_helper_pktinfo | +522
  xfrm_audit_helper_sainfo  | +598
 2 functions changed, 1120 bytes added, diff: +1120

net/xfrm/xfrm_state.o:
 9 functions changed, 1120 bytes added, 3793 bytes removed, diff: -2673

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/xfrm/xfrm_state.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 4dec655..81b0fce 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2008,8 +2008,8 @@ void __init xfrm_state_init(void)
 }
=20
 #ifdef CONFIG_AUDITSYSCALL
-static inline void xfrm_audit_helper_sainfo(struct xfrm_state *x,
-					    struct audit_buffer *audit_buf)
+static void xfrm_audit_helper_sainfo(struct xfrm_state *x,
+				     struct audit_buffer *audit_buf)
 {
 	struct xfrm_sec_ctx *ctx =3D x->security;
 	u32 spi =3D ntohl(x->id.spi);
@@ -2036,8 +2036,8 @@ static inline void xfrm_audit_helper_sainfo(struc=
t xfrm_state *x,
 	audit_log_format(audit_buf, " spi=3D%u(0x%x)", spi, spi);
 }
=20
-static inline void xfrm_audit_helper_pktinfo(struct sk_buff *skb, u16 =
family,
-					     struct audit_buffer *audit_buf)
+static void xfrm_audit_helper_pktinfo(struct sk_buff *skb, u16 family,
+				      struct audit_buffer *audit_buf)
 {
 	struct iphdr *iph4;
 	struct ipv6hdr *iph6;
--=20
1.5.0.6

