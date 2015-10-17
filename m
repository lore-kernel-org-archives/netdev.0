From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/35] ipvs: Remove possibly unused variables from ip_vs_conn_net_{init,cleanup}
Date: Sat, 17 Oct 2015 13:32:46 +0200
Message-ID: <1445081590-2924-12-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Simon Horman <horms@verge.net.au>

If CONFIG_PROC_FS is undefined then the arguments of proc_create()
and remove_proc_entry() are unused. As a result the net variables of
ip_vs_conn_net_{init,cleanup} are unused.

net/netfilter/ipvs//ip_vs_conn.c: In function =E2=80=98ip_vs_conn_net_i=
nit=E2=80=99:
net/netfilter/ipvs//ip_vs_conn.c:1350:14: warning: unused variable =E2=80=
=98net=E2=80=99 [-Wunused-variable]
net/netfilter/ipvs//ip_vs_conn.c: In function =E2=80=98ip_vs_conn_net_c=
leanup=E2=80=99:
net/netfilter/ipvs//ip_vs_conn.c:1361:14: warning: unused variable =E2=80=
=98net=E2=80=99 [-Wunused-variable]
=2E..

Resolve this by dereferencing net as needed rather than storing it
in a variable.

=46ixes: 3d99376689ee ("ipvs: Pass ipvs not net into ip_vs_control_net_=
(init|cleanup)")
Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs=
_conn.c
index d1d168c..85ca189 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1347,23 +1347,20 @@ flush_again:
  */
 int __net_init ip_vs_conn_net_init(struct netns_ipvs *ipvs)
 {
-	struct net *net =3D ipvs->net;
-
 	atomic_set(&ipvs->conn_count, 0);
=20
-	proc_create("ip_vs_conn", 0, net->proc_net, &ip_vs_conn_fops);
-	proc_create("ip_vs_conn_sync", 0, net->proc_net, &ip_vs_conn_sync_fop=
s);
+	proc_create("ip_vs_conn", 0, ipvs->net->proc_net, &ip_vs_conn_fops);
+	proc_create("ip_vs_conn_sync", 0, ipvs->net->proc_net,
+		    &ip_vs_conn_sync_fops);
 	return 0;
 }
=20
 void __net_exit ip_vs_conn_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct net *net =3D ipvs->net;
-
 	/* flush all the connection entries first */
 	ip_vs_conn_flush(ipvs);
-	remove_proc_entry("ip_vs_conn", net->proc_net);
-	remove_proc_entry("ip_vs_conn_sync", net->proc_net);
+	remove_proc_entry("ip_vs_conn", ipvs->net->proc_net);
+	remove_proc_entry("ip_vs_conn_sync", ipvs->net->proc_net);
 }
=20
 int __init ip_vs_conn_init(void)
--=20
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
