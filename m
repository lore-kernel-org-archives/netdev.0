From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: tc action mirred packet lost
Date: Sun, 31 Oct 2010 13:44:08 +0100
Message-ID: <aff638d83f21a1b8ab3e1911f2d3ac43@justnet.pl>
Reply-To: adam.niescierowicz@justnet.pl
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.justnet.pl ([80.54.30.237]:59565 "EHLO mail.justnet.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755526Ab0JaNLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Oct 2010 09:11:15 -0400
Received: from mail.justnet.pl ([80.54.30.237])
	by service with esmtpa (Exim 4.69)
	(envelope-from <adam.niescierowicz@justnet.pl>)
	id 1PCXGa-000509-9c
	for netdev@vger.kernel.org; Sun, 31 Oct 2010 13:44:08 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hello,
 recently there was a need to create 3-4 copies of the data sent to the 
 router, I decided to use the tc action mirred.


 Ingress traficn on eth1 copies to eth1 eth2, eth3, eth4, eth5 using:
 ---
 tc qdisc add dev eth1 ingress

 tc filter add dev eth1 parent ffff: protocol ip prio 10 u32 match ip 
 src
 0/0 flowid 1:1 action mirred egress mirror dev eth2 pipe action mirred
 egress mirror dev eth3 pipe action mirred egress mirror dev eth4 pipe
 action mirred egress mirror dev eth5
 --


 Unfortunately the number of packets seen on eth1 qdisc is different 
 than the eth [2-5]
 ---
 12:02:57 CET
 qdisc pfifo_fast 0: dev eth0 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 668167 bytes 6001 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
 qdisc pfifo_fast 0: dev eth1 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 36336 bytes 860 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
 qdisc ingress ffff: dev eth1 parent ffff:fff1 ----------------
  Sent 7221533005980 bytes 199468106 pkt (dropped 0, overlimits 0 
 requeues 0)
  backlog 0b 0p requeues 0
 qdisc htb 1: dev eth2 root refcnt 2 r2q 10 default 0 
 direct_packets_stat 197808186 ver 3.17
  Sent 7404614590804 bytes 197808186 pkt (dropped 0, overlimits 0 
 requeues 1976)
  backlog 0b 0p requeues 1976
 qdisc pfifo_fast 0: dev eth3 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 7404614590804 bytes 197808186 pkt (dropped 0, overlimits 0 
 requeues 2779)
  backlog 0b 0p requeues 2779
 qdisc pfifo_fast 0: dev eth4 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 7404614590804 bytes 197808186 pkt (dropped 0, overlimits 0 
 requeues 1958)
  backlog 0b 0p requeues 1958
 qdisc pfifo_fast 0: dev eth5 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 7404614590804 bytes 197808186 pkt (dropped 0, overlimits 0 
 requeues 3231)
  backlog 0b 0p requeues 3231

 12:03:07 CET
 qdisc pfifo_fast 0: dev eth0 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 669819 bytes 6003 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
 qdisc pfifo_fast 0: dev eth1 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 36336 bytes 860 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
 qdisc ingress ffff: dev eth1 parent ffff:fff1 ----------------
  Sent 7221762321336 bytes 199909173 pkt (dropped 0, overlimits 0 
 requeues 0)
  backlog 0b 0p requeues 0
 qdisc htb 1: dev eth2 root refcnt 2 r2q 10 default 0 
 direct_packets_stat 198249138 ver 3.17
  Sent 7404850074198 bytes 198249138 pkt (dropped 0, overlimits 0 
 requeues 1976)
  backlog 0b 0p requeues 1976
 qdisc pfifo_fast 0: dev eth3 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 7404850074198 bytes 198249138 pkt (dropped 0, overlimits 0 
 requeues 2779)
  backlog 0b 0p requeues 2779
 qdisc pfifo_fast 0: dev eth4 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 7404850074198 bytes 198249138 pkt (dropped 0, overlimits 0 
 requeues 1958)
  backlog 0b 0p requeues 1958
 qdisc pfifo_fast 0: dev eth5 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 7404850074198 bytes 198249138 pkt (dropped 0, overlimits 0 
 requeues 3232)
  backlog 0b 0p requeues 3232

 12:03:17 CET
 qdisc pfifo_fast 0: dev eth0 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 671439 bytes 6005 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
 qdisc pfifo_fast 0: dev eth1 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 36336 bytes 860 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
 qdisc ingress ffff: dev eth1 parent ffff:fff1 ----------------
  Sent 7221978715996 bytes 200334775 pkt (dropped 0, overlimits 0 
 requeues 0)
  backlog 0b 0p requeues 0
 qdisc htb 1: dev eth2 root refcnt 2 r2q 10 default 0 
 direct_packets_stat 198674650 ver 3.17
  Sent 7405072421886 bytes 198674650 pkt (dropped 0, overlimits 0 
 requeues 1976)
  backlog 0b 0p requeues 1976
 qdisc pfifo_fast 0: dev eth3 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 7405072421886 bytes 198674650 pkt (dropped 0, overlimits 0 
 requeues 2779)
  backlog 0b 0p requeues 2779
 qdisc pfifo_fast 0: dev eth4 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 7405072421886 bytes 198674650 pkt (dropped 0, overlimits 0 
 requeues 1958)
  backlog 0b 0p requeues 1958
 qdisc pfifo_fast 0: dev eth5 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 
 0 0 1 1 1 1 1 1 1 1
  Sent 7405072421886 bytes 198674650 pkt (dropped 0, overlimits 0 
 requeues 3232)
  backlog 0b 0p requeues 3232
 ---


 also, each packet arriving at the filter is mirred
 ---
 filter protocol ip pref 10 u32
 filter protocol ip pref 10 u32 fh 800: ht divisor 1
 filter protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 
 flowid 1:1  (rule hit 422685 success 422685)
   match 00000000/00000000 at 12 (success 422685 )
         action order 1: mirred (Egress Mirror to device eth2) pipe
         index 9 ref 1 bind 1 installed 9 sec
         Action statistics:
         Sent 212219392 bytes 422685 pkt (dropped 0, overlimits 0 
 requeues 0)
         backlog 0b 0p requeues 0

         action order 2: mirred (Egress Mirror to device eth3) pipe
         index 10 ref 1 bind 1 installed 9 sec
         Action statistics:
         Sent 212219392 bytes 422685 pkt (dropped 0, overlimits 0 
 requeues 0)
         backlog 0b 0p requeues 0

         action order 3: mirred (Egress Mirror to device eth4) pipe
         index 11 ref 1 bind 1 installed 9 sec
         Action statistics:
         Sent 212219392 bytes 422685 pkt (dropped 0, overlimits 0 
 requeues 0)
         backlog 0b 0p requeues 0

         action order 4: mirred (Egress Mirror to device eth5) pipe
         index 12 ref 1 bind 1 installed 9 sec
         Action statistics:
         Sent 212219392 bytes 422685 pkt (dropped 0, overlimits 0 
 requeues 0)
         backlog 0b 0p requeues 0
 ---


 traffic on the interface is between 150-200Mbps
 ---
 ifstat -tb -i eth1,eth2,eth3,eth4,eth5
   Time           eth1                eth2                eth3           
  eth4                eth5
 HH:MM:SS   Kbps in  Kbps out   Kbps in  Kbps out   Kbps in  Kbps out   
 Kbps in  Kbps out   Kbps in  Kbps out
 12:32:13  188022.1      0.00      0.47  188016.0      0.00  188039.9    
 0.00  188016.0      0.00  188039.9
 12:32:14  188743.2      0.00      0.00  188736.6      0.00  188736.6    
 0.00  188736.6      0.00  188736.6
 12:32:15  195705.1      0.00      0.47  195700.9      0.00  195682.9    
 0.00  195682.9      0.00  195700.9
 12:32:16  183506.6      0.00      0.00  183516.1      0.00  183522.2    
 0.00  183522.2      0.00  183504.3
 ---

 Am I doing something wrong, or what is a purpose of packet loss.
 My plan is to mirror 800-900Mbps to 4-8 network devices.

 Thanks

