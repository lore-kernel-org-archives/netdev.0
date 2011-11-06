From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Linux Route Cache performance tests
Date: Sun, 06 Nov 2011 16:57:22 +0100
Message-ID: <4EB6AE62.5050803@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:48703 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753167Ab1KFP5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Nov 2011 10:57:24 -0500
Received: from unknown (HELO [192.168.1.200]) (itcare_pstaszewski@[95.48.69.170])
          (envelope-sender <pstaszewski@itcare.pl>)
          by iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 6 Nov 2011 15:57:22 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello



I make some networking performance tests for Linux 3.1

Configuration:

Linux (pktget) ----> Linux (router) ----> Linux (Sink)

pktgen config:
clone_skb 32
pkt_size 64
delay 0

pgset "flag IPDST_RND"
pgset "dst_min 10.0.0.0"
pgset "dst_max 10.18.255.255"
pgset "config 1"
pgset "flows 256"
pgset "flowlen 8"

TX performance for this host:
eth0:            RX: 0.00 P/s      TX: 12346107.73 P/s      TOTAL: 
12346107.73 P/s

On Linux (router):
grep . /proc/sys/net/ipv4/route/*
/proc/sys/net/ipv4/route/error_burst:500
/proc/sys/net/ipv4/route/error_cost:100
grep: /proc/sys/net/ipv4/route/flush: Permission denied
/proc/sys/net/ipv4/route/gc_elasticity:4
/proc/sys/net/ipv4/route/gc_interval:60
/proc/sys/net/ipv4/route/gc_min_interval:0
/proc/sys/net/ipv4/route/gc_min_interval_ms:500
/proc/sys/net/ipv4/route/gc_thresh:2000000
/proc/sys/net/ipv4/route/gc_timeout:60
/proc/sys/net/ipv4/route/max_size:8388608
/proc/sys/net/ipv4/route/min_adv_mss:256
/proc/sys/net/ipv4/route/min_pmtu:552
/proc/sys/net/ipv4/route/mtu_expires:600
/proc/sys/net/ipv4/route/redirect_load:2
/proc/sys/net/ipv4/route/redirect_number:9
/proc/sys/net/ipv4/route/redirect_silence:2048

For the first 30secs maybee more router is forwarding ~5Mpps to the 
Linux (Sink)
and some stats for this forst 30secs in attached image:

http://imageshack.us/photo/my-images/684/test1ih.png/

Left up - pktgen linux
left down - Linux router (htop)
Right up - Linux router (bwm-ng - showing pps)
Right down - Linux router (lnstat)


And all is good - performance 5Mpps until Linux router will reach ~1kk 
entries
What You can see on next attached image:

http://imageshack.us/photo/my-images/24/test2id.png/

Forwarding performance drops from 5Mpps to 1,8Mpps
And after 3 - 4 minutes it will stop on 0,7Mpps


After flushing the route cache performance increase from 0.7Mpps to 6Mpps
What You can see on next attached image:

http://imageshack.us/photo/my-images/197/test3r.png/

Is it possible to turn off route cache ? and see what performance will 
be without caching


Thanks
Pawel
