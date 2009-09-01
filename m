From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 1 Sep 2009 14:03:07 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1>
References: <20090901063726.GA5222@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	davem@linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:53851 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754360AbZIAOFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 10:05:33 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A6C8482C757
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 10:07:11 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id PMNhEZluxvti for <netdev@vger.kernel.org>;
	Tue,  1 Sep 2009 10:07:11 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E555982C786
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 10:05:30 -0400 (EDT)
In-Reply-To: <20090901063726.GA5222@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric: This occurs with a Broadcom driver (bnx2). There is only one
network device up and the IP statistics are correctly incremented.

#ip ro
10.2.36.0/24 dev eth0  proto kernel  scope link  src 10.2.36.121
default via 10.2.36.3 dev eth0
#ip ro get 10.2.36.120
10.2.36.120 dev eth0  src 10.2.36.121
    cache  mtu 1500 advmss 1460 hoplimit 64
ip ro get 239.0.192.2
multicast 239.0.192.2 dev eth0  src 10.2.36.121
    cache <mc>  mtu 1500 advmss 1460 hoplimit 64

dmesg:

[    1.560094] Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.1
(May 6, 2009)
[    1.560192]   alloc irq_desc for 36 on node 0
[    1.560193]   alloc kstat_irqs on node 0
[    1.560197] alloc irq_2_iommu on node 0
[    1.560204] bnx2 0000:01:00.0: PCI INT A -> GSI 36 (level, low) -> IRQ
36
[    1.560275] bnx2 0000:01:00.0: setting latency timer to 64
[    1.560394] bnx2 0000:01:00.0: firmware: requesting
bnx2/bnx2-mips-09-4.6.17.fw


$ netstat -su
IcmpMsg:
    InType0: 4
    InType3: 1
    OutType3: 1
    OutType8: 4
Udp:
    44363 packets received
    0 packets to unknown port received.
    0 packet receive errors
    4363620 packets sent
    SndbufErrors: 738519
UdpLite:
IpExt:
    InMcastPkts: 1289
    OutMcastPkts: 5057780
    InOctets: 13956676
    OutOctets: 1672676365
    InMcastOctets: 36164
    OutMcastOctets: 1658949880

(Your patch to account for TX errors was applied)

clameter@rd-gateway3-deb64:~$ ifconfig
eth0      Link encap:Ethernet  HWaddr 00:21:9b:8f:9f:1b
          inet addr:10.2.36.121  Bcast:10.2.36.255  Mask:255.255.255.0
          inet6 addr: fe80::221:9bff:fe8f:9f1b/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:50091 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4367178 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:14928488 (14.2 MiB)  TX bytes:1509122809 (1.4 GiB)
          Interrupt:36 Memory:d6000000-d6012800

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:89 errors:0 dropped:0 overruns:0 frame:0
          TX packets:89 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:7114 (6.9 KiB)  TX bytes:7114 (6.9 KiB)



