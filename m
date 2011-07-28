From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net-next 1/2] stp:add netdevice.h into stp.h
Date: Thu, 28 Jul 2011 16:37:39 +0800
Message-ID: <cb7357573edf19eed618fcafdb4ba7014c9e49e2.1311841820.git.panweiping3@gmail.com>
References: <cover.1311841820.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:51926 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797Ab1G1IgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 04:36:25 -0400
Received: by mail-qw0-f46.google.com with SMTP id 3so1208684qwk.19
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 01:36:24 -0700 (PDT)
In-Reply-To: <cover.1311841820.git.panweiping3@gmail.com>
In-Reply-To: <cover.1311841820.git.panweiping3@gmail.com>
References: <cover.1311841820.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't meet a compile error becasue <linux/netdevice.h>
is added by ohter header files, luckily.

I find this problem when I want to remove the duplicate <linux/if_vlan.=
h>.
As net/8021q/vlan.h already includes it, so other files that includes v=
lan.h
need not to include it.

But when I remove <linux/if_vlan.h> from net/8021q/vlan_gvrp.c,
I met a compile error.
[pwp@localhost net-next]$ make O=3D../net-next_build/ M=3Dnet/8021q
  CC      net/8021q/vlan_core.o
  LD      net/8021q/built-in.o
  CC [M]  net/8021q/vlan.o
  CC [M]  net/8021q/vlan_dev.o
  CC [M]  net/8021q/vlan_netlink.o
  CC [M]  net/8021q/vlan_gvrp.o
In file included from /home/pwp/mysvn/linux/net-next/include/net/garp.h=
:4:0,
                 from /home/pwp/mysvn/linux/net-next/net/8021q/vlan_gvr=
p.c:12:
/home/pwp/mysvn/linux/net-next/include/net/stp.h:5:30: error: =E2=80=98=
ETH_ALEN=E2=80=99 undeclared here (not in a function)
/home/pwp/mysvn/linux/net-next/include/net/stp.h:7:18: warning: =E2=80=98=
struct net_device=E2=80=99 declared inside parameter list
/home/pwp/mysvn/linux/net-next/include/net/stp.h:7:18: warning: its sco=
pe is only this definition or declaration, which is probably not what y=
ou want
/home/pwp/mysvn/linux/net-next/include/net/stp.h:7:18: warning: =E2=80=98=
struct sk_buff=E2=80=99 declared inside parameter list
In file included from /home/pwp/mysvn/linux/net-next/net/8021q/vlan_gvr=
p.c:12:0:
/home/pwp/mysvn/linux/net-next/include/net/garp.h:36:50: warning: =E2=80=
=98struct sk_buff=E2=80=99 declared inside parameter list
/home/pwp/mysvn/linux/net-next/include/net/garp.h: In function =E2=80=98=
garp_cb=E2=80=99:
/home/pwp/mysvn/linux/net-next/include/net/garp.h:38:2: error: implicit=
 declaration of function =E2=80=98BUILD_BUG_ON=E2=80=99
/home/pwp/mysvn/linux/net-next/include/net/garp.h:39:8: error: implicit=
 declaration of function =E2=80=98FIELD_SIZEOF=E2=80=99
/home/pwp/mysvn/linux/net-next/include/net/garp.h:39:21: error: expecte=
d expression before =E2=80=98struct=E2=80=99
/home/pwp/mysvn/linux/net-next/include/net/garp.h:40:34: error: derefer=
encing pointer to incomplete type
/home/pwp/mysvn/linux/net-next/include/net/garp.h: At top level:
/home/pwp/mysvn/linux/net-next/include/net/garp.h:79:19: error: field =E2=
=80=98node=E2=80=99 has incomplete type
/home/pwp/mysvn/linux/net-next/include/net/garp.h:101:20: error: field =
=E2=80=98join_timer=E2=80=99 has incomplete type
/home/pwp/mysvn/linux/net-next/include/net/garp.h:103:2: error: expecte=
d specifier-qualifier-list before =E2=80=98spinlock_t=E2=80=99
/home/pwp/mysvn/linux/net-next/include/net/garp.h:112:20: error: field =
=E2=80=98rcu=E2=80=99 has incomplete type
make[2]: *** [net/8021q/vlan_gvrp.o] Error 1
make[1]: *** [_module_net/8021q] Error 2
make: *** [sub-make] Error 2

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 include/net/stp.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/net/stp.h b/include/net/stp.h
index ad447f1..13318f3 100644
--- a/include/net/stp.h
+++ b/include/net/stp.h
@@ -1,6 +1,8 @@
 #ifndef _NET_STP_H
 #define _NET_STP_H
=20
+#include <linux/netdevice.h>
+
 struct stp_proto {
 	unsigned char	group_address[ETH_ALEN];
 	void		(*rcv)(const struct stp_proto *, struct sk_buff *,
--=20
1.7.4.4

