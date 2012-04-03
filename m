From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: xt_CT: remove a compile warning
Date: Tue, 03 Apr 2012 05:48:22 +0200
Message-ID: <1333424902.18626.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:52389 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394Ab2DCDs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 23:48:26 -0400
Received: by wejx9 with SMTP id x9so2090888wej.19
        for <netdev@vger.kernel.org>; Mon, 02 Apr 2012 20:48:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If CONFIG_NF_CONNTRACK_TIMEOUT=3Dn we have following warning :

  CC [M]  net/netfilter/xt_CT.o
net/netfilter/xt_CT.c: In function =E2=80=98xt_ct_tg_check_v1=E2=80=99:
net/netfilter/xt_CT.c:284: warning: label =E2=80=98err4=E2=80=99 define=
d but not used

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 0c8e438..6d4ca2f 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -269,7 +269,9 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_=
param *par)
 		} else {
 			ret =3D -ENOENT;
 			pr_info("Timeout policy base is empty\n");
-			goto err4;
+err4:
+			rcu_read_unlock();
+			goto err3;
 		}
 		rcu_read_unlock();
 	}
@@ -281,8 +283,6 @@ out:
 	info->ct =3D ct;
 	return 0;
=20
-err4:
-	rcu_read_unlock();
 err3:
 	nf_conntrack_free(ct);
 err2:
