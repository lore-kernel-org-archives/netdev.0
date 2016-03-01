From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [RFC bonding]: whether need to correct the slave mac address
Date: Tue, 1 Mar 2016 18:52:59 +0800
Message-ID: <56D5748B.5050904@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@gmail.com>, <netdev@vger.kernel.org>
To: <j.vosburgh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:21427 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460AbcCAKxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 05:53:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay:
	I met a very strange problem, and still not sure about the reason, the step is:


[2016-02-23 02:01:01] current oper: 1
[2016-02-23 02:01:01] lastbasenicname: 
[2016-02-23 02:01:01] lastbondnicname: 
[2016-02-23 02:01:01] g_basenicname: bond0
[2016-02-23 02:01:01] g_bondnicname: eth0;eth1
[2016-02-23 02:01:01] lastbondnicnum: 
[2016-02-23 02:01:01] bondnicnum: 2
[2016-02-23 02:01:01] ifconfig -a | grep eth0
[2016-02-23 02:01:01] ret  eth0:
[2016-02-23 02:01:01] ifconfig -a | grep eth1
[2016-02-23 02:01:01] ret  eth1:
[2016-02-23 02:01:01] modprobe bonding  mode=1 miimon=100 fail_over_mac=2
[2016-02-23 02:01:01] ip link set bond0 name bond0; Ret=0
[2016-02-23 02:01:01] ifconfig bond0 up; Ret=0
[2016-02-23 02:01:01] ifenslave bond0 eth0; Ret=0
[2016-02-23 02:01:01] ifenslave bond0 eth1; Ret=0
[2016-02-23 02:01:01] ifconfig bond0 up; Ret=0
[2016-02-23 02:01:01] ifconfig eth0 up; Ret=0
[2016-02-23 02:01:01] ifconfig eth1 up; Ret=0
[2016-02-23 02:01:01] creat bond successfully

This commands will run every time when the vm is start, but for once the bonding could not work, then I check the
bonding, it looks very strange:

localhost:/home/lgnusr # cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup) (fail_over_mac follow)
Primary Slave: None
Currently Active Slave: eth0
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth0
MII Status: up
Speed: 10000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: fa:16:3e:c2:92:91
Slave queue ID: 0

Slave Interface: eth1
MII Status: down
Speed: 10000 Mbps
Duplex: full
Link Failure Count: 1
Permanent HW addr: fa:16:3e:bc:97:b8
Slave queue ID: 0

bond0:4:1: flags=5187<UP,BROADCAST,RUNNING,MASTER,MULTICAST> mtu 1500
inet 172.17.0.17 netmask 255.255.0.0 broadcast 172.17.255.255
ether fa:16:3e:c2:92:91 txqueuelen 1000 (Ethernet)

eth0: flags=6211<UP,BROADCAST,RUNNING,SLAVE,MULTICAST> mtu 1500
ether fa:16:3e:bc:97:b8 txqueuelen 1000 (Ethernet)
RX packets 37663 bytes 14358982 (13.6 MiB)
RX errors 0 dropped 28299 overruns 0 frame 0
TX packets 7122 bytes 2023100 (1.9 MiB)
TX errors 0 dropped 0 overruns 0 carrier 0 collisions 0

eth2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST> mtu 1500
inet6 fe80::f816:3eff:fe67:fae prefixlen 64 scopeid 0x20<link>
ether fa:16:3e:67:0f:ae txqueuelen 1000 (Ethernet)
RX packets 1038338 bytes 1375751467 (1.2 GiB)
RX errors 0 dropped 0 overruns 0 frame 0
TX packets 324325 bytes 76088291 (72.5 MiB)
TX errors 0 dropped 0 overruns 0 carrier 0 collisions 0

localhost:/home/lgnusr # ifconfig eth1 
eth1: flags=6146<BROADCAST,SLAVE,MULTICAST> mtu 1500
ether fa:16:3e:bc:97:b8 txqueuelen 1000 (Ethernet)
RX packets 28300 bytes 12305006 (11.7 MiB)
RX errors 0 dropped 0 overruns 0 frame 0
TX packets 67310 bytes 25106280 (23.9 MiB)
TX errors 0 dropped 0 overruns 0 carrier 0 collisions 0

It looks that the bond0 use the eth1 as the active slave, but they have different mac address, I check the logic for fail_over_mac=2,
but still can not find the reason, can you give me some suggestion? the kernel version is 3.10.98.

Should I need to make a patch to check the active slave mac in the mii monitor and correct it?
