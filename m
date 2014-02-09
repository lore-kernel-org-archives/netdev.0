From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: =?UTF-8?q?=5BPATCH=20v2=2011/13=5D=20net=3A=20Move=20prototype=20declaration=20to=20header=20file=20include/net/net=5Fnamespace=2Eh=20from=20net/ipx/af=5Fipx=2Ec?=
Date: Sun,  9 Feb 2014 22:29:14 +0530
Message-ID: <1fc35d143bf8d29a11d6a81fb94650682db1aa7c.1391955925.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, josh@joshtriplett.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move prototype declaration of function to header file
include/net/net_namespace.h from net/ipx/af_ipx.c because they are used
by more than one file.

This eliminates the following warning in net/ipx/sysctl_net_ipx.c:
net/ipx/sysctl_net_ipx.c:33:6: warning: no previous prototype for =E2=80=
=98ipx_register_sysctl=E2=80=99 [-Wmissing-prototypes]
net/ipx/sysctl_net_ipx.c:38:6: warning: no previous prototype for =E2=80=
=98ipx_unregister_sysctl=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
---

Changes since v1:
Move else block in the header file.

 include/net/net_namespace.h |    8 ++++++++
 net/ipx/af_ipx.c            |    9 +--------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index da68c9a..991dcd9 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -162,6 +162,14 @@ extern struct list_head net_namespace_list;
 struct net *get_net_ns_by_pid(pid_t pid);
 struct net *get_net_ns_by_fd(int pid);
=20
+#ifdef CONFIG_SYSCTL
+void ipx_register_sysctl(void);
+void ipx_unregister_sysctl(void);
+#else
+#define ipx_register_sysctl()
+#define ipx_unregister_sysctl()
+#endif
+
 #ifdef CONFIG_NET_NS
 void __put_net(struct net *net);
=20
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 224d058..00b2a6d 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -54,17 +54,10 @@
 #include <net/sock.h>
 #include <net/datalink.h>
 #include <net/tcp_states.h>
+#include <net/net_namespace.h>
=20
 #include <asm/uaccess.h>
=20
-#ifdef CONFIG_SYSCTL
-extern void ipx_register_sysctl(void);
-extern void ipx_unregister_sysctl(void);
-#else
-#define ipx_register_sysctl()
-#define ipx_unregister_sysctl()
-#endif
-
 /* Configuration Variables */
 static unsigned char ipxcfg_max_hops =3D 16;
 static char ipxcfg_auto_select_primary;
--=20
1.7.9.5
