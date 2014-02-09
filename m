From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: =?UTF-8?q?=5BPATCH=20v2=2008/13=5D=20net=3A=20Move=20prototype=20declaration=20to=20include/net/ipx=2Eh=20from=20net/ipx/ipx=5Froute=2Ec?=
Date: Sun,  9 Feb 2014 22:24:33 +0530
Message-ID: <aa4aee4681c6f0be526df8fc2a8899793dc34801.1391955925.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-kernel@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	josh@joshtriplett.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move prototype definition of function to header file include/net/ipx.h
from net/ipx/ipx_route.c because they are used by more than one file.

This eliminates the following warning from net/ipx/af_ipx.c:
net/ipx/af_ipx.c:193:23: warning: no previous prototype for =E2=80=98ip=
xitf_find_using_net=E2=80=99 [-Wmissing-prototypes]
net/ipx/af_ipx.c:577:5: warning: no previous prototype for =E2=80=98ipx=
itf_send=E2=80=99 [-Wmissing-prototypes]
net/ipx/af_ipx.c:1219:8: warning: no previous prototype for =E2=80=98ip=
x_cksum=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 include/net/ipx.h   |    3 +++
 net/ipx/ipx_route.c |    4 ----
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/net/ipx.h b/include/net/ipx.h
index 9e9e354..75466ac 100644
--- a/include/net/ipx.h
+++ b/include/net/ipx.h
@@ -140,6 +140,9 @@ static __inline__ void ipxitf_hold(struct ipx_inter=
face *intrfc)
 }
=20
 void ipxitf_down(struct ipx_interface *intrfc);
+struct ipx_interface *ipxitf_find_using_net(__be32 net);
+int ipxitf_send(struct ipx_interface *intrfc, struct sk_buff *skb, cha=
r *node);
+__be16 ipx_cksum(struct ipxhdr *packet, int length);
=20
 static __inline__ void ipxitf_put(struct ipx_interface *intrfc)
 {
diff --git a/net/ipx/ipx_route.c b/net/ipx/ipx_route.c
index 30f4519..c1f0318 100644
--- a/net/ipx/ipx_route.c
+++ b/net/ipx/ipx_route.c
@@ -20,15 +20,11 @@ DEFINE_RWLOCK(ipx_routes_lock);
=20
 extern struct ipx_interface *ipx_internal_net;
=20
-extern __be16 ipx_cksum(struct ipxhdr *packet, int length);
 extern struct ipx_interface *ipxitf_find_using_net(__be32 net);
 extern int ipxitf_demux_socket(struct ipx_interface *intrfc,
 			       struct sk_buff *skb, int copy);
 extern int ipxitf_demux_socket(struct ipx_interface *intrfc,
 			       struct sk_buff *skb, int copy);
-extern int ipxitf_send(struct ipx_interface *intrfc, struct sk_buff *s=
kb,
-		       char *node);
-extern struct ipx_interface *ipxitf_find_using_net(__be32 net);
=20
 struct ipx_route *ipxrtr_lookup(__be32 net)
 {
--=20
1.7.9.5
