From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH] net: fix compile error of leaking kmemleak.h header
Date: Thu, 19 Apr 2012 12:05:46 +0800
Message-ID: <4F8F8F1A.6020000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: majianpeng@gmail.com, Eric Dumazet <eric.dumazet@gmail.com>,
	NetDev <netdev@vger.kernel.org>,
	davidshan <davidshan@tencent.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:41276 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab2DSEFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 00:05:00 -0400
Received: by dake40 with SMTP id e40so10778649dak.11
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 21:05:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Shan Wei <davidshan@tencent.com>

net/core/sysctl_net_core.c: In function =91sysctl_core_init=92:
net/core/sysctl_net_core.c:259: error: implicit declaration of function=
 =91kmemleak_not_leak=92

with same error in net/ipv4/route.c

Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 net/core/sysctl_net_core.c |    1 +
 net/ipv4/route.c           |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index cee5991..247c69b 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -14,6 +14,7 @@
 #include <linux/vmalloc.h>
 #include <linux/init.h>
 #include <linux/slab.h>
+#include <linux/kmemleak.h>
=20
 #include <net/ip.h>
 #include <net/sock.h>
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index bcd4744..a1c115d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -109,6 +109,7 @@
 #include <net/rtnetlink.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
+#include <linux/kmemleak.h>
 #endif
 #include <net/secure_seq.h>
=20
--=20
1.7.1
