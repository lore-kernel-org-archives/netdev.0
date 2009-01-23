From: Greg KH <gregkh@suse.de>
Subject: [patch 30/46] netfilter: nf_conntrack: fix ICMP/ICMPv6 timeout
	sysctls on big-endian
Date: Thu, 22 Jan 2009 17:12:35 -0800
Message-ID: <20090123011235.GE19756@kroah.com>
References: <20090123010651.683741823@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>, Willy Tarreau <w@1wt.eu>,
	Rodrigo Rubira Branco <rbranco@la.checkpoint.com>,
	Jake Edge <jake@lwn.net>, Eugene Teo <eteo@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	davem@davemloft.net
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename="netfilter-nf_conntrack-fix-icmp-icmpv6-timeout-sysctls-on-big-endian.patch"
In-Reply-To: <20090123011110.GA19756@kroah.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2.6.28-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Patrick McHardy <kaber@trash.net>

Upstream commit 71320af:

An old bug crept back into the ICMP/ICMPv6 conntrack protocols: the timeout
values are defined as unsigned longs, the sysctl's maxsize is set to
sizeof(unsigned int). Use unsigned int for the timeout values as in the
other conntrack protocols.

Reported-by: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -20,7 +20,7 @@
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_log.h>
 
-static unsigned long nf_ct_icmp_timeout __read_mostly = 30*HZ;
+static unsigned int nf_ct_icmp_timeout __read_mostly = 30*HZ;
 
 static bool icmp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 			      struct nf_conntrack_tuple *tuple)
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -26,7 +26,7 @@
 #include <net/netfilter/ipv6/nf_conntrack_icmpv6.h>
 #include <net/netfilter/nf_log.h>
 
-static unsigned long nf_ct_icmpv6_timeout __read_mostly = 30*HZ;
+static unsigned int nf_ct_icmpv6_timeout __read_mostly = 30*HZ;
 
 static bool icmpv6_pkt_to_tuple(const struct sk_buff *skb,
 				unsigned int dataoff,

