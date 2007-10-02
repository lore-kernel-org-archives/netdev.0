From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 13:40:20 -0700
Message-ID: <4702ACB4.8020709@hp.com>
References: <20071002005917.GB5480@bitmover.com>	<E1IcfN0-0007tt-00@gondolin.me.apana.org.au>	<20071002150935.GC17418@bitmover.com> <47028DEF.5070009@psc.edu>	<20071002190742.GC29944@bitmover.com>	<20071002193304.GA31611@bitmover.com> <4702A1B6.5020505@psc.edu> <20071002201420.GE29944@bitmover.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010708090704070806030703"
Cc: John Heffner <jheffner@psc.edu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: Larry McVoy <lm@bitmover.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:53871 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753669AbXJBUk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 16:40:26 -0400
In-Reply-To: <20071002201420.GE29944@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010708090704070806030703
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

> Alternatively, take your favorite test programs, such as John's,
> and make a second pair that reverses the direction the data is 
> sent.  So one pair is server sends, the other is server receives,
> try both.  That's where we started, BitKeeper, my stripped down test,
> and John's test all exhibit the same behavior.  And the rsh test
> is just a really simple way to demonstrate it.

Netperf TCP_STREAM - server receives.  TCP_MAERTS (STREAM backwards) - server sends:

[root@hpcpc106 ~]# netperf -H 192.168.2.107
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.2.107 
(192.168.2.107) port 0 AF_INET : demo
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

  87380  87380  87380    10.17     941.46
[root@hpcpc106 ~]# netperf -H 192.168.2.107 -t TCP_MAERTS
TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.2.107 
(192.168.2.107) port 0 AF_INET : demo
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

  87380  87380  87380    10.15     941.35

The above took all the defaults for socket buffers and such.

  [root@hpcpc106 ~]# uname -a
Linux hpcpc106.cup.hp.com 2.6.18-8.el5 #1 SMP Fri Jan 26 14:16:09 EST 2007 ia64 
ia64 ia64 GNU/Linux

[root@hpcpc106 ~]# ethtool -i eth2
driver: e1000
version: 7.2.7-k2-NAPI
firmware-version: N/A
bus-info: 0000:06:01.0

between a pair of 1.6 GHz itanium2 montecito rx2660's with a dual-port HP A9900A 
(Intel 82546GB) in slot 3 of the io cage on each.  Connection is actually 
back-to-back rather than through a switch.  I'm afraid I've nothing older installed.

sysctl settings attached

Where I do have things connected via a switch (HP ProCurve 3500 IIRC, perhaps a 
2724) is through the core BCM5704:

[root@hpcpc106 netperf2_work]# netperf -H hpcpc107
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to hpcpc107.cup.hp.com 
(16.89.84.107) port 0 AF_INET : demo
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

  87380  87380  87380    10.03     941.41

[root@hpcpc106 netperf2_work]# netperf -H hpcpc107 -t TCP_MAERTS
TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to hpcpc107.cup.hp.com 
(16.89.84.107) port 0 AF_INET : demo
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

  87380  87380  87380    10.03     941.37

[root@hpcpc106 netperf2_work]# ethtool -i eth0
driver: tg3
version: 3.65-rh
firmware-version: 5704-v3.27
bus-info: 0000:01:02.0

rick jones

--------------010708090704070806030703
Content-Type: text/plain;
 name="sysctl.net.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sysctl.net.txt"

net.ipv6.conf.eth2.router_probe_interval = 60
net.ipv6.conf.eth2.accept_ra_rtr_pref = 1
net.ipv6.conf.eth2.accept_ra_pinfo = 1
net.ipv6.conf.eth2.accept_ra_defrtr = 1
net.ipv6.conf.eth2.max_addresses = 16
net.ipv6.conf.eth2.max_desync_factor = 600
net.ipv6.conf.eth2.regen_max_retry = 5
net.ipv6.conf.eth2.temp_prefered_lft = 86400
net.ipv6.conf.eth2.temp_valid_lft = 604800
net.ipv6.conf.eth2.use_tempaddr = 0
net.ipv6.conf.eth2.force_mld_version = 0
net.ipv6.conf.eth2.router_solicitation_delay = 1
net.ipv6.conf.eth2.router_solicitation_interval = 4
net.ipv6.conf.eth2.router_solicitations = 3
net.ipv6.conf.eth2.dad_transmits = 1
net.ipv6.conf.eth2.autoconf = 1
net.ipv6.conf.eth2.accept_redirects = 1
net.ipv6.conf.eth2.accept_ra = 1
net.ipv6.conf.eth2.mtu = 1500
net.ipv6.conf.eth2.hop_limit = 64
net.ipv6.conf.eth2.forwarding = 0
net.ipv6.conf.eth0.router_probe_interval = 60
net.ipv6.conf.eth0.accept_ra_rtr_pref = 1
net.ipv6.conf.eth0.accept_ra_pinfo = 1
net.ipv6.conf.eth0.accept_ra_defrtr = 1
net.ipv6.conf.eth0.max_addresses = 16
net.ipv6.conf.eth0.max_desync_factor = 600
net.ipv6.conf.eth0.regen_max_retry = 5
net.ipv6.conf.eth0.temp_prefered_lft = 86400
net.ipv6.conf.eth0.temp_valid_lft = 604800
net.ipv6.conf.eth0.use_tempaddr = 0
net.ipv6.conf.eth0.force_mld_version = 0
net.ipv6.conf.eth0.router_solicitation_delay = 1
net.ipv6.conf.eth0.router_solicitation_interval = 4
net.ipv6.conf.eth0.router_solicitations = 3
net.ipv6.conf.eth0.dad_transmits = 1
net.ipv6.conf.eth0.autoconf = 1
net.ipv6.conf.eth0.accept_redirects = 1
net.ipv6.conf.eth0.accept_ra = 1
net.ipv6.conf.eth0.mtu = 1500
net.ipv6.conf.eth0.hop_limit = 64
net.ipv6.conf.eth0.forwarding = 0
net.ipv6.conf.default.router_probe_interval = 60
net.ipv6.conf.default.accept_ra_rtr_pref = 1
net.ipv6.conf.default.accept_ra_pinfo = 1
net.ipv6.conf.default.accept_ra_defrtr = 1
net.ipv6.conf.default.max_addresses = 16
net.ipv6.conf.default.max_desync_factor = 600
net.ipv6.conf.default.regen_max_retry = 5
net.ipv6.conf.default.temp_prefered_lft = 86400
net.ipv6.conf.default.temp_valid_lft = 604800
net.ipv6.conf.default.use_tempaddr = 0
net.ipv6.conf.default.force_mld_version = 0
net.ipv6.conf.default.router_solicitation_delay = 1
net.ipv6.conf.default.router_solicitation_interval = 4
net.ipv6.conf.default.router_solicitations = 3
net.ipv6.conf.default.dad_transmits = 1
net.ipv6.conf.default.autoconf = 1
net.ipv6.conf.default.accept_redirects = 1
net.ipv6.conf.default.accept_ra = 1
net.ipv6.conf.default.mtu = 1280
net.ipv6.conf.default.hop_limit = 64
net.ipv6.conf.default.forwarding = 0
net.ipv6.conf.all.router_probe_interval = 60
net.ipv6.conf.all.accept_ra_rtr_pref = 1
net.ipv6.conf.all.accept_ra_pinfo = 1
net.ipv6.conf.all.accept_ra_defrtr = 1
net.ipv6.conf.all.max_addresses = 16
net.ipv6.conf.all.max_desync_factor = 600
net.ipv6.conf.all.regen_max_retry = 5
net.ipv6.conf.all.temp_prefered_lft = 86400
net.ipv6.conf.all.temp_valid_lft = 604800
net.ipv6.conf.all.use_tempaddr = 0
net.ipv6.conf.all.force_mld_version = 0
net.ipv6.conf.all.router_solicitation_delay = 1
net.ipv6.conf.all.router_solicitation_interval = 4
net.ipv6.conf.all.router_solicitations = 3
net.ipv6.conf.all.dad_transmits = 1
net.ipv6.conf.all.autoconf = 1
net.ipv6.conf.all.accept_redirects = 1
net.ipv6.conf.all.accept_ra = 1
net.ipv6.conf.all.mtu = 1280
net.ipv6.conf.all.hop_limit = 64
net.ipv6.conf.all.forwarding = 0
net.ipv6.conf.lo.router_probe_interval = 60
net.ipv6.conf.lo.accept_ra_rtr_pref = 1
net.ipv6.conf.lo.accept_ra_pinfo = 1
net.ipv6.conf.lo.accept_ra_defrtr = 1
net.ipv6.conf.lo.max_addresses = 16
net.ipv6.conf.lo.max_desync_factor = 600
net.ipv6.conf.lo.regen_max_retry = 5
net.ipv6.conf.lo.temp_prefered_lft = 86400
net.ipv6.conf.lo.temp_valid_lft = 604800
net.ipv6.conf.lo.use_tempaddr = -1
net.ipv6.conf.lo.force_mld_version = 0
net.ipv6.conf.lo.router_solicitation_delay = 1
net.ipv6.conf.lo.router_solicitation_interval = 4
net.ipv6.conf.lo.router_solicitations = 3
net.ipv6.conf.lo.dad_transmits = 1
net.ipv6.conf.lo.autoconf = 1
net.ipv6.conf.lo.accept_redirects = 1
net.ipv6.conf.lo.accept_ra = 1
net.ipv6.conf.lo.mtu = 16436
net.ipv6.conf.lo.hop_limit = 64
net.ipv6.conf.lo.forwarding = 0
net.ipv6.neigh.eth2.base_reachable_time_ms = 30000
net.ipv6.neigh.eth2.retrans_time_ms = 1000
net.ipv6.neigh.eth2.locktime = 0
net.ipv6.neigh.eth2.proxy_delay = 800
net.ipv6.neigh.eth2.anycast_delay = 1000
net.ipv6.neigh.eth2.proxy_qlen = 64
net.ipv6.neigh.eth2.unres_qlen = 3
net.ipv6.neigh.eth2.gc_stale_time = 60
net.ipv6.neigh.eth2.delay_first_probe_time = 5
net.ipv6.neigh.eth2.retrans_time = 1000
net.ipv6.neigh.eth2.app_solicit = 0
net.ipv6.neigh.eth2.ucast_solicit = 3
net.ipv6.neigh.eth2.mcast_solicit = 3
net.ipv6.neigh.eth0.base_reachable_time_ms = 30000
net.ipv6.neigh.eth0.retrans_time_ms = 1000
net.ipv6.neigh.eth0.locktime = 0
net.ipv6.neigh.eth0.proxy_delay = 800
net.ipv6.neigh.eth0.anycast_delay = 1000
net.ipv6.neigh.eth0.proxy_qlen = 64
net.ipv6.neigh.eth0.unres_qlen = 3
net.ipv6.neigh.eth0.gc_stale_time = 60
net.ipv6.neigh.eth0.delay_first_probe_time = 5
net.ipv6.neigh.eth0.retrans_time = 1000
net.ipv6.neigh.eth0.app_solicit = 0
net.ipv6.neigh.eth0.ucast_solicit = 3
net.ipv6.neigh.eth0.mcast_solicit = 3
net.ipv6.neigh.lo.base_reachable_time_ms = 30000
net.ipv6.neigh.lo.retrans_time_ms = 1000
net.ipv6.neigh.lo.locktime = 0
net.ipv6.neigh.lo.proxy_delay = 800
net.ipv6.neigh.lo.anycast_delay = 1000
net.ipv6.neigh.lo.proxy_qlen = 64
net.ipv6.neigh.lo.unres_qlen = 3
net.ipv6.neigh.lo.gc_stale_time = 60
net.ipv6.neigh.lo.delay_first_probe_time = 5
net.ipv6.neigh.lo.retrans_time = 1000
net.ipv6.neigh.lo.app_solicit = 0
net.ipv6.neigh.lo.ucast_solicit = 3
net.ipv6.neigh.lo.mcast_solicit = 3
net.ipv6.neigh.default.base_reachable_time_ms = 30000
net.ipv6.neigh.default.retrans_time_ms = 1000
net.ipv6.neigh.default.gc_thresh3 = 1024
net.ipv6.neigh.default.gc_thresh2 = 512
net.ipv6.neigh.default.gc_thresh1 = 128
net.ipv6.neigh.default.gc_interval = 30
net.ipv6.neigh.default.locktime = 0
net.ipv6.neigh.default.proxy_delay = 800
net.ipv6.neigh.default.anycast_delay = 1000
net.ipv6.neigh.default.proxy_qlen = 64
net.ipv6.neigh.default.unres_qlen = 3
net.ipv6.neigh.default.gc_stale_time = 60
net.ipv6.neigh.default.delay_first_probe_time = 5
net.ipv6.neigh.default.retrans_time = 1000
net.ipv6.neigh.default.app_solicit = 0
net.ipv6.neigh.default.ucast_solicit = 3
net.ipv6.neigh.default.mcast_solicit = 3
net.ipv6.mld_max_msf = 64
net.ipv6.ip6frag_secret_interval = 600
net.ipv6.ip6frag_time = 60
net.ipv6.ip6frag_low_thresh = 196608
net.ipv6.ip6frag_high_thresh = 262144
net.ipv6.bindv6only = 0
net.ipv6.icmp.ratelimit = 1000
net.ipv6.route.gc_min_interval_ms = 500
net.ipv6.route.min_adv_mss = 1
net.ipv6.route.mtu_expires = 600
net.ipv6.route.gc_elasticity = 0
net.ipv6.route.gc_interval = 30
net.ipv6.route.gc_timeout = 60
net.ipv6.route.gc_min_interval = 0
net.ipv6.route.max_size = 4096
net.ipv6.route.gc_thresh = 1024
net.unix.max_dgram_qlen = 10
net.token-ring.rif_timeout = 600000
net.ipv4.conf.eth3.promote_secondaries = 0
net.ipv4.conf.eth3.force_igmp_version = 0
net.ipv4.conf.eth3.disable_policy = 0
net.ipv4.conf.eth3.disable_xfrm = 0
net.ipv4.conf.eth3.arp_accept = 0
net.ipv4.conf.eth3.arp_ignore = 1
net.ipv4.conf.eth3.arp_announce = 0
net.ipv4.conf.eth3.arp_filter = 1
net.ipv4.conf.eth3.tag = 0
net.ipv4.conf.eth3.log_martians = 0
net.ipv4.conf.eth3.bootp_relay = 0
net.ipv4.conf.eth3.medium_id = 0
net.ipv4.conf.eth3.proxy_arp = 0
net.ipv4.conf.eth3.accept_source_route = 0
net.ipv4.conf.eth3.send_redirects = 1
net.ipv4.conf.eth3.rp_filter = 1
net.ipv4.conf.eth3.shared_media = 1
net.ipv4.conf.eth3.secure_redirects = 1
net.ipv4.conf.eth3.accept_redirects = 1
net.ipv4.conf.eth3.mc_forwarding = 0
net.ipv4.conf.eth3.forwarding = 0
net.ipv4.conf.eth2.promote_secondaries = 0
net.ipv4.conf.eth2.force_igmp_version = 0
net.ipv4.conf.eth2.disable_policy = 0
net.ipv4.conf.eth2.disable_xfrm = 0
net.ipv4.conf.eth2.arp_accept = 0
net.ipv4.conf.eth2.arp_ignore = 1
net.ipv4.conf.eth2.arp_announce = 0
net.ipv4.conf.eth2.arp_filter = 1
net.ipv4.conf.eth2.tag = 0
net.ipv4.conf.eth2.log_martians = 0
net.ipv4.conf.eth2.bootp_relay = 0
net.ipv4.conf.eth2.medium_id = 0
net.ipv4.conf.eth2.proxy_arp = 0
net.ipv4.conf.eth2.accept_source_route = 0
net.ipv4.conf.eth2.send_redirects = 1
net.ipv4.conf.eth2.rp_filter = 1
net.ipv4.conf.eth2.shared_media = 1
net.ipv4.conf.eth2.secure_redirects = 1
net.ipv4.conf.eth2.accept_redirects = 1
net.ipv4.conf.eth2.mc_forwarding = 0
net.ipv4.conf.eth2.forwarding = 0
net.ipv4.conf.eth0.promote_secondaries = 0
net.ipv4.conf.eth0.force_igmp_version = 0
net.ipv4.conf.eth0.disable_policy = 0
net.ipv4.conf.eth0.disable_xfrm = 0
net.ipv4.conf.eth0.arp_accept = 0
net.ipv4.conf.eth0.arp_ignore = 1
net.ipv4.conf.eth0.arp_announce = 0
net.ipv4.conf.eth0.arp_filter = 1
net.ipv4.conf.eth0.tag = 0
net.ipv4.conf.eth0.log_martians = 0
net.ipv4.conf.eth0.bootp_relay = 0
net.ipv4.conf.eth0.medium_id = 0
net.ipv4.conf.eth0.proxy_arp = 0
net.ipv4.conf.eth0.accept_source_route = 0
net.ipv4.conf.eth0.send_redirects = 1
net.ipv4.conf.eth0.rp_filter = 1
net.ipv4.conf.eth0.shared_media = 1
net.ipv4.conf.eth0.secure_redirects = 1
net.ipv4.conf.eth0.accept_redirects = 1
net.ipv4.conf.eth0.mc_forwarding = 0
net.ipv4.conf.eth0.forwarding = 0
net.ipv4.conf.lo.promote_secondaries = 0
net.ipv4.conf.lo.force_igmp_version = 0
net.ipv4.conf.lo.disable_policy = 1
net.ipv4.conf.lo.disable_xfrm = 1
net.ipv4.conf.lo.arp_accept = 0
net.ipv4.conf.lo.arp_ignore = 0
net.ipv4.conf.lo.arp_announce = 0
net.ipv4.conf.lo.arp_filter = 0
net.ipv4.conf.lo.tag = 0
net.ipv4.conf.lo.log_martians = 0
net.ipv4.conf.lo.bootp_relay = 0
net.ipv4.conf.lo.medium_id = 0
net.ipv4.conf.lo.proxy_arp = 0
net.ipv4.conf.lo.accept_source_route = 1
net.ipv4.conf.lo.send_redirects = 1
net.ipv4.conf.lo.rp_filter = 0
net.ipv4.conf.lo.shared_media = 1
net.ipv4.conf.lo.secure_redirects = 1
net.ipv4.conf.lo.accept_redirects = 1
net.ipv4.conf.lo.mc_forwarding = 0
net.ipv4.conf.lo.forwarding = 0
net.ipv4.conf.default.promote_secondaries = 0
net.ipv4.conf.default.force_igmp_version = 0
net.ipv4.conf.default.disable_policy = 0
net.ipv4.conf.default.disable_xfrm = 0
net.ipv4.conf.default.arp_accept = 0
net.ipv4.conf.default.arp_ignore = 1
net.ipv4.conf.default.arp_announce = 0
net.ipv4.conf.default.arp_filter = 1
net.ipv4.conf.default.tag = 0
net.ipv4.conf.default.log_martians = 0
net.ipv4.conf.default.bootp_relay = 0
net.ipv4.conf.default.medium_id = 0
net.ipv4.conf.default.proxy_arp = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.send_redirects = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.shared_media = 1
net.ipv4.conf.default.secure_redirects = 1
net.ipv4.conf.default.accept_redirects = 1
net.ipv4.conf.default.mc_forwarding = 0
net.ipv4.conf.default.forwarding = 0
net.ipv4.conf.all.promote_secondaries = 0
net.ipv4.conf.all.force_igmp_version = 0
net.ipv4.conf.all.disable_policy = 0
net.ipv4.conf.all.disable_xfrm = 0
net.ipv4.conf.all.arp_accept = 0
net.ipv4.conf.all.arp_ignore = 0
net.ipv4.conf.all.arp_announce = 0
net.ipv4.conf.all.arp_filter = 0
net.ipv4.conf.all.tag = 0
net.ipv4.conf.all.log_martians = 0
net.ipv4.conf.all.bootp_relay = 0
net.ipv4.conf.all.medium_id = 0
net.ipv4.conf.all.proxy_arp = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.send_redirects = 1
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.all.shared_media = 1
net.ipv4.conf.all.secure_redirects = 1
net.ipv4.conf.all.accept_redirects = 1
net.ipv4.conf.all.mc_forwarding = 0
net.ipv4.conf.all.forwarding = 0
net.ipv4.neigh.eth3.base_reachable_time_ms = 30000
net.ipv4.neigh.eth3.retrans_time_ms = 1000
net.ipv4.neigh.eth3.locktime = 1000
net.ipv4.neigh.eth3.proxy_delay = 800
net.ipv4.neigh.eth3.anycast_delay = 1000
net.ipv4.neigh.eth3.proxy_qlen = 64
net.ipv4.neigh.eth3.unres_qlen = 3
net.ipv4.neigh.eth3.gc_stale_time = 60
net.ipv4.neigh.eth3.delay_first_probe_time = 5
net.ipv4.neigh.eth3.base_reachable_time = 30
net.ipv4.neigh.eth3.retrans_time = 1000
net.ipv4.neigh.eth3.app_solicit = 0
net.ipv4.neigh.eth3.ucast_solicit = 3
net.ipv4.neigh.eth3.mcast_solicit = 3
net.ipv4.neigh.eth2.base_reachable_time_ms = 30000
net.ipv4.neigh.eth2.retrans_time_ms = 1000
net.ipv4.neigh.eth2.locktime = 1000
net.ipv4.neigh.eth2.proxy_delay = 800
net.ipv4.neigh.eth2.anycast_delay = 1000
net.ipv4.neigh.eth2.proxy_qlen = 64
net.ipv4.neigh.eth2.unres_qlen = 3
net.ipv4.neigh.eth2.gc_stale_time = 60
net.ipv4.neigh.eth2.delay_first_probe_time = 5
net.ipv4.neigh.eth2.base_reachable_time = 30
net.ipv4.neigh.eth2.retrans_time = 1000
net.ipv4.neigh.eth2.app_solicit = 0
net.ipv4.neigh.eth2.ucast_solicit = 3
net.ipv4.neigh.eth2.mcast_solicit = 3
net.ipv4.neigh.eth0.base_reachable_time_ms = 30000
net.ipv4.neigh.eth0.retrans_time_ms = 1000
net.ipv4.neigh.eth0.locktime = 1000
net.ipv4.neigh.eth0.proxy_delay = 800
net.ipv4.neigh.eth0.anycast_delay = 1000
net.ipv4.neigh.eth0.proxy_qlen = 64
net.ipv4.neigh.eth0.unres_qlen = 3
net.ipv4.neigh.eth0.gc_stale_time = 60
net.ipv4.neigh.eth0.delay_first_probe_time = 5
net.ipv4.neigh.eth0.base_reachable_time = 30
net.ipv4.neigh.eth0.retrans_time = 1000
net.ipv4.neigh.eth0.app_solicit = 0
net.ipv4.neigh.eth0.ucast_solicit = 3
net.ipv4.neigh.eth0.mcast_solicit = 3
net.ipv4.neigh.lo.base_reachable_time_ms = 30000
net.ipv4.neigh.lo.retrans_time_ms = 1000
net.ipv4.neigh.lo.locktime = 1000
net.ipv4.neigh.lo.proxy_delay = 800
net.ipv4.neigh.lo.anycast_delay = 1000
net.ipv4.neigh.lo.proxy_qlen = 64
net.ipv4.neigh.lo.unres_qlen = 3
net.ipv4.neigh.lo.gc_stale_time = 60
net.ipv4.neigh.lo.delay_first_probe_time = 5
net.ipv4.neigh.lo.base_reachable_time = 30
net.ipv4.neigh.lo.retrans_time = 1000
net.ipv4.neigh.lo.app_solicit = 0
net.ipv4.neigh.lo.ucast_solicit = 3
net.ipv4.neigh.lo.mcast_solicit = 3
net.ipv4.neigh.default.base_reachable_time_ms = 30000
net.ipv4.neigh.default.retrans_time_ms = 1000
net.ipv4.neigh.default.gc_thresh3 = 1024
net.ipv4.neigh.default.gc_thresh2 = 512
net.ipv4.neigh.default.gc_thresh1 = 128
net.ipv4.neigh.default.gc_interval = 30
net.ipv4.neigh.default.locktime = 1000
net.ipv4.neigh.default.proxy_delay = 800
net.ipv4.neigh.default.anycast_delay = 1000
net.ipv4.neigh.default.proxy_qlen = 64
net.ipv4.neigh.default.unres_qlen = 3
net.ipv4.neigh.default.gc_stale_time = 60
net.ipv4.neigh.default.delay_first_probe_time = 5
net.ipv4.neigh.default.base_reachable_time = 30
net.ipv4.neigh.default.retrans_time = 1000
net.ipv4.neigh.default.app_solicit = 0
net.ipv4.neigh.default.ucast_solicit = 3
net.ipv4.neigh.default.mcast_solicit = 3
net.ipv4.cipso_rbm_strictvalid = 1
net.ipv4.cipso_rbm_optfmt = 0
net.ipv4.cipso_cache_bucket_size = 10
net.ipv4.cipso_cache_enable = 1
net.ipv4.tcp_slow_start_after_idle = 1
net.ipv4.tcp_dma_copybreak = 4096
net.ipv4.tcp_workaround_signed_windows = 0
net.ipv4.tcp_base_mss = 512
net.ipv4.tcp_mtu_probing = 0
net.ipv4.tcp_abc = 0
net.ipv4.tcp_congestion_control = bic
net.ipv4.tcp_tso_win_divisor = 3
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_no_metrics_save = 0
net.ipv4.ipfrag_max_dist = 64
net.ipv4.ipfrag_secret_interval = 600
net.ipv4.tcp_low_latency = 0
net.ipv4.tcp_frto = 0
net.ipv4.tcp_tw_reuse = 0
net.ipv4.icmp_ratemask = 6168
net.ipv4.icmp_ratelimit = 1000
net.ipv4.tcp_adv_win_scale = 2
net.ipv4.tcp_app_win = 31
net.ipv4.tcp_rmem = 4096	87380	20971520
net.ipv4.tcp_wmem = 4096	87380	20971520
net.ipv4.tcp_mem = 49152	65536	98304
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_reordering = 3
net.ipv4.tcp_fack = 1
net.ipv4.tcp_orphan_retries = 0
net.ipv4.inet_peer_gc_maxtime = 120
net.ipv4.inet_peer_gc_mintime = 10
net.ipv4.inet_peer_maxttl = 600
net.ipv4.inet_peer_minttl = 120
net.ipv4.inet_peer_threshold = 65664
net.ipv4.igmp_max_msf = 10
net.ipv4.igmp_max_memberships = 20
net.ipv4.route.secret_interval = 600
net.ipv4.route.min_adv_mss = 256
net.ipv4.route.min_pmtu = 552
net.ipv4.route.mtu_expires = 600
net.ipv4.route.gc_elasticity = 8
net.ipv4.route.error_burst = 5000
net.ipv4.route.error_cost = 1000
net.ipv4.route.redirect_silence = 20480
net.ipv4.route.redirect_number = 9
net.ipv4.route.redirect_load = 20
net.ipv4.route.gc_interval = 60
net.ipv4.route.gc_timeout = 300
net.ipv4.route.gc_min_interval_ms = 500
net.ipv4.route.gc_min_interval = 0
net.ipv4.route.max_size = 8388608
net.ipv4.route.gc_thresh = 524288
net.ipv4.route.max_delay = 10
net.ipv4.route.min_delay = 2
net.ipv4.icmp_errors_use_inbound_ifaddr = 0
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_echo_ignore_all = 0
net.ipv4.ip_local_port_range = 32768	61000
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_rfc1337 = 0
net.ipv4.tcp_stdurg = 0
net.ipv4.tcp_abort_on_overflow = 0
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 60
net.ipv4.tcp_retries2 = 15
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_keepalive_intvl = 75
net.ipv4.tcp_keepalive_probes = 9
net.ipv4.tcp_keepalive_time = 7200
net.ipv4.ipfrag_time = 30
net.ipv4.ip_dynaddr = 0
net.ipv4.ipfrag_low_thresh = 196608
net.ipv4.ipfrag_high_thresh = 262144
net.ipv4.tcp_max_tw_buckets = 180000
net.ipv4.tcp_max_orphans = 16384
net.ipv4.tcp_synack_retries = 5
net.ipv4.tcp_syn_retries = 5
net.ipv4.ip_nonlocal_bind = 0
net.ipv4.ip_no_pmtu_disc = 0
net.ipv4.ip_default_ttl = 64
net.ipv4.ip_forward = 0
net.ipv4.tcp_retrans_collapse = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.core.netdev_budget = 300
net.core.somaxconn = 128
net.core.xfrm_aevent_rseqth = 2
net.core.xfrm_aevent_etime = 10
net.core.optmem_max = 20480
net.core.message_burst = 10
net.core.message_cost = 5
net.core.netdev_max_backlog = 10000
net.core.dev_weight = 64
net.core.rmem_default = 126976
net.core.wmem_default = 126976
net.core.rmem_max = 20971520
net.core.wmem_max = 20971520

--------------010708090704070806030703--
