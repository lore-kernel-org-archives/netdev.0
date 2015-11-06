From: Dmitry Safonov <0x7f454c46@gmail.com>
Subject: [PATCH] net: netfilter: fix GCC uninitialized warning
Date: Fri,  6 Nov 2015 21:48:14 +0300
Message-ID: <1446835694-6967-1-git-send-email-0x7f454c46@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Safonov <0x7f454c46@gmail.com>
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With x86_64_defconfig:
GCC thinks that in nfulnl_recv_config flags parameter is not inited but
it was under the same condition (nfula[NFULA_CFG_FLAGS] =3D=3D true).
Suppress this warning:
	net/netfilter/nfnetlink_log.c: In function =E2=80=98nfulnl_recv_config=
=E2=80=99:
	net/netfilter/nfnetlink_log.c:320:14: warning: =E2=80=98flags=E2=80=99=
 may be used uninitialized in this function [-Wmaybe-uninitialized]
  	inst->flags =3D flags;
	            ^
Signed-off-by: Dmitry Safonov <0x7f454c46@gmail.com>
---
 net/netfilter/nfnetlink_log.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_lo=
g.c
index 06eb48fceb42e4..d65f3b987b7f13 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -825,7 +825,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buf=
f *skb,
 	struct net *net =3D sock_net(ctnl);
 	struct nfnl_log_net *log =3D nfnl_log_pernet(net);
 	int ret =3D 0;
-	u16 flags;
+	u16 flags =3D 0; /* GCC uninitialized */
=20
 	if (nfula[NFULA_CFG_CMD]) {
 		u_int8_t pf =3D nfmsg->nfgen_family;
--=20
2.6.2
