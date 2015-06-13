From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: make u64_stats_init() a function
Date: Fri, 12 Jun 2015 19:44:48 -0700
Message-ID: <1434163488.27504.122.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35667 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310AbbFMCou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 22:44:50 -0400
Received: by pacyx8 with SMTP id yx8so31792937pac.2
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 19:44:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

Using a function instead of a macro is cleaner and remove
following W=3D1 warnings (extract)

In file included from net/ipv6/ip6_vti.c:29:0:
net/ipv6/ip6_vti.c: In function =E2=80=98vti6_dev_init_gen=E2=80=99:
include/linux/netdevice.h:2029:18: warning: variable =E2=80=98stat=E2=80=
=99 set but not
used [-Wunused-but-set-variable]
    typeof(type) *stat;   \
                  ^
net/ipv6/ip6_vti.c:862:16: note: in expansion of macro
=E2=80=98netdev_alloc_pcpu_stats=E2=80=99
  dev->tstats =3D netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
                ^
  CC [M]  net/ipv6/sit.o
In file included from net/ipv6/sit.c:30:0:
net/ipv6/sit.c: In function =E2=80=98ipip6_tunnel_init=E2=80=99:
include/linux/netdevice.h:2029:18: warning: variable =E2=80=98stat=E2=80=
=99 set but not
used [-Wunused-but-set-variable]
    typeof(type) *stat;   \
                  ^

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/u64_stats_sync.h |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/u64_stats_sync.h b/include/linux/u64_stats_s=
ync.h
index 4b4439e75f45f8e915f0ffb6b855be5f1113a04f..df89c9bcba7db8dbde3bbf2=
b99f9af6ed562b112 100644
--- a/include/linux/u64_stats_sync.h
+++ b/include/linux/u64_stats_sync.h
@@ -68,11 +68,12 @@ struct u64_stats_sync {
 };
=20
=20
+static inline void u64_stats_init(struct u64_stats_sync *syncp)
+{
 #if BITS_PER_LONG =3D=3D 32 && defined(CONFIG_SMP)
-# define u64_stats_init(syncp)	seqcount_init(syncp.seq)
-#else
-# define u64_stats_init(syncp)	do { } while (0)
+	seqcount_init(&syncp->seq);
 #endif
+}
=20
 static inline void u64_stats_update_begin(struct u64_stats_sync *syncp=
)
 {
