From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH nf-next] netfilter: nf_dup{4,6}: fix build error when nf_conntrack disabled
Date: Wed,  2 Sep 2015 20:54:02 +0200
Message-ID: <dc51f50f4680ff2d2a91b9852fe6f44f0f14d2cf.1441219641.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fw@strlen.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While testing various Kconfig options on another issue, I found that
the following one triggers as well on allmodconfig and nf_conntrack
disabled:

  net/ipv4/netfilter/nf_dup_ipv4.c: In function =E2=80=98nf_dup_ipv4=E2=
=80=99:
  net/ipv4/netfilter/nf_dup_ipv4.c:72:20: error: =E2=80=98nf_skb_duplic=
ated=E2=80=99 undeclared (first use in this function)
    if (this_cpu_read(nf_skb_duplicated))
  [...]
  net/ipv6/netfilter/nf_dup_ipv6.c: In function =E2=80=98nf_dup_ipv6=E2=
=80=99:
  net/ipv6/netfilter/nf_dup_ipv6.c:66:20: error: =E2=80=98nf_skb_duplic=
ated=E2=80=99 undeclared (first use in this function)
    if (this_cpu_read(nf_skb_duplicated))

=46ix it by including directly the header where it is defined.

=46ixes: bbde9fc1824a ("netfilter: factor out packet duplication for IP=
v4/IPv6")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 [ Don't know whether Dave wants to take it directly, or if it should
   go via nf-next. I have one more build fix coming later tonight. Also
   applies to net-next. ]

 net/ipv4/netfilter/nf_dup_ipv4.c | 1 +
 net/ipv6/netfilter/nf_dup_ipv6.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_d=
up_ipv4.c
index b5bb375..2d79e6e 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -13,6 +13,7 @@
 #include <linux/percpu.h>
 #include <linux/route.h>
 #include <linux/skbuff.h>
+#include <linux/netfilter.h>
 #include <net/checksum.h>
 #include <net/icmp.h>
 #include <net/ip.h>
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_d=
up_ipv6.c
index c5c87e9..c8ab626 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -11,6 +11,7 @@
 #include <linux/module.h>
 #include <linux/percpu.h>
 #include <linux/skbuff.h>
+#include <linux/netfilter.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
 #include <net/netfilter/ipv6/nf_dup_ipv6.h>
--=20
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
