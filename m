From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: CBQ(but probably u32 filter bug), kernel "freeze", at least from
 3.2.0
Date: Tue, 28 Aug 2012 07:50:01 +0300
Message-ID: <a680a8297b2f099eb713b266792b9b82@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:43296 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465Ab2H1EuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 00:50:04 -0400
Received: from webmail.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 032F148951D
	for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 07:50:02 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Got information from friend, confirmed that it crashed at least two my 
boxes also :)
3.0.5-rc1 is working fine, 3.4.1 , 3.2.0 from ubuntu  - crashing
No watchdog fired, and didn't got yet significant debugging 
information.

Very easy to reproduce:
1)run the script
2)ping 192.168.3.234

script:
DEV_OUT=eth0
ICMP="match ip protocol 1 0xff"
U32="protocol ip u32"
DST="match ip dst"
tc qdisc add dev $DEV_OUT root handle 1: cbq avpkt 1000 bandwidth 
100mbit
tc class add dev $DEV_OUT parent 1: classid 1:1 cbq rate 512kbit allot 
1500 prio 5 bounded isolated
tc filter add dev $DEV_OUT parent 1:              prio 3 $U32 $ICMP 
$DST 192.168.3.234 flowid 1:
tc qdisc add dev $DEV_OUT parent 1:1 sfq perturb 10

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
