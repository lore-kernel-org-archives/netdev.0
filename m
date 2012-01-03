From: Ben Greear <greearb@candelatech.com>
Subject: Why is gre0 auto-created, and can we fix it?
Date: Tue, 03 Jan 2012 11:49:50 -0800
Message-ID: <4F035BDE.5060409@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54055 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754438Ab2ACTtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 14:49:51 -0500
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id q03JnoTo027066
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 3 Jan 2012 11:49:50 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While trying to figure out why 'gre0' doesn't
go away properly in my application, I noticed that
it is auto-created if you just run 'ifconfig gre0'.
(Same thing happens if you use 'ip link show gre0')

As far as I can tell, no other interfaces are auto-created
in this manner.

If I cook up a patch to 'fix' this, would it be acceptable,
or are we stuck with the current behaviour for backwards-compat
reasons?

[root@lec2010-ath9k-1 lanforge]# rmmod ip_gre
[root@lec2010-ath9k-1 lanforge]# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
     link/ether 00:90:0b:13:ed:ea brd ff:ff:ff:ff:ff:ff
3: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
     link/ether 00:90:0b:13:ed:eb brd ff:ff:ff:ff:ff:ff
[root@lec2010-ath9k-1 lanforge]# ifconfig gre0
gre0      Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-01-00-00-00-00-00-00-00-00-00
           NOARP  MTU:1476  Metric:1

[root@lec2010-ath9k-1 lanforge]# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
     link/ether 00:90:0b:13:ed:ea brd ff:ff:ff:ff:ff:ff
3: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
     link/ether 00:90:0b:13:ed:eb brd ff:ff:ff:ff:ff:ff
76: gre0: <NOARP> mtu 1476 qdisc noop state DOWN
     link/gre 0.0.0.0 brd 0.0.0.0
[root@lec2010-ath9k-1 lanforge]# ifconfig tap0
tap0: error fetching interface information: Device not found

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
