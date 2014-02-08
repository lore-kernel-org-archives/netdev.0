From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 09/13] net: Move prototype declaration to header file
 include/net/ipx.h from net/ipx/af_ipx.c
Date: Sun, 9 Feb 2014 01:33:57 +0530
Message-ID: <0eafec9f4039e058f88caa98e87578a4600d7087.1391888654.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move prototype declaration of functions to header file include/net/ipx.=
h
from net/ipx/af_ipx.c because they are used by more than one file.

This eliminates the following warning in=20
net/ipx/ipx_route.c:33:19: warning: no previous prototype for =E2=80=98=
ipxrtr_lookup=E2=80=99 [-Wmissing-prototypes]
net/ipx/ipx_route.c:52:5: warning: no previous prototype for =E2=80=98i=
pxrtr_add_route=E2=80=99 [-Wmissing-prototypes]
net/ipx/ipx_route.c:94:6: warning: no previous prototype for =E2=80=98i=
pxrtr_del_routes=E2=80=99 [-Wmissing-prototypes]
net/ipx/ipx_route.c:149:5: warning: no previous prototype for =E2=80=98=
ipxrtr_route_skb=E2=80=99 [-Wmissing-prototypes]
net/ipx/ipx_route.c:171:5: warning: no previous prototype for =E2=80=98=
ipxrtr_route_packet=E2=80=99 [-Wmissing-prototypes]
net/ipx/ipx_route.c:261:5: warning: no previous prototype for =E2=80=98=
ipxrtr_ioctl=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
---
 include/net/ipx.h |    8 ++++++++
 net/ipx/af_ipx.c  |    9 ---------
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/net/ipx.h b/include/net/ipx.h
index 75466ac..0143180 100644
--- a/include/net/ipx.h
+++ b/include/net/ipx.h
@@ -143,6 +143,14 @@ void ipxitf_down(struct ipx_interface *intrfc);
 struct ipx_interface *ipxitf_find_using_net(__be32 net);
 int ipxitf_send(struct ipx_interface *intrfc, struct sk_buff *skb, cha=
r *node);
 __be16 ipx_cksum(struct ipxhdr *packet, int length);
+int ipxrtr_add_route(__be32 network, struct ipx_interface *intrfc,
+		     unsigned char *node);
+void ipxrtr_del_routes(struct ipx_interface *intrfc);
+int ipxrtr_route_packet(struct sock *sk, struct sockaddr_ipx *usipx,
+			struct iovec *iov, size_t len, int noblock);
+int ipxrtr_route_skb(struct sk_buff *skb);
+struct ipx_route *ipxrtr_lookup(__be32 net);
+int ipxrtr_ioctl(unsigned int cmd, void __user *arg);
=20
 static __inline__ void ipxitf_put(struct ipx_interface *intrfc)
 {
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 994e28b..e5a00a9 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -84,15 +84,6 @@ DEFINE_SPINLOCK(ipx_interfaces_lock);
 struct ipx_interface *ipx_primary_net;
 struct ipx_interface *ipx_internal_net;
=20
-extern int ipxrtr_add_route(__be32 network, struct ipx_interface *intr=
fc,
-			    unsigned char *node);
-extern void ipxrtr_del_routes(struct ipx_interface *intrfc);
-extern int ipxrtr_route_packet(struct sock *sk, struct sockaddr_ipx *u=
sipx,
-			       struct iovec *iov, size_t len, int noblock);
-extern int ipxrtr_route_skb(struct sk_buff *skb);
-extern struct ipx_route *ipxrtr_lookup(__be32 net);
-extern int ipxrtr_ioctl(unsigned int cmd, void __user *arg);
-
 struct ipx_interface *ipx_interfaces_head(void)
 {
 	struct ipx_interface *rc =3D NULL;
--=20
1.7.9.5
