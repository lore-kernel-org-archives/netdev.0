From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 11/13] net: Move prototype declaration to header file
 include/net/net_namespace.h from net/ipx/af_ipx.c
Date: Sun, 9 Feb 2014 01:37:20 +0530
Message-ID: <0d855fd121af07a77d258aec045b71dfa68cb0af.1391888654.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
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
 include/net/net_namespace.h |    3 +++
 net/ipx/af_ipx.c            |    6 ++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index da68c9a..a43435c 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -162,6 +162,9 @@ extern struct list_head net_namespace_list;
 struct net *get_net_ns_by_pid(pid_t pid);
 struct net *get_net_ns_by_fd(int pid);
=20
+void ipx_register_sysctl(void);
+void ipx_unregister_sysctl(void);
+
 #ifdef CONFIG_NET_NS
 void __put_net(struct net *net);
=20
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 224d058..aa2abb8 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -54,13 +54,11 @@
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
+#ifndef CONFIG_SYSCTL
 #define ipx_register_sysctl()
 #define ipx_unregister_sysctl()
 #endif
--=20
1.7.9.5
