From: Ben Greear <greearb@candelatech.com>
Subject: Interface without IP address can route??
Date: Tue, 23 Aug 2011 17:20:29 -0700
Message-ID: <4E5443CD.60502@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47983 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730Ab1HXAUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 20:20:30 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p7O0KTOa000792
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 23 Aug 2011 17:20:29 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just noticed on a 3.0.1 kernel that the system is routing packets
received on an interface without an IP address. (I was trying to use the
interface in a user-space wifi_station-to-wired bridge application).

[root@lf0301-demo1 lanforge]# cat /proc/sys/net/ipv4/conf/sta1/forwarding
1
[root@lf0301-demo1 lanforge]# ifconfig sta1
sta1      Link encap:Ethernet  HWaddr 00:03:2D:12:16:0D
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:85248 errors:0 dropped:0 overruns:0 frame:0
           TX packets:1419 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:67423391 (64.2 MiB)  TX bytes:1087581 (1.0 MiB)


Seems that older stock kernels have forwarding set for interfaces without
IP addresses too, so maybe it's always been this way...

Anyway, I can add some logic to my config to explicitly disable
routing for interfaces w/out IP address, but it seems to me that
it should automatically not route packets received on an interface
that had no IP address on it..

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
