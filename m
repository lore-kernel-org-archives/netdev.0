From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netfilter: Allow xt_nat.c and x_tables.c to compiled in
Date: Thu, 13 Sep 2012 19:32:30 -0700
Message-ID: <87627hfi69.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


xt_init in x_tables.c must be called before xt_nat_init in xt_nat.c
Reorder the makefile so that x_tables.o comes before xt_nat.o in
netfilter.o.

This allows me to built a kernel with both of these modules compiled in.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/Makefile |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 98244d4..1f652b6 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -43,6 +43,9 @@ obj-$(CONFIG_NF_CONNTRACK_SANE) += nf_conntrack_sane.o
 obj-$(CONFIG_NF_CONNTRACK_SIP) += nf_conntrack_sip.o
 obj-$(CONFIG_NF_CONNTRACK_TFTP) += nf_conntrack_tftp.o
 
+# generic X tables 
+obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
+
 nf_nat-y	:= nf_nat_core.o nf_nat_proto_unknown.o nf_nat_proto_common.o \
 		   nf_nat_proto_udp.o nf_nat_proto_tcp.o nf_nat_helper.o
 
@@ -64,9 +67,6 @@ obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
 # transparent proxy support
 obj-$(CONFIG_NETFILTER_TPROXY) += nf_tproxy_core.o
 
-# generic X tables 
-obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
-
 # combos
 obj-$(CONFIG_NETFILTER_XT_MARK) += xt_mark.o
 obj-$(CONFIG_NETFILTER_XT_CONNMARK) += xt_connmark.o
-- 
1.7.5.4

