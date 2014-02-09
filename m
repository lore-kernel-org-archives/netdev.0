From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: =?UTF-8?q?=5BPATCH=20v2=2007/13=5D=20net=3A=20Move=20prototype=20declaration=20to=20header=20file=20include/net/dn=2Eh=20from=20net/decnet/af=5Fdecnet=2Ec?=
Date: Sun,  9 Feb 2014 22:22:53 +0530
Message-ID: <308804ddc5f1fb40d26af2a7e89cf06e0ffc0581.1391955925.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: josh@joshtriplett.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Steffen Hurrle <steffen@hurrle.net>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move prototype declaration of functions to header file include/net/dn.h
from net/decnet/af_decnet.c because they are used by more than one file=
=2E

This eliminates the following warning in net/decnet/af_decnet.c:
net/decnet/sysctl_net_decnet.c:354:6: warning: no previous prototype fo=
r =E2=80=98dn_register_sysctl=E2=80=99 [-Wmissing-prototypes]
net/decnet/sysctl_net_decnet.c:359:6: warning: no previous prototype fo=
r =E2=80=98dn_unregister_sysctl=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 include/net/dn.h       |    2 ++
 net/decnet/af_decnet.c |    3 ---
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/net/dn.h b/include/net/dn.h
index ccc1558..913b73d 100644
--- a/include/net/dn.h
+++ b/include/net/dn.h
@@ -200,6 +200,8 @@ static inline void dn_sk_ports_copy(struct flowidn =
*fld, struct dn_scp *scp)
 }
=20
 unsigned int dn_mss_from_pmtu(struct net_device *dev, int mtu);
+void dn_register_sysctl(void);
+void dn_unregister_sysctl(void);
=20
 #define DN_MENUVER_ACC 0x01
 #define DN_MENUVER_USR 0x02
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 24d9193..4c04848 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2351,9 +2351,6 @@ static const struct proto_ops dn_proto_ops =3D {
 	.sendpage =3D	sock_no_sendpage,
 };
=20
-void dn_register_sysctl(void);
-void dn_unregister_sysctl(void);
-
 MODULE_DESCRIPTION("The Linux DECnet Network Protocol");
 MODULE_AUTHOR("Linux DECnet Project Team");
 MODULE_LICENSE("GPL");
--=20
1.7.9.5
