From: Sami Farin <safari-kernel@safari.iki.fi>
Subject: Linux 2.6.22: Leak r=1 1
Date: Wed, 11 Jul 2007 20:40:30 +0300
Message-ID: <20070711174030.tjmxpxtfsn4twgk2@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:44320 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753954AbXGKSud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 14:50:33 -0400
Received: from safari.iki.fi (80.223.106.128) by pne-smtpout4-sn2.hy.skanova.net (7.2.075)
        id 45B621690082BDFC for netdev@vger.kernel.org; Wed, 11 Jul 2007 19:40:31 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

That's right, so descriptive is the new Linux kernel 2.6.22.
Took a while to grep what is "leaking".

Linux safari.finland.fbi 2.6.22-cfs-v19 #3 SMP Tue Jul 10 00:22:25 EEST 2007 i686 i686 i386 GNU/Linux

Just normal Internet usage, azureus for example =)
I think this is easy to trigger.
But that printk is not very useful, or is it?
I am also using HTB+ESFQ to limit outgoing bandwidth...

# ss -n|wc -l
870

# ping -A 80.223.96.1 
PING 80.223.96.1 (80.223.96.1) 56(84) bytes of data.
64 bytes from 80.223.96.1: icmp_seq=1 ttl=255 time=431 ms
...
--- 80.223.96.1 ping statistics ---
40 packets transmitted, 25 received, 37% packet loss, time 17954ms
rtt min/avg/max/mdev = 406.000/467.758/530.983/29.384 ms, pipe 2, ipg/ewma 460.361/456.381 ms

But ploss is only temporary (when I am downloading with azureus =) ,
when only uploading (95% of bandwidth used) rtt avg = 32ms).

# dmesg|grep Leak
[114992.191011] Leak r=1 4
[124231.713348] Leak r=1 4
[142807.938284] Leak r=1 4
[142999.674521] Leak r=1 1
[143177.462073] Leak r=1 4
[143230.001570] Leak r=1 4
[143232.982560] Leak r=1 4
[143234.537096] Leak r=1 4
[143297.927760] Leak r=1 4
[143300.633603] Leak r=1 4
[143302.172917] Leak r=1 4
[143357.083193] Leak r=1 1
[143361.780879] Leak r=1 4
[143413.706490] Leak r=1 4
[143552.996598] Leak r=1 1

[root@safari /proc/sys/net/ipv4]# grep . *
icmp_echo_ignore_all:0
icmp_echo_ignore_broadcasts:1
icmp_errors_use_inbound_ifaddr:0
icmp_ignore_bogus_error_responses:1
icmp_ratelimit:1000
icmp_ratemask:6168
igmp_max_memberships:20
igmp_max_msf:10
inet_peer_gc_maxtime:120
inet_peer_gc_mintime:10
inet_peer_maxttl:600
inet_peer_minttl:120
inet_peer_threshold:65664
ip_default_ttl:61
ip_dynaddr:0
ip_forward:0
ip_local_port_range:40000       65535
ip_no_pmtu_disc:1
ip_nonlocal_bind:0
ipfrag_high_thresh:262144
ipfrag_low_thresh:196608
ipfrag_max_dist:64
ipfrag_secret_interval:600
ipfrag_time:30
tcp_abc:2
tcp_abort_on_overflow:0
tcp_adv_win_scale:2
tcp_allowed_congestion_control:cubic bic reno
tcp_app_win:31
tcp_available_congestion_control:cubic bic reno westwood vegas scalable
hybla htcp highspeed
tcp_base_mss:512
tcp_congestion_control:cubic
tcp_dma_copybreak:4096
tcp_dsack:1
tcp_ecn:1
tcp_fack:1
tcp_fin_timeout:30
tcp_frto:1
tcp_frto_response:0
tcp_keepalive_intvl:75
tcp_keepalive_probes:9
tcp_keepalive_time:3300
tcp_low_latency:0
tcp_max_orphans:2048
tcp_max_ssthresh:0
tcp_max_syn_backlog:1024
tcp_max_tw_buckets:180000
tcp_mem:95136   126848  190272
tcp_moderate_rcvbuf:1
tcp_mtu_probing:0
tcp_no_metrics_save:0
tcp_orphan_retries:0
tcp_reordering:3
tcp_retrans_collapse:0
tcp_retries1:3
tcp_retries2:15
tcp_rfc1337:0
tcp_rmem:4096   87380   262144
tcp_sack:1
tcp_slow_start_after_idle:0
tcp_stdurg:0
tcp_syn_retries:5
tcp_synack_retries:5
tcp_syncookies:0
tcp_timestamps:1
tcp_tso_win_divisor:3
tcp_tw_recycle:1
tcp_tw_reuse:0
tcp_window_scaling:1
tcp_wmem:4096   16384   262144
tcp_workaround_signed_windows:0

-- 
Do what you love because life is too short for anything else.

