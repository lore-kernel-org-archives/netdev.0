From: "David S. Miller" <davem@redhat.com>
Subject: Re: [DOCUMENTATION PATCH] Missing net sysctls, some fixed, rest
 flagged
Date: Tue, 15 Jun 2004 20:19:12 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040615201912.691ffe35.davem@redhat.com>
References: <20040609175242.GA13875@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266108AbUFPDmV@vger.kernel.org>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20040609175242.GA13875@outpost.ds9a.nl>
List-Id: netdev.vger.kernel.org


Looks fine, I applied it with some minor changes as follows:

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/06/15 20:20:25-07:00 ahu@ds9a.nl 
#   [NET]: Update some sysctl documentation.
#   
#   I ran the following (crappy) script:
#    ...
#   In /proc/sys/ and found a host of undocumented sysctls. This patch documents
#   a number of them, and at least mentions the rest as 'TODO'. Please verify my
#   code-inspired documentation before applying!
#   
#   Signed-off-by: Bert Hubert <ahu@ds9a.nl>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# Documentation/networking/ip-sysctl.txt
#   2004/06/15 20:19:32-07:00 ahu@ds9a.nl +57 -0
#   [NET]: Update some sysctl documentation.
#   
#   I ran the following (crappy) script:
#    ...
#   In /proc/sys/ and found a host of undocumented sysctls. This patch documents
#   a number of them, and at least mentions the rest as 'TODO'. Please verify my
#   code-inspired documentation before applying!
#   
#   Signed-off-by: Bert Hubert <ahu@ds9a.nl>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# Documentation/filesystems/proc.txt
#   2004/06/15 20:19:32-07:00 ahu@ds9a.nl +2 -1
#   [NET]: Update some sysctl documentation.
#   
#   I ran the following (crappy) script:
#    ...
#   In /proc/sys/ and found a host of undocumented sysctls. This patch documents
#   a number of them, and at least mentions the rest as 'TODO'. Please verify my
#   code-inspired documentation before applying!
#   
#   Signed-off-by: Bert Hubert <ahu@ds9a.nl>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
diff -Nru a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
--- a/Documentation/filesystems/proc.txt	2004-06-15 20:20:56 -07:00
+++ b/Documentation/filesystems/proc.txt	2004-06-15 20:20:56 -07:00
@@ -1640,7 +1640,8 @@
 
 Writing to this file results in a flush of the routing cache.
 
-gc_elastic, gc_interval, gc_min_interval, gc_tresh, gc_timeout
+gc_elasticity, gc_interval, gc_min_interval, gc_tresh, gc_timeout,
+gc_thresh, gc_thresh1, gc_thresh2, gc_thresh3
 --------------------------------------------------------------
 
 Values to  control  the  frequency  and  behavior  of  the  garbage collection
diff -Nru a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
--- a/Documentation/networking/ip-sysctl.txt	2004-06-15 20:20:56 -07:00
+++ b/Documentation/networking/ip-sysctl.txt	2004-06-15 20:20:56 -07:00
@@ -17,6 +17,16 @@
 	Disable Path MTU Discovery.
 	default FALSE
 
+min_pmtu - INTEGER
+	default 562 - minimum discovered Path MTU
+
+mtu_expires - INTEGER
+	Time, in seconds, that cached PMTU information is kept.
+
+min_adv_mss - INTEGER
+	The advertised MSS depends on the first hop route MTU, but will
+	never be lower than this setting.
+
 IP Fragmentation:
 
 ipfrag_high_thresh - INTEGER
@@ -345,6 +355,19 @@
 	conections.
 	Default: 7
 
+
+tcp_frto - BOOLEAN
+	Enables F-RTO, an enhanced recovery algorithm for TCP retransmission
+	timeouts.  It is particularly beneficial in wireless environments
+	where packet loss is typically due to random radio interference
+	rather than intermediate router congestion.
+
+somaxconn - INTEGER
+	Limit of TCP listen backlog, known in userspace as SOMAXCONN.
+	Defaults to 128
+
+IP Variables:
+
 ip_local_port_range - 2 INTEGERS
 	Defines the local port range that is used by TCP and UDP to
 	choose the local port. The first number is the first, the 
@@ -586,6 +609,19 @@
 	The max value from conf/{all,interface}/arp_ignore is used
 	when ARP request is received on the {interface}
 
+app_solicit - INTEGER
+	The maximum number of probes to send to the user space ARP daemon
+	via netlink before dropping back to multicast probes (see
+	mcast_solicit).  Defaults to 0.
+
+disable_policy - BOOLEAN
+	Disable IPSEC policy (SPD) for this interface
+
+disable_xfrm - BOOLEAN
+	Disable IPSEC encryption on this interface, whatever the policy
+
+
+
 tag - INTEGER
 	Allows you to write a number, which can be used as required.
 	Default value is 0.
@@ -803,5 +839,26 @@
 	0 : disable this.
 	Default: 1
 
+
+UNDOCUMENTED:
+
+dev_weight FIXME
+discovery_slots FIXME
+discovery_timeout FIXME
+fast_poll_increase FIXME
+ip6_queue_maxlen FIXME
+lap_keepalive_time FIXME
+lo_cong FIXME
+max_baud_rate FIXME
+max_dgram_qlen FIXME
+max_noreply_time FIXME
+max_tx_data_size FIXME
+max_tx_window FIXME
+min_tx_turn_time FIXME
+mod_cong FIXME
+no_cong FIXME
+no_cong_thresh FIXME
+slot_timeout FIXME
+warn_noreply_time FIXME
 
 $Id: ip-sysctl.txt,v 1.20 2001/12/13 09:00:18 davem Exp $
