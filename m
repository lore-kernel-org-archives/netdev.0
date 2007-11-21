From: Ben Greear <greearb@candelatech.com>
Subject: Routing tables associated with VLANs dissappear when parent ethX
 down/up
Date: Tue, 20 Nov 2007 17:20:36 -0800
Message-ID: <474387E4.7020802@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:58245 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932318AbXKUBUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 20:20:37 -0500
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id lAL1Ka7R005301
	for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 17:20:37 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Found something strange today.

Suppose I have eth2 with VLAN 2 (eth2.2) associated with it.  I
add a routing table that is associated with eth2.2 (table 76 in my case).


Now, I run:
ifconfig eth2 down
ifconfig eth2 up

All of the routes in routing table 76 are now gone!  I can
understand how it might be useful to remove the routes from
the eth2 table (as is also done), but it seems pretty extreme
to muck with the VLAN device's tables as well.


[root@lanforge-33-46 local]# ip route show table 76
27.1.1.0/24 via 27.1.1.2 dev eth2.2
default via 27.1.1.1 dev eth2.2
[root@lanforge-33-46 local]# ifconfig eth2.2
eth2.2    Link encap:Ethernet  HWaddr 00:03:2D:08:33:47
           inet addr:27.1.1.2  Bcast:27.1.1.255  Mask:255.255.255.0
           UP BROADCAST MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

[root@lanforge-33-46 local]# ifconfig eth2 down;ifconfig eth2 up
[root@lanforge-33-46 local]# ip route show table 76



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

