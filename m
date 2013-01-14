From: pablo@netfilter.org
Subject: [PATCH 1/3] netfilter: xt_CT: fix unset return value if conntrack zone are disabled
Date: Tue, 15 Jan 2013 00:24:03 +0100
Message-ID: <1358205845-8522-2-git-send-email-pablo@netfilter.org>
References: <1358205845-8522-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38548 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757928Ab3ANXYR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 18:24:17 -0500
In-Reply-To: <1358205845-8522-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pablo Neira Ayuso <pablo@netfilter.org>

net/netfilter/xt_CT.c: In function =E2=80=98xt_ct_tg_check_v1=E2=80=99:
net/netfilter/xt_CT.c:250:6: warning: =E2=80=98ret=E2=80=99 may be used=
 uninitialized in this function [-Wmaybe-uninitialized]
net/netfilter/xt_CT.c: In function =E2=80=98xt_ct_tg_check_v0=E2=80=99:
net/netfilter/xt_CT.c:112:6: warning: =E2=80=98ret=E2=80=99 may be used=
 uninitialized in this function [-Wmaybe-uninitialized]

Reported-by: Borislav Petkov <bp@alien8.de>
Acked-by: Borislav Petkov <bp@alien8.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 2a08430..bde009e 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -109,7 +109,7 @@ static int xt_ct_tg_check_v0(const struct xt_tgchk_=
param *par)
 	struct xt_ct_target_info *info =3D par->targinfo;
 	struct nf_conntrack_tuple t;
 	struct nf_conn *ct;
-	int ret;
+	int ret =3D -EOPNOTSUPP;
=20
 	if (info->flags & ~XT_CT_NOTRACK)
 		return -EINVAL;
@@ -247,7 +247,7 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_=
param *par)
 	struct xt_ct_target_info_v1 *info =3D par->targinfo;
 	struct nf_conntrack_tuple t;
 	struct nf_conn *ct;
-	int ret;
+	int ret =3D -EOPNOTSUPP;
=20
 	if (info->flags & ~XT_CT_NOTRACK)
 		return -EINVAL;
--=20
1.7.10.4
