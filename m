From: Ovidiu Mara <ovidiu.mara@epfl.ch>
Subject: Order of interfaces in output of ip link
Date: Tue, 02 Sep 2014 16:27:42 +0200
Message-ID: <19313218.dxlnVqzEMb@hp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.epfl.ch ([128.178.224.219]:56288 "EHLO smtp4.epfl.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750963AbaIBOe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 10:34:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

The ip command shows the interfaces on this machine in an unnatural order (eth0 followed by eth2 then eth1).

For example:

ip -o link         
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default \    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether 2c:59:e5:9a:4c:a4 brd ff:ff:ff:ff:ff:ff
3: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether ac:16:2d:98:9e:d8 brd ff:ff:ff:ff:ff:ff
4: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DEFAULT group default qlen 1000\    link/ether 2c:59:e5:9a:4c:a5 brd ff:ff:ff:ff:ff:ff
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether ac:16:2d:98:9e:d9 brd ff:ff:ff:ff:ff:ff
6: eth4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether ac:16:2d:98:9e:da brd ff:ff:ff:ff:ff:ff
7: eth5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether ac:16:2d:98:9e:db brd ff:ff:ff:ff:ff:ff
8: eth6: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000\    link/ether a0:36:9f:26:b3:10 brd ff:ff:ff:ff:ff:ff
9: eth7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether a0:36:9f:26:b3:12 brd ff:ff:ff:ff:ff:ff

eth0 and eth1 are two ports on the same network card, so I would expect them to be shown together, as they are numbered. According to the documentation I found here ( http://www.policyrouting.org/iproute2.doc.html#ss9.1.1 ): "The number followed by a colon is the interface index or ifindex. This number uniquely identifies the interface. If you look at the output from cat /proc/net/dev you will see that the network devices are listed in the same order as the numbering you see here."

However in /proc/net/dev they are shown in the natural order:

cat /proc/net/dev
Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
  eth0: 1000705102 6535806    0 8946    0     0          0   2861813  5252988   39289    0    0    0     0       0          0
  eth1:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0          0
  eth2: 104506836  257406    0    0    0     0          0         0      648       8    0    0    0     0       0          0
  eth3: 104506430  257405    0    0    0     0          0         0      648       8    0    0    0     0       0          0
  eth4: 104506430  257405    0    0    0     0          0         0      648       8    0    0    0     0       0          0
  eth5: 104505618  257403    0    0    0     0          0         0      648       8    0    0    0     0       0          0
  eth6:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0          0
  eth7: 396628856508 364243051    0    0    0     0          0         0 398063721522 365214422    0    0    0     0       0          0
    lo:     178       2    0    0    0     0          0         0      178       2    0    0    0     0       0          0

I'm using iproute2-3.11.0.

Could you please tell me if there is any workaround for this?

Thanks,
Ovidiu

PS Please CC me in replies.
