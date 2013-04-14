From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: tcp_memcontrol: minor: remove unused variable
Date: Sun, 14 Apr 2013 20:29:12 +0200
Message-ID: <dfb368afc3840edaf20d8d96be44c58e0f0bbd87.1365963999.git.dborkman@redhat.com>
References: <cover.1365963999.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752208Ab3DNS3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Apr 2013 14:29:17 -0400
In-Reply-To: <cover.1365963999.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 10b96f7306e5 (``tcp_memcontrol: remove a redundant statement
in tcp_destroy_cgroup()'') says ``We read the value but make no use
of it.'', but forgot to remove the variable declaration as well. This
was a follow-up commit of 3f1346193 (``memcg: decrement static keys
at real destroy time'') that removed the read of variable 'val'.

This fixes therefore:

  CC      net/ipv4/tcp_memcontrol.o
net/ipv4/tcp_memcontrol.c: In function =E2=80=98tcp_destroy_cgroup=E2=80=
=99:
net/ipv4/tcp_memcontrol.c:67:6: warning: unused variable =E2=80=98val=E2=
=80=99 [-Wunused-variable]

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv4/tcp_memcontrol.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index d52196f..da14436 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -64,7 +64,6 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
 {
 	struct cg_proto *cg_proto;
 	struct tcp_memcontrol *tcp;
-	u64 val;
=20
 	cg_proto =3D tcp_prot.proto_cgroup(memcg);
 	if (!cg_proto)
--=20
1.7.11.7
