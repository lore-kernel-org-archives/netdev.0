From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/5] ip-sysctl.txt alphabetize
Date: Tue, 31 Oct 2006 15:01:45 -0800
Message-ID: <20061031230214.234717760@osdl.org>
References: <20061031230140.191929094@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:26810 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946110AbWJaXER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 18:04:17 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=ip-sysctl-organize.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rearrange TCP entries in alpha order.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- tcp.orig/Documentation/networking/ip-sysctl.txt	2006-10-31 14:59:20.000000000 -0800
+++ tcp/Documentation/networking/ip-sysctl.txt	2006-10-31 15:01:06.000000000 -0800
@@ -101,6 +101,11 @@
 
 TCP variables: 
 
+somaxconn - INTEGER
+	Limit of socket listen() backlog, known in userspace as SOMAXCONN.
+	Defaults to 128.  See also tcp_max_syn_backlog for additional tuning
+	for TCP sockets.
+
 tcp_abc - INTEGER
 	Controls Appropriate Byte Count (ABC) defined in RFC3465.
 	ABC is a way of increasing congestion window (cwnd) more slowly
@@ -112,48 +117,51 @@
 		  of two segments to compensate for delayed acknowledgments.
 	Default: 0 (off)
 
-tcp_syn_retries - INTEGER
-	Number of times initial SYNs for an active TCP connection attempt
-	will be retransmitted. Should not be higher than 255. Default value
-	is 5, which corresponds to ~180seconds.
+tcp_abort_on_overflow - BOOLEAN
+	If listening service is too slow to accept new connections,
+	reset them. Default state is FALSE. It means that if overflow
+	occurred due to a burst, connection will recover. Enable this
+	option _only_ if you are really sure that listening daemon
+	cannot be tuned to accept connections faster. Enabling this
+	option can harm clients of your server.
 
-tcp_synack_retries - INTEGER
-	Number of times SYNACKs for a passive TCP connection attempt will
-	be retransmitted. Should not be higher than 255. Default value
-	is 5, which corresponds to ~180seconds.
+tcp_adv_win_scale - INTEGER
+	Count buffering overhead as bytes/2^tcp_adv_win_scale
+	(if tcp_adv_win_scale > 0) or bytes-bytes/2^(-tcp_adv_win_scale),
+	if it is <= 0.
+	Default: 2
 
-tcp_keepalive_time - INTEGER
-	How often TCP sends out keepalive messages when keepalive is enabled.
-	Default: 2hours.
+tcp_allowed_congestion_control - STRING
+	Show/set the congestion control choices available to non-privileged
+	processes. The list is a subset of those listed in
+	tcp_available_congestion_control.
+	Default is "reno" and the default setting (tcp_congestion_control).
 
-tcp_keepalive_probes - INTEGER
-	How many keepalive probes TCP sends out, until it decides that the
-	connection is broken. Default value: 9.
+tcp_app_win - INTEGER
+	Reserve max(window/2^tcp_app_win, mss) of window for application
+	buffer. Value 0 is special, it means that nothing is reserved.
+	Default: 31
 
-tcp_keepalive_intvl - INTEGER
-	How frequently the probes are send out. Multiplied by
-	tcp_keepalive_probes it is time to kill not responding connection,
-	after probes started. Default value: 75sec i.e. connection
-	will be aborted after ~11 minutes of retries.
+tcp_available_congestion_control - STRING
+	Shows the available congestion control choices that are registered.
+	More congestion control algorithms may be available as modules,
+	but not loaded.
 
-tcp_retries1 - INTEGER
-	How many times to retry before deciding that something is wrong
-	and it is necessary to report this suspicion to network layer.
-	Minimal RFC value is 3, it is default, which corresponds
-	to ~3sec-8min depending on RTO.
+tcp_congestion_control - STRING
+	Set the congestion control algorithm to be used for new
+	connections. The algorithm "reno" is always available, but
+	additional choices may be available based on kernel configuration.
+	Default is set as part of kernel configuration.
 
-tcp_retries2 - INTEGER
-	How may times to retry before killing alive TCP connection.
-	RFC1122 says that the limit should be longer than 100 sec.
-	It is too small number.	Default value 15 corresponds to ~13-30min
-	depending on RTO.
+tcp_dsack - BOOLEAN
+	Allows TCP to send "duplicate" SACKs.
 
-tcp_orphan_retries - INTEGER
-	How may times to retry before killing TCP connection, closed
-	by our side. Default value 7 corresponds to ~50sec-16min
-	depending on RTO. If you machine is loaded WEB server,
-	you should think about lowering this value, such sockets
-	may consume significant resources. Cf. tcp_max_orphans.
+tcp_ecn - BOOLEAN
+	Enable Explicit Congestion Notification in TCP.
+
+tcp_fack - BOOLEAN
+	Enable FACK congestion avoidance and fast retransmission.
+	The value is not used, if tcp_sack is not enabled.
 
 tcp_fin_timeout - INTEGER
 	Time to hold socket in state FIN-WAIT-2, if it was closed
@@ -166,24 +174,33 @@
 	because they eat maximum 1.5K of memory, but they tend
 	to live longer.	Cf. tcp_max_orphans.
 
-tcp_max_tw_buckets - INTEGER
-	Maximal number of timewait sockets held by system simultaneously.
-	If this number is exceeded time-wait socket is immediately destroyed
-	and warning is printed. This limit exists only to prevent
-	simple DoS attacks, you _must_ not lower the limit artificially,
-	but rather increase it (probably, after increasing installed memory),
-	if network conditions require more than default value.
+tcp_frto - BOOLEAN
+	Enables F-RTO, an enhanced recovery algorithm for TCP retransmission
+	timeouts.  It is particularly beneficial in wireless environments
+	where packet loss is typically due to random radio interference
+	rather than intermediate router congestion.
 
-tcp_tw_recycle - BOOLEAN
-	Enable fast recycling TIME-WAIT sockets. Default value is 0.
-	It should not be changed without advice/request of technical
-	experts.
+tcp_keepalive_time - INTEGER
+	How often TCP sends out keepalive messages when keepalive is enabled.
+	Default: 2hours.
 
-tcp_tw_reuse - BOOLEAN
-	Allow to reuse TIME-WAIT sockets for new connections when it is
-	safe from protocol viewpoint. Default value is 0.
-	It should not be changed without advice/request of technical
-	experts.
+tcp_keepalive_probes - INTEGER
+	How many keepalive probes TCP sends out, until it decides that the
+	connection is broken. Default value: 9.
+
+tcp_keepalive_intvl - INTEGER
+	How frequently the probes are send out. Multiplied by
+	tcp_keepalive_probes it is time to kill not responding connection,
+	after probes started. Default value: 75sec i.e. connection
+	will be aborted after ~11 minutes of retries.
+
+tcp_low_latency - BOOLEAN
+	If set, the TCP stack makes decisions that prefer lower
+	latency as opposed to higher throughput.  By default, this
+	option is not set meaning that higher throughput is preferred.
+	An example of an application where this default should be
+	changed would be a Beowulf compute cluster.
+	Default: 0
 
 tcp_max_orphans - INTEGER
 	Maximal number of TCP sockets not attached to any user file handle,
@@ -197,41 +214,6 @@
 	more aggressively. Let me to remind again: each orphan eats
 	up to ~64K of unswappable memory.
 
-tcp_abort_on_overflow - BOOLEAN
-	If listening service is too slow to accept new connections,
-	reset them. Default state is FALSE. It means that if overflow
-	occurred due to a burst, connection will recover. Enable this
-	option _only_ if you are really sure that listening daemon
-	cannot be tuned to accept connections faster. Enabling this
-	option can harm clients of your server.
-
-tcp_syncookies - BOOLEAN
-	Only valid when the kernel was compiled with CONFIG_SYNCOOKIES
-	Send out syncookies when the syn backlog queue of a socket 
-	overflows. This is to prevent against the common 'syn flood attack'
-	Default: FALSE
-
-	Note, that syncookies is fallback facility.
-	It MUST NOT be used to help highly loaded servers to stand
-	against legal connection rate. If you see synflood warnings
-	in your logs, but investigation	shows that they occur
-	because of overload with legal connections, you should tune
-	another parameters until this warning disappear.
-	See: tcp_max_syn_backlog, tcp_synack_retries, tcp_abort_on_overflow.
-
-	syncookies seriously violate TCP protocol, do not allow
-	to use TCP extensions, can result in serious degradation
-	of some services (f.e. SMTP relaying), visible not by you,
-	but your clients and relays, contacting you. While you see
-	synflood warnings in logs not being really flooded, your server
-	is seriously misconfigured.
-
-tcp_stdurg - BOOLEAN
-	Use the Host requirements interpretation of the TCP urg pointer field.
-	Most hosts use the older BSD interpretation, so if you turn this on
-	Linux might not communicate correctly with them.	
-	Default: FALSE 
-	
 tcp_max_syn_backlog - INTEGER
 	Maximal number of remembered connection requests, which are
 	still did not receive an acknowledgment from connecting client.
@@ -239,24 +221,34 @@
 	and 128 for low memory machines. If server suffers of overload,
 	try to increase this number.
 
-tcp_window_scaling - BOOLEAN
-	Enable window scaling as defined in RFC1323.
+tcp_max_tw_buckets - INTEGER
+	Maximal number of timewait sockets held by system simultaneously.
+	If this number is exceeded time-wait socket is immediately destroyed
+	and warning is printed. This limit exists only to prevent
+	simple DoS attacks, you _must_ not lower the limit artificially,
+	but rather increase it (probably, after increasing installed memory),
+	if network conditions require more than default value.
 
-tcp_timestamps - BOOLEAN
-	Enable timestamps as defined in RFC1323.
+tcp_mem - vector of 3 INTEGERs: min, pressure, max
+	min: below this number of pages TCP is not bothered about its
+	memory appetite.
 
-tcp_sack - BOOLEAN
-	Enable select acknowledgments (SACKS).
+	pressure: when amount of memory allocated by TCP exceeds this number
+	of pages, TCP moderates its memory consumption and enters memory
+	pressure mode, which is exited when memory consumption falls
+	under "min".
 
-tcp_fack - BOOLEAN
-	Enable FACK congestion avoidance and fast retransmission.
-	The value is not used, if tcp_sack is not enabled.
+	max: number of pages allowed for queueing by all TCP sockets.
 
-tcp_dsack - BOOLEAN
-	Allows TCP to send "duplicate" SACKs.
+	Defaults are calculated at boot time from amount of available
+	memory.
 
-tcp_ecn - BOOLEAN
-	Enable Explicit Congestion Notification in TCP.
+tcp_orphan_retries - INTEGER
+	How may times to retry before killing TCP connection, closed
+	by our side. Default value 7 corresponds to ~50sec-16min
+	depending on RTO. If you machine is loaded WEB server,
+	you should think about lowering this value, such sockets
+	may consume significant resources. Cf. tcp_max_orphans.
 
 tcp_reordering - INTEGER
 	Maximal reordering of packets in a TCP stream.
@@ -267,20 +259,23 @@
 	On retransmit try to send bigger packets to work around bugs in
 	certain TCP stacks.
 
-tcp_wmem - vector of 3 INTEGERs: min, default, max
-	min: Amount of memory reserved for send buffers for TCP socket.
-	Each TCP socket has rights to use it due to fact of its birth.
-	Default: 4K
+tcp_retries1 - INTEGER
+	How many times to retry before deciding that something is wrong
+	and it is necessary to report this suspicion to network layer.
+	Minimal RFC value is 3, it is default, which corresponds
+	to ~3sec-8min depending on RTO.
 
-	default: Amount of memory allowed for send buffers for TCP socket
-	by default. This value overrides net.core.wmem_default used
-	by other protocols, it is usually lower than net.core.wmem_default.
-	Default: 16K
+tcp_retries2 - INTEGER
+	How may times to retry before killing alive TCP connection.
+	RFC1122 says that the limit should be longer than 100 sec.
+	It is too small number.	Default value 15 corresponds to ~13-30min
+	depending on RTO.
 
-	max: Maximal amount of memory allowed for automatically selected
-	send buffers for TCP socket. This value does not override
-	net.core.wmem_max, "static" selection via SO_SNDBUF does not use this.
-	Default: 128K
+tcp_rfc1337 - BOOLEAN
+	If set, the TCP stack behaves conforming to RFC1337. If unset,
+	we are not conforming to RFC, but prevent TCP TIME_WAIT
+	assassination.
+	Default: 0
 
 tcp_rmem - vector of 3 INTEGERs: min, default, max
 	min: Minimal size of receive buffer used by TCP sockets.
@@ -299,79 +294,91 @@
 	net.core.rmem_max, "static" selection via SO_RCVBUF does not use this.
 	Default: 87380*2 bytes.
 
-tcp_mem - vector of 3 INTEGERs: min, pressure, max
-	min: below this number of pages TCP is not bothered about its
-	memory appetite.
+tcp_sack - BOOLEAN
+	Enable select acknowledgments (SACKS).
 
-	pressure: when amount of memory allocated by TCP exceeds this number
-	of pages, TCP moderates its memory consumption and enters memory
-	pressure mode, which is exited when memory consumption falls
-	under "min".
+tcp_slow_start_after_idle - BOOLEAN
+	If set, provide RFC2861 behavior and time out the congestion
+	window after an idle period.  An idle period is defined at
+	the current RTO.  If unset, the congestion window will not
+	be timed out after an idle period.
+	Default: 1
 
-	max: number of pages allowed for queueing by all TCP sockets.
+tcp_stdurg - BOOLEAN
+	Use the Host requirements interpretation of the TCP urg pointer field.
+	Most hosts use the older BSD interpretation, so if you turn this on
+	Linux might not communicate correctly with them.
+	Default: FALSE
 
-	Defaults are calculated at boot time from amount of available
-	memory.
+tcp_synack_retries - INTEGER
+	Number of times SYNACKs for a passive TCP connection attempt will
+	be retransmitted. Should not be higher than 255. Default value
+	is 5, which corresponds to ~180seconds.
 
-tcp_app_win - INTEGER
-	Reserve max(window/2^tcp_app_win, mss) of window for application
-	buffer. Value 0 is special, it means that nothing is reserved.
-	Default: 31
+tcp_syncookies - BOOLEAN
+	Only valid when the kernel was compiled with CONFIG_SYNCOOKIES
+	Send out syncookies when the syn backlog queue of a socket
+	overflows. This is to prevent against the common 'syn flood attack'
+	Default: FALSE
 
-tcp_adv_win_scale - INTEGER
-	Count buffering overhead as bytes/2^tcp_adv_win_scale
-	(if tcp_adv_win_scale > 0) or bytes-bytes/2^(-tcp_adv_win_scale),
-	if it is <= 0.
-	Default: 2
+	Note, that syncookies is fallback facility.
+	It MUST NOT be used to help highly loaded servers to stand
+	against legal connection rate. If you see synflood warnings
+	in your logs, but investigation	shows that they occur
+	because of overload with legal connections, you should tune
+	another parameters until this warning disappear.
+	See: tcp_max_syn_backlog, tcp_synack_retries, tcp_abort_on_overflow.
 
-tcp_rfc1337 - BOOLEAN
-	If set, the TCP stack behaves conforming to RFC1337. If unset,
-	we are not conforming to RFC, but prevent TCP TIME_WAIT
-	assassination.   
-	Default: 0
+	syncookies seriously violate TCP protocol, do not allow
+	to use TCP extensions, can result in serious degradation
+	of some services (f.e. SMTP relaying), visible not by you,
+	but your clients and relays, contacting you. While you see
+	synflood warnings in logs not being really flooded, your server
+	is seriously misconfigured.
 
-tcp_low_latency - BOOLEAN
-	If set, the TCP stack makes decisions that prefer lower
-	latency as opposed to higher throughput.  By default, this
-	option is not set meaning that higher throughput is preferred.
-	An example of an application where this default should be
-	changed would be a Beowulf compute cluster.
-	Default: 0
+tcp_syn_retries - INTEGER
+	Number of times initial SYNs for an active TCP connection attempt
+	will be retransmitted. Should not be higher than 255. Default value
+	is 5, which corresponds to ~180seconds.
+
+tcp_timestamps - BOOLEAN
+	Enable timestamps as defined in RFC1323.
 
 tcp_tso_win_divisor - INTEGER
-       This allows control over what percentage of the congestion window
-       can be consumed by a single TSO frame.
-       The setting of this parameter is a choice between burstiness and
-       building larger TSO frames.
-       Default: 3
+	This allows control over what percentage of the congestion window
+	can be consumed by a single TSO frame.
+	The setting of this parameter is a choice between burstiness and
+	building larger TSO frames.
+	Default: 3
 
-tcp_frto - BOOLEAN
-	Enables F-RTO, an enhanced recovery algorithm for TCP retransmission
-	timeouts.  It is particularly beneficial in wireless environments
-	where packet loss is typically due to random radio interference
-	rather than intermediate router congestion.
+tcp_tw_recycle - BOOLEAN
+	Enable fast recycling TIME-WAIT sockets. Default value is 0.
+	It should not be changed without advice/request of technical
+	experts.
 
-tcp_allowed_congestion_control - STRING
-	Show/set the congestion control choices available to non-privileged
-	processes. The list is a subset of those listed in
-	tcp_available_congestion_control.
-	Default is "reno" and the default setting (tcp_congestion_control).
+tcp_tw_reuse - BOOLEAN
+	Allow to reuse TIME-WAIT sockets for new connections when it is
+	safe from protocol viewpoint. Default value is 0.
+	It should not be changed without advice/request of technical
+	experts.
 
-tcp_available_congestion_control - STRING
-	Shows the available congestion control choices that are registered.
-	More congestion control algorithms may be available as modules,
-	but not loaded.
+tcp_window_scaling - BOOLEAN
+	Enable window scaling as defined in RFC1323.
 
-tcp_congestion_control - STRING
-	Set the congestion control algorithm to be used for new
-	connections. The algorithm "reno" is always available, but
-	additional choices may be available based on kernel configuration.
-	Default is set as part of kernel configuration.
+tcp_wmem - vector of 3 INTEGERs: min, default, max
+	min: Amount of memory reserved for send buffers for TCP socket.
+	Each TCP socket has rights to use it due to fact of its birth.
+	Default: 4K
 
-somaxconn - INTEGER
-	Limit of socket listen() backlog, known in userspace as SOMAXCONN.
-	Defaults to 128.  See also tcp_max_syn_backlog for additional tuning
-	for TCP sockets.
+	default: Amount of memory allowed for send buffers for TCP socket
+	by default. This value overrides net.core.wmem_default used
+	by other protocols, it is usually lower than net.core.wmem_default.
+	Default: 16K
+
+	max: Maximal amount of memory allowed for automatically selected
+	send buffers for TCP socket. This value does not override
+	net.core.wmem_max, "static" selection via SO_SNDBUF does not use this.
+	Default: 128K
 
 tcp_workaround_signed_windows - BOOLEAN
 	If set, assume no receipt of a window scaling option means the
@@ -380,13 +387,6 @@
 	not receive a window scaling option from them.
 	Default: 0
 
-tcp_slow_start_after_idle - BOOLEAN
-	If set, provide RFC2861 behavior and time out the congestion
-	window after an idle period.  An idle period is defined at
-	the current RTO.  If unset, the congestion window will not
-	be timed out after an idle period.
-	Default: 1
-
 CIPSOv4 Variables:
 
 cipso_cache_enable - BOOLEAN
@@ -986,4 +986,3 @@
 slot_timeout FIXME
 warn_noreply_time FIXME
 
-$Id: ip-sysctl.txt,v 1.20 2001/12/13 09:00:18 davem Exp $

--
Stephen Hemminger <shemminger@osdl.org>

