From: pablo@netfilter.org
Subject: [PATCH 3/3] netfilter: xt_CT: remove a compile warning
Date: Tue,  3 Apr 2012 12:13:21 +0200
Message-ID: <1333448001-2507-4-git-send-email-pablo@netfilter.org>
References: <1333448001-2507-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33501 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753602Ab2DCKNs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 06:13:48 -0400
In-Reply-To: <1333448001-2507-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pablo Neira Ayuso <pablo@netfilter.org>

If CONFIG_NF_CONNTRACK_TIMEOUT=3Dn we have following warning :

  CC [M]  net/netfilter/xt_CT.o
net/netfilter/xt_CT.c: In function =E2=80=98xt_ct_tg_check_v1=E2=80=99:
net/netfilter/xt_CT.c:284: warning: label =E2=80=98err4=E2=80=99 define=
d but not used

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 0c8e438..138b75e 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -281,8 +281,10 @@ out:
 	info->ct =3D ct;
 	return 0;
=20
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 err4:
 	rcu_read_unlock();
+#endif
 err3:
 	nf_conntrack_free(ct);
 err2:
--=20
1.7.2.5
