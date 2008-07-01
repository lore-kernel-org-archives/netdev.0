From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] ip: sysctl documentation cleanup
Date: Tue, 1 Jul 2008 15:43:06 -0700
Message-ID: <20080701154306.21b04c75@extreme>
References: <20080701153820.235faa72@extreme>
	<20080701153926.7b3fe1dd@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48750 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763640AbYGAWnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 18:43:18 -0400
In-Reply-To: <20080701153926.7b3fe1dd@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some documentation stuff:
  * replace non-standard spelling
  * remove confusing sentence in F-RTO description. The existing
    text is sufficient to explain what the option does
  * reorganize and update list of undocumented values

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/Documentation/networking/ip-sysctl.txt	2008-07-01 14:52:00.000000000 -0700
+++ b/Documentation/networking/ip-sysctl.txt	2008-07-01 15:12:26.000000000 -0700
@@ -148,9 +148,9 @@ tcp_available_congestion_control - STRIN
 	but not loaded.
 
 tcp_base_mss - INTEGER
-	The initial value of search_low to be used by Packetization Layer
-	Path MTU Discovery (MTU probing).  If MTU probing is enabled,
-	this is the inital MSS used by the connection.
+	The initial value of search_low to be used by the packetization layer
+	Path MTU discovery (MTU probing).  If MTU probing is enabled,
+	this is the initial MSS used by the connection.
 
 tcp_congestion_control - STRING
 	Set the congestion control algorithm to be used for new
@@ -159,7 +159,7 @@ tcp_congestion_control - STRING
 	Default is set as part of kernel configuration.
 
 tcp_dsack - BOOLEAN
-	Allows TCP to send "duplicate" SACKs.
+	Allows TCP to send "duplicate" SACK's.
 
 tcp_ecn - BOOLEAN
 	Enable Explicit Congestion Notification in TCP.
@@ -185,10 +185,9 @@ tcp_frto - INTEGER
 	timeouts.  It is particularly beneficial in wireless environments
 	where packet loss is typically due to random radio interference
 	rather than intermediate router congestion.  F-RTO is sender-side
-	only modification.  Therefore it does not require any support from
-	the peer, but in a typical case, however, where wireless link is
-	the local access link and most of the data flows downlink, the
-	faraway servers should have F-RTO enabled to take advantage of it.
+	only modification therefore it does not require any support from
+	the peer.
+
 	If set to 1, basic version is enabled.  2 enables SACK enhanced
 	F-RTO if flow uses SACK.  The basic version can be used also when
 	SACK is in use though scenario(s) with it exists where F-RTO
@@ -261,7 +260,7 @@ tcp_max_tw_buckets - INTEGER
 	but rather increase it (probably, after increasing installed memory),
 	if network conditions require more than default value.
 
-tcp_mem - vector of 3 INTEGERs: min, pressure, max
+tcp_mem - vector of 3 INTEGER's: min, pressure, max
 	min: below this number of pages TCP is not bothered about its
 	memory appetite.
 
@@ -270,13 +269,13 @@ tcp_mem - vector of 3 INTEGERs: min, pre
 	pressure mode, which is exited when memory consumption falls
 	under "min".
 
-	max: number of pages allowed for queueing by all TCP sockets.
+	max: number of pages allowed for queuing by all TCP sockets.
 
 	Defaults are calculated at boot time from amount of available
 	memory.
 
 tcp_moderate_rcvbuf - BOOLEAN
-	If set, TCP performs receive buffer autotuning, attempting to
+	If set, TCP performs receive buffer auto tuning, attempting to
 	automatically size the buffer (no greater than tcp_rmem[2]) to
 	match the size required by the path for full throughput.  Enabled by
 	default.
@@ -330,7 +329,7 @@ tcp_rfc1337 - BOOLEAN
 	assassination.
 	Default: 0
 
-tcp_rmem - vector of 3 INTEGERs: min, default, max
+tcp_rmem - vector of 3 INTEGER's: min, default, max
 	min: Minimal size of receive buffer used by TCP sockets.
 	It is guaranteed to each TCP socket, even under moderate memory
 	pressure.
@@ -358,13 +357,13 @@ tcp_slow_start_after_idle - BOOLEAN
 	Default: 1
 
 tcp_stdurg - BOOLEAN
-	Use the Host requirements interpretation of the TCP urg pointer field.
+	Use the Host requirements interpretation of the TCP urgent pointer field.
 	Most hosts use the older BSD interpretation, so if you turn this on
 	Linux might not communicate correctly with them.
 	Default: FALSE
 
 tcp_synack_retries - INTEGER
-	Number of times SYNACKs for a passive TCP connection attempt will
+	Number of times SYNACK's for a passive TCP connection attempt will
 	be retransmitted. Should not be higher than 255. Default value
 	is 5, which corresponds to ~180seconds.
 
@@ -376,7 +375,7 @@ tcp_syncookies - BOOLEAN
 
 	Note, that syncookies is fallback facility.
 	It MUST NOT be used to help highly loaded servers to stand
-	against legal connection rate. If you see synflood warnings
+	against legal connection rate. If you see SYN flood warnings
 	in your logs, but investigation	shows that they occur
 	because of overload with legal connections, you should tune
 	another parameters until this warning disappear.
@@ -386,11 +385,11 @@ tcp_syncookies - BOOLEAN
 	to use TCP extensions, can result in serious degradation
 	of some services (f.e. SMTP relaying), visible not by you,
 	but your clients and relays, contacting you. While you see
-	synflood warnings in logs not being really flooded, your server
+	SYN flood warnings in logs not being really flooded, your server
 	is seriously misconfigured.
 
 tcp_syn_retries - INTEGER
-	Number of times initial SYNs for an active TCP connection attempt
+	Number of times initial SYN's for an active TCP connection attempt
 	will be retransmitted. Should not be higher than 255. Default value
 	is 5, which corresponds to ~180seconds.
 
@@ -418,7 +417,7 @@ tcp_tw_reuse - BOOLEAN
 tcp_window_scaling - BOOLEAN
 	Enable window scaling as defined in RFC1323.
 
-tcp_wmem - vector of 3 INTEGERs: min, default, max
+tcp_wmem - vector of 3 INTEGER's: min, default, max
 	min: Amount of memory reserved for send buffers for TCP socket.
 	Each TCP socket has rights to use it due to fact of its birth.
 	Default: 4K
@@ -448,8 +447,8 @@ tcp_dma_copybreak - INTEGER
 
 UDP variables:
 
-udp_mem - vector of 3 INTEGERs: min, pressure, max
-	Number of pages allowed for queueing by all UDP sockets.
+udp_mem - vector of 3 INTEGER's: min, pressure, max
+	Number of pages allowed for queuing by all UDP sockets.
 
 	min: Below this number of pages UDP is not bothered about its
 	memory appetite. When amount of memory allocated by UDP exceeds
@@ -457,7 +456,7 @@ udp_mem - vector of 3 INTEGERs: min, pre
 
 	pressure: This value was introduced to follow format of tcp_mem.
 
-	max: Number of pages allowed for queueing by all UDP sockets.
+	max: Number of pages allowed for queuing by all UDP sockets.
 
 	Default is calculated at boot time from amount of available memory.
 
@@ -707,7 +706,7 @@ rp_filter - BOOLEAN
 
 arp_filter - BOOLEAN
 	1 - Allows you to have multiple network interfaces on the same
-	subnet, and have the ARPs for each interface be answered
+	subnet, and have the ARP's for each interface be answered
 	based on whether or not the kernel would route a packet from
 	the ARP'd IP out that interface (therefore you must use source
 	based routing for this to work). In other words it allows control
@@ -1061,25 +1060,24 @@ bridge-nf-filter-pppoe-tagged - BOOLEAN
 	0 : disable this.
 	Default: 1
 
-
 UNDOCUMENTED:
 
-dev_weight FIXME
-discovery_slots FIXME
-discovery_timeout FIXME
-fast_poll_increase FIXME
-ip6_queue_maxlen FIXME
-lap_keepalive_time FIXME
-lo_cong FIXME
-max_baud_rate FIXME
-max_dgram_qlen FIXME
-max_noreply_time FIXME
-max_tx_data_size FIXME
-max_tx_window FIXME
-min_tx_turn_time FIXME
-mod_cong FIXME
-no_cong FIXME
-no_cong_thresh FIXME
-slot_timeout FIXME
-warn_noreply_time FIXME
+/proc/sys/net/core/*
+	dev_weight FIXME
+
+/proc/sys/net/unix/*
+	max_dgram_qlen FIXME
+
+/proc/sys/net/irda/*
+	fast_poll_increase FIXME
+	warn_noreply_time FIXME
+	discovery_slots FIXME
+	slot_timeout FIXME
+	max_baud_rate FIXME
+	discovery_timeout FIXME
+	lap_keepalive_time FIXME
+	max_noreply_time FIXME
+	max_tx_data_size FIXME
+	max_tx_window FIXME
+	min_tx_turn_time FIXME
 
