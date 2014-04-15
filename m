From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 1/3] net: move LOOPBACK_IFINDEX to include/net/flow.h
Date: Mon, 14 Apr 2014 18:33:26 -0700
Message-ID: <1397525608-11592-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Biederman <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:58817 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbaDOBdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 21:33:37 -0400
Received: by mail-pb0-f47.google.com with SMTP id up15so8790074pbc.6
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 18:33:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Cong Wang <cwang@twopensource.com>

1) It is mostly used by flowi_iif

2) Fix the following compile error if we use it in flow.h
by the patches latter:

In file included from include/linux/netfilter.h:277:0,
                 from include/net/netns/netfilter.h:5,
                 from include/net/net_namespace.h:21,
                 from include/linux/netdevice.h:43,
                 from include/linux/icmpv6.h:12,
                 from include/linux/ipv6.h:61,
                 from include/net/ipv6.h:16,
                 from include/linux/sunrpc/clnt.h:27,
                 from include/linux/nfs_fs.h:30,
                 from init/do_mounts.c:32:
include/net/flow.h: In function =E2=80=98flowi4_init_output=E2=80=99:
include/net/flow.h:84:32: error: =E2=80=98LOOPBACK_IFINDEX=E2=80=99 und=
eclared (first use in this function)

Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 include/net/flow.h          | 8 ++++++++
 include/net/net_namespace.h | 9 +--------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 64fd248..5401998 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -11,6 +11,14 @@
 #include <linux/in6.h>
 #include <linux/atomic.h>
=20
+/*
+ * ifindex generation is per-net namespace, and loopback is
+ * always the 1st device in ns (see net_dev_init), thus any
+ * loopback device should get ifindex 1
+ */
+
+#define LOOPBACK_IFINDEX	1
+
 struct flowi_common {
 	int	flowic_oif;
 	int	flowic_iif;
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 79387f7..5f9eb26 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -9,6 +9,7 @@
 #include <linux/list.h>
 #include <linux/sysctl.h>
=20
+#include <net/flow.h>
 #include <net/netns/core.h>
 #include <net/netns/mib.h>
 #include <net/netns/unix.h>
@@ -131,14 +132,6 @@ struct net {
 	atomic_t		fnhe_genid;
 };
=20
-/*
- * ifindex generation is per-net namespace, and loopback is
- * always the 1st device in ns (see net_dev_init), thus any
- * loopback device should get ifindex 1
- */
-
-#define LOOPBACK_IFINDEX	1
-
 #include <linux/seq_file_net.h>
=20
 /* Init's network namespace */
--=20
1.8.3.1
