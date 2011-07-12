From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: Bridging behavior apparently changed around the Fedora 14 time
Date: Mon, 11 Jul 2011 22:06:55 -0500
Message-ID: <925A849792280C4E80C5461017A4B8A2A040F9@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com>	<20110711130729.607d461e@nehalam.ftrdhcpuser.net>	<925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com>	<20110711134938.5178797c@nehalam.ftrdhcpuser.net>	<925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com> <20110711141028.19f0de46@nehalam.ftrdhcpuser.net> <4E1B6826.8090101@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Lynn Hanson" <LynnHanson@eaganhills.org>,
	"Joe Whalen" <JoeWhalen@eaganhills.org>
To: "Ben Greear" <greearb@candelatech.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:26556 "EHLO
	mail.InfraSupportEtc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021Ab1GLDG5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 23:06:57 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You can read /sys/class/net/dev/eth0/flags and
> see if flag 0x100 is set..if so, it's promisc.

Hmmm...

According to this, sure enough, all the relevant devices **are** set to
PROMISC, even though ip link show doesn't say so.

[root@ehac-fw2011 firewall-scripts]# more /sys/class/net/eth0/flags
0x1103
[root@ehac-fw2011 firewall-scripts]# more /sys/class/net/eth1/flags
0x1103
[root@ehac-fw2011 firewall-scripts]# more /sys/class/net/br0/flags
0x1103
[root@ehac-fw2011 firewall-scripts]#
[root@ehac-fw2011 firewall-scripts]#
[root@ehac-fw2011 firewall-scripts]# # eth2 is not part of the br0
bridge.
[root@ehac-fw2011 firewall-scripts]# more /sys/class/net/eth2/flags
0x1003
[root@ehac-fw2011 firewall-scripts]#

So the plot thickens - although I set br0 to PROMISC mode by hand here.

Gathering similar data from an older and larger bridged site, this one
running Fedora 9.  Here I did not set br0 to PROMISC by hand, but it's
set that way anyway. 

[root@lme-fw2 ~]#
[root@lme-fw2 ~]# brctl showmacs br0
port no mac addr                is local?       ageing timer
  2     00:00:aa:a9:c3:91       no                18.06
  2     00:00:aa:ab:25:5b       no               267.93
  2     00:01:6c:68:9b:fc       no                91.39
  2     00:01:6c:68:9c:15       no                19.81
  2     00:09:6b:83:30:fc       no                48.57
  2     00:0d:60:2b:cd:6b       no                62.93
  2     00:0d:60:70:bc:87       no               104.11
  2     00:0e:0c:ee:5f:f0       no                 1.27
  1     00:11:21:bd:7f:80       no                 0.03
  2     00:11:25:6b:3a:8b       no                39.18
  2     00:12:79:7f:f5:2f       no                 8.66
  2     00:14:38:de:4c:7a       no                 9.76
  2     00:15:b7:22:43:ff       no                 1.30
  2     00:15:b7:28:eb:fc       no               232.10
  2     00:15:b7:bf:bd:fc       no                52.28
  2     00:15:b7:c1:d8:fd       no               118.31
  2     00:15:b7:db:b0:fc       no               275.73
  2     00:15:f2:ea:93:c4       no                15.83
  2     00:16:17:e0:24:72       no               158.90
  2     00:17:31:46:e1:12       no                 7.74
  2     00:17:c5:14:e6:58       no                12.14
  2     00:17:c5:14:e6:59       no                 0.01
  2     00:19:21:07:8e:8c       no                37.98
  2     00:19:db:a1:56:3e       no                26.43
  2     00:1b:78:22:63:0c       no                19.87
  2     00:1c:25:97:70:2e       no                 9.63
  2     00:1c:c4:8e:dd:3e       no                12.90
  2     00:1e:0b:3e:7c:41       no                44.20
  2     00:1e:0b:3e:7f:11       no                 0.20
  2     00:1e:4f:b9:2f:00       no                14.06
  2     00:1f:29:14:f0:53       no                14.12
  2     00:21:5e:89:92:d0       no                15.30
  2     00:21:5e:b3:03:c1       no                 0.17
  2     00:22:68:59:b1:bf       no                36.45
  2     00:22:68:59:f5:a8       no                23.25
  2     00:22:68:59:f7:0a       no               106.53
  2     00:22:68:59:fe:24       no                 2.63
  2     00:24:01:07:15:a6       no                 2.12
  2     00:26:5a:7b:0f:e3       no               161.61
  2     00:30:80:d3:cd:20       no                 1.54
  2     00:40:af:81:7a:1b       no                15.81
  2     00:80:64:5e:5b:1b       no                66.77
  2     00:80:64:5e:5b:67       no                 1.67
  2     00:80:64:62:64:e8       no                 2.12
  2     00:90:dc:02:b5:9b       no                70.30
  2     00:90:dc:a4:0f:3b       no                 4.07
  2     00:90:dc:a4:0f:3c       no                22.30
  2     00:a0:c8:20:54:05       no                 0.23
  2     00:c0:b6:0a:da:3c       no                44.77
  2     00:c0:b6:0a:da:3d       no                44.77
  2     10:78:d2:a8:e6:84       no                34.50
  3     12:34:56:00:10:01       yes                0.00
  2     12:34:56:00:10:11       no                 1.02
  2     12:34:56:00:30:05       yes                0.00
  1     12:34:56:00:32:51       no                 1.02
  1     12:34:56:24:80:50       yes                0.00
  2     40:61:86:7e:8c:93       no                10.02
  2     6c:62:6d:5a:af:09       no                58.99
  2     70:71:bc:51:8e:73       no                18.06
  2     90:fb:a6:22:0a:06       no                23.24
  2     e4:1f:13:2d:63:a8       no                 0.31
[root@lme-fw2 ~]#
[root@lme-fw2 ~]#
[root@lme-fw2 ~]# brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.123456001001       no              eth0
                                                        eth1
                                                        eth2
pan0            8000.000000000000       no
[root@lme-fw2 ~]#  more /sys/class/net/eth2/flags
0x1103
[root@lme-fw2 ~]#  more /sys/class/net/eth1/flags
0x1103
[root@lme-fw2 ~]#  more /sys/class/net/eth0/flags
0x1103
[root@lme-fw2 ~]#  more /sys/class/net/br0/flags
0x1103
[root@lme-fw2 ~]#
[root@lme-fw2 ~]#
[root@lme-fw2 ~]# ip link show dev eth2
4: eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast
qlen 1000
    link/ether 12:34:56:00:10:01 brd ff:ff:ff:ff:ff:ff
[root@lme-fw2 ~]# ip link show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
qlen 1000
    link/ether 12:34:56:00:30:05 brd ff:ff:ff:ff:ff:ff
[root@lme-fw2 ~]# ip link show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
qlen 1000
    link/ether 12:34:56:24:80:50 brd ff:ff:ff:ff:ff:ff
[root@lme-fw2 ~]# ip 
[root@lme-fw2 ~]# more /proc/version
Linux version 2.6.25-14.fc9.i686 (mockbuild@) (gcc version 4.3.0
20080428 (Red H
at 4.3.0-8) (GCC) ) #1 SMP Thu May 1 06:28:41 EDT 2008
[link show dev br0
8: br0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc noqueue
    link/ether 12:34:56:00:10:01 brd ff:ff:ff:ff:ff:ff
[root@lme-fw2 ~]#

