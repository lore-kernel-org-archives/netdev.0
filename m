From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: =?UTF-8?q?=5BPATCH=20v2=2006/13=5D=20net=3A=20Move=20prototype=20declaration=20to=20appropriate=20header=20file=20from=20decnet/af=5Fdecnet=2Ec?=
Date: Sun,  9 Feb 2014 22:20:09 +0530
Message-ID: <46a1a3d1431e13a5c253833cf44c869eb0d43993.1391955925.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Steffen Hurrle <steffen@hurrle.net>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net, josh@joshtriplett.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move prototype declaration of functions to header file include/net/dn_r=
oute.h
from net/decnet/af_decnet.c because it is used by more than one file.

This eliminates the following warning in net/decnet/dn_route.c:
net/decnet/dn_route.c:629:5: warning: no previous prototype for =E2=80=98=
dn_route_rcv=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 include/net/dn_route.h |    2 ++
 net/decnet/af_decnet.c |    2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/dn_route.h b/include/net/dn_route.h
index b409ad6..55df993 100644
--- a/include/net/dn_route.h
+++ b/include/net/dn_route.h
@@ -20,6 +20,8 @@ int dn_route_output_sock(struct dst_entry __rcu **ppr=
t, struct flowidn *,
 			 struct sock *sk, int flags);
 int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb);
 void dn_rt_cache_flush(int delay);
+int dn_route_rcv(struct sk_buff *skb, struct net_device *dev,
+		 struct packet_type *pt, struct net_device *orig_dev);
=20
 /* Masks for flags field */
 #define DN_RT_F_PID 0x07 /* Mask for packet type                      =
*/
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 2954dcb..24d9193 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2104,8 +2104,6 @@ static struct notifier_block dn_dev_notifier =3D =
{
 	.notifier_call =3D dn_device_event,
 };
=20
-extern int dn_route_rcv(struct sk_buff *, struct net_device *, struct =
packet_type *, struct net_device *);
-
 static struct packet_type dn_dix_packet_type __read_mostly =3D {
 	.type =3D		cpu_to_be16(ETH_P_DNA_RT),
 	.func =3D		dn_route_rcv,
--=20
1.7.9.5
