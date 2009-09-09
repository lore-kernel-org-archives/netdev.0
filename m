From: jamal <hadi@cyberus.ca>
Subject: Re: [iproute2] tc action mirred    question
Date: Wed, 09 Sep 2009 18:11:06 -0400
Message-ID: <1252534266.4119.5.camel@dogo.mojatatu.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com>
	 <1252376168.5244.11.camel@dogo.mojatatu.com>
	 <313388.35529.qm@web111617.mail.gq1.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux netdev <netdev@vger.kernel.org>
To: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f192.google.com ([209.85.221.192]:56722 "EHLO
	mail-qy0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754387AbZIIWNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 18:13:30 -0400
Received: by qyk30 with SMTP id 30so4049610qyk.5
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2009 15:13:32 -0700 (PDT)
In-Reply-To: <313388.35529.qm@web111617.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-09 at 06:12 -0700, Xiaofei Wu wrote:


> 
> After run 'tcpdump -i wlan1 -e', I can not capture any packets.

Could it be related to the wireless driver? Here's something i tried
on my laptop
---
dogo:/home/hadi# tc qdisc add dev lo handle 1: root prio

dogo:/home/hadi# tc filter add dev lo parent 1: protocol ip prio 10 u32
match ip src 127.0.0.1/24 flowid 1:16 action pedit munge offset -14 u16
set 0x0023 munge offset -12 u32 set 0xcdafecda munge offset -8 u32 set
0x0023cdaf munge offset -4 u32 set 0xd0740800 pipe action mirred egress
mirror dev eth0
---

On window1: tcpdump -n -i eth0
on window2:  ping 127.0.0.2

On window1 i see:
----
dogo:/home/hadi# tcpdump -n -i eth0 -e
tcpdump: verbose output suppressed, use -v or -vv for full protocol
decode
listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
18:05:23.184602 00:23:cd:af:d0:74 > 00:23:cd:af:ec:da, ethertype IPv4
(0x0800), length 98: 127.0.0.2 > 127.0.0.2: ICMP echo request, id 53329,
seq 1, length 64
18:05:23.558949 00:06:dc:44:4b:ed > ff:ff:ff:ff:ff:ff, ethertype ARP
(0x0806), length 60: arp who-has 10.0.0.34 tell 10.0.0.33
18:05:24.199184 00:23:cd:af:d0:74 > 00:23:cd:af:ec:da, ethertype IPv4
(0x0800), length 98: 127.0.0.2 > 127.0.0.2: ICMP echo request, id 53329,
seq 2, length 64
--------

Try the exact example, if it doesnt work then you have other problems;

cheers,
jamal


