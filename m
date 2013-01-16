From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] doc: add nf_conntrack sysctl api documentation
Date: Wed, 16 Jan 2013 13:44:17 +0100
Message-ID: <1358340257-1902-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, rob@landley.net, linux-doc@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I grepped through the code and picked bits about nf_conntrack sysctl api
and put that into one documentation file.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 Documentation/networking/nf_conntrack-sysctl.txt | 160 +++++++++++++++++++++++
 1 file changed, 160 insertions(+)
 create mode 100644 Documentation/networking/nf_conntrack-sysctl.txt

diff --git a/Documentation/networking/nf_conntrack-sysctl.txt b/Documentation/networking/nf_conntrack-sysctl.txt
new file mode 100644
index 0000000..ab5f977
--- /dev/null
+++ b/Documentation/networking/nf_conntrack-sysctl.txt
@@ -0,0 +1,160 @@
+/proc/sys/net/netfilter/nf_conntrack_* Variables:
+
+nf_conntrack_acct - BOOLEAN
+	0 - disabled (default)
+	not 0 - enabled
+
+	Enable connection tracking flow accounting.
+
+nf_conntrack_buckets - INTEGER (read-only)
+	Size of hash table. Value is computed in nf_conntrack_init_init_net()
+	and it basically depends on total memory size.
+
+nf_conntrack_checksum - BOOLEAN
+	0 - disabled
+	not 0 - enabled (default)
+
+	Enable connection tracking checksuming.
+
+nf_conntrack_count - INTEGER (read-only)
+	Number of currently allocated conntracks.
+
+nf_conntrack_events - BOOLEAN
+	0 - disabled
+	not 0 - enabled (default)
+
+	If this option is enabled, the connection tracking code will provide
+	a notifier chain that can be used by other kernel code to get notified
+	about changes in the connection tracking state.
+
+nf_conntrack_events_retry_timeout - INTEGER (seconds)
+	default 15
+
+	Timeout after which destroy event will be delivered.
+
+nf_conntrack_expect_max - INTEGER
+	Maximum size of expectation table. Default value is computed in
+	nf_conntrack_expect_init() and depends on nf_conntrack_buckets value.
+
+nf_conntrack_frag6_high_thresh - INTEGER
+	default 262144
+
+	Maximum memory used to reassemble IPv6 fragments. When
+	nf_conntrack_frag6_high_thresh bytes of memory is allocated for this
+	purpose, the fragment handler will toss packets until
+	nf_conntrack_frag6_low_thresh is reached.
+
+nf_conntrack_frag6_low_thresh - INTEGER
+	default 196608
+
+	See nf_conntrack_frag6_low_thresh
+
+nf_conntrack_frag6_timeout - INTEGER (seconds)
+	default 60
+
+	Time to keep an IPv6 fragment in memory.
+
+nf_conntrack_generic_timeout - INTEGER (seconds)
+	default 600
+
+	Default for generic timeout.
+
+nf_conntrack_helper - BOOLEAN
+	0 - disabled
+	not 0 - enabled (default)
+
+	Enable automatic conntrack helper assignment.
+
+nf_conntrack_icmp_timeout - INTEGER (seconds)
+	default 30
+
+	Default for ICMP timeout.
+
+nf_conntrack_icmpv6_timeout - INTEGER (seconds)
+	default 30
+
+	Default for ICMP6 timeout.
+
+nf_conntrack_log_invalid - INTEGER
+	0 - disabled (default)
+	IPPROTO_RAW (log packets of any proto)
+	IPPROTO_TCP
+	IPPROTO_ICMP
+	IPPROTO_ICMPV6
+	IPPROTO_DCCP
+	IPPROTO_UDP
+	IPPROTO_UDPLITE
+
+	For values, see <linux/in.h>
+
+	Log invalid packets of a type specified by value.
+
+nf_conntrack_max - INTEGER
+	Size of connection tracking table. Default value is computed in
+	nf_conntrack_init_init_net() and depends on nf_conntrack_buckets value.
+
+nf_conntrack_tcp_be_liberal - BOOLEAN
+	0 - disabled (default)
+	not 0 - enabled
+
+	Be conservative in what you do, be liberal in what you accept from others.
+	If it's non-zero, we mark only out of window RST segments as INVALID.
+
+nf_conntrack_tcp_loose - BOOLEAN
+	0 - disabled
+	not 0 - enabled (default)
+
+	If it is set to zero, we disable picking up already established
+	connections.
+
+nf_conntrack_tcp_max_retrans - INTEGER
+	default 3
+
+	Max number of the retransmitted packets without receiving an
+	(acceptable) ACK from the destination. If this number is reached,
+	a shorter timer will be started.
+
+nf_conntrack_tcp_timeout_close - INTEGER (seconds)
+	default 10
+
+nf_conntrack_tcp_timeout_close_wait - INTEGER (seconds)
+	default 60
+
+nf_conntrack_tcp_timeout_established - INTEGER (seconds)
+	default 432000 (5 days)
+
+nf_conntrack_tcp_timeout_fin_wait - INTEGER (seconds)
+	default 120
+
+nf_conntrack_tcp_timeout_last_ack - INTEGER (seconds)
+	default 30
+
+nf_conntrack_tcp_timeout_max_retrans - INTEGER (seconds)
+	default 300
+
+nf_conntrack_tcp_timeout_syn_recv - INTEGER (seconds)
+	default 60
+
+nf_conntrack_tcp_timeout_syn_sent - INTEGER (seconds)
+	default 120
+
+nf_conntrack_tcp_timeout_time_wait - INTEGER (seconds)
+	default 120
+
+nf_conntrack_tcp_timeout_unacknowledged - INTEGER (seconds)
+	default 300
+
+nf_conntrack_timestamp - BOOLEAN
+	0 - disabled (default)
+	not 0 - enabled
+
+	Enable connection tracking flow timestamping.
+
+nf_conntrack_udp_timeout - INTEGER (seconds)
+	default 30
+
+nf_conntrack_udp_timeout_stream2 - INTEGER (seconds)
+	default 180
+
+	This extended timeout will be used in case there is an UDP stream
+	detected.
-- 
1.8.1

