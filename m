From: Arjun Pandey <apandepublic@gmail.com>
Subject: 802.3 ad bonding mode min-links doesn't work correctly once slave
 port link status is up again
Date: Tue, 27 Oct 2015 17:47:08 +0530
Message-ID: <CAKpWUYnGO_YhXTQ5ekNTONZhaveDHScs2OLy-4NiDOTa6ahDsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:34163 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932130AbbJ0MRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 08:17:08 -0400
Received: by igpw7 with SMTP id w7so4407955igp.1
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 05:17:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I have configured a bond with 2 slave bond ports in 802.3 ad mode.
I have also set min-links=2 and miimon=100


root@foo bonding]# cat /proc/net/bonding/bond
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer2 (0)
MII Status: down
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

802.3ad info
LACP rate: fast
Min links: 2
Aggregator selection policy (ad_select): stable
Active Aggregator Info:
Aggregator ID: 2
Number of ports: 1
Actor Key: 17
Partner Key: 1
Partner Mac Address: 00:00:00:00:00:00

Slave Interface: eth1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 7
Permanent HW addr: 08:00:27:0a:cd:2c
Aggregator ID: 1
Slave queue ID: 0

Slave Interface: eth2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 4
Permanent HW addr: 08:00:27:b0:4d:7e
Aggregator ID: 2
Slave queue ID: 0

I tried the following steps :
1. Bring up bond with slaves as eth1 and eth2
2. Bring down eth1 down via ip link set down eth1
3. Check bond link status which now shows up as down
4. Restore eth1 link status up.
5. Bond link status is still set as down.

I can't get bond link status up unless i make min-links 0/1 and bring
bond status manually up via ip link set bond down and ip link set bond
up
[root@foo /]# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    link/ether 08:00:27:f8:38:ad brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc
pfifo_fast master bond state UP qlen 1000
    link/ether 08:00:27:0a:cd:2c brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc
pfifo_fast master bond state UP qlen 1000
    link/ether 08:00:27:0a:cd:2c brd ff:ff:ff:ff:ff:ff
23: bond: <NO-CARRIER,BROADCAST,MULTICAST,MASTER,UP> mtu 1500 qdisc
noqueue state DOWN
    link/ether 08:00:27:0a:cd:2c brd ff:ff:ff:ff:ff:ff

Am i missing something ?


This is on Centos 6.5 and kernel 3.10.27.1

Regards
Arjun
