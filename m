From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 06/09: nf_conntrack: fix ICMP/ICMPv6 timeout sysctls on big-endian
Date: Mon, 12 Jan 2009 11:06:07 +0100 (MET)
Message-ID: <20090112100607.9280.14980.sendpatchset@x2.localnet>
References: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 8bc192edb227774abd2146b2c9cd21efb03533df
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jan 12 09:44:00 2009 +0100

    netfilter: nf_conntrack: fix ICMP/ICMPv6 timeout sysctls on big-endian
    
    An old bug crept back into the ICMP/ICMPv6 conntrack protocols: the timeout
    values are defined as unsigned longs, the sysctl's maxsize is set to
    sizeof(unsigned int). Use unsigned int for the timeout values as in the
    other conntrack protocols.
    
    Reported-by: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 1fd3ef7..2a8bee2 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -20,7 +20,7 @@
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_log.h>
 
-static unsigned long nf_ct_icmp_timeout __read_mostly = 30*HZ;
+static unsigned int nf_ct_icmp_timeout __read_mostly = 30*HZ;
 
 static bool icmp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 			      struct nf_conntrack_tuple *tuple)
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index bd52151..c455cf4 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -26,7 +26,7 @@
 #include <net/netfilter/ipv6/nf_conntrack_icmpv6.h>
 #include <net/netfilter/nf_log.h>
 
-static unsigned long nf_ct_icmpv6_timeout __read_mostly = 30*HZ;
+static unsigned int nf_ct_icmpv6_timeout __read_mostly = 30*HZ;
 
 static bool icmpv6_pkt_to_tuple(const struct sk_buff *skb,
 				unsigned int dataoff,
