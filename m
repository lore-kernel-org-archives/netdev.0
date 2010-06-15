From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: IPv6 stops working after ethtool diagnostic
Date: Tue, 15 Jun 2010 12:05:59 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FF43AAD0F@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42274 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755553Ab0FOSGD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 14:06:03 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We ran into a problem on net-next where IPv6 traffic fails after running ethtool -t:

Steps to reproduce:
1. ip addr show eth0
170: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:1b:21:53:0a:d6 brd ff:ff:ff:ff:ff:ff
    inet 190.0.15.5/16 brd 190.0.255.255 scope global eth0
    inet6 fec0::1505/112 scope site 
       valid_lft forever preferred_lft forever
    inet6 fe80::21b:21ff:fe53:ad6/64 scope link 
       valid_lft forever preferred_lft forever

2. ping6 -I eth0 fec0::1314
PING fec0::1314(fec0::1314) from fec0::1505 eth0: 56 data bytes
64 bytes from fec0::1314: icmp_seq=1 ttl=64 time=0.130 ms
64 bytes from fec0::1314: icmp_seq=2 ttl=64 time=0.119 ms
64 bytes from fec0::1314: icmp_seq=3 ttl=64 time=0.167 ms

3 ethtool -t eth0 (ifconfig eth0 down/up has the same effect)

4. ping6 -I eth0 fec0::1314
connect: Network is unreachable

5. ip addr show eth0
170: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:1b:21:53:0a:d6 brd ff:ff:ff:ff:ff:ff
    inet 190.0.15.5/16 brd 190.0.255.255 scope global eth0
    inet6 fec0::1505/112 scope site 
       valid_lft forever preferred_lft forever
    inet6 fe80::21b:21ff:fe53:ad6/64 scope link 
       valid_lft forever preferred_lft forever

Thanks,
Emil