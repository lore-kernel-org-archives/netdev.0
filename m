From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: getting VF link info seems to be broken in 3.9-rc8
Date: Wed, 24 Apr 2013 19:07:54 +0300
Message-ID: <5178035A.5090306@mellanox.com>
References: <5177D946.9080704@mellanox.com> <20130424083825.00004f94@unknown> <20130424090133.00005ca6@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Rony Efraim <ronye@mellanox.com>, <Sibai.li@intel.com>
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:49991 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756200Ab3DXQIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 12:08:02 -0400
In-Reply-To: <20130424090133.00005ca6@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/04/2013 19:01, Greg Rose wrote:
>  From our validation engineer Sibai Li (added to response):
>
> I tested 3.9.0-rc8, I have no problem to list vf info. But I didn=E2=80=
=99t run
> in FPP mode. But I don't think it's a matter. From the info he gave
> here, I didn=E2=80=99t see he loaded the vf driver when he ran in ker=
nel
> 3.9.0-rc8, but he did load the driver in 3.8.8.
>
> ---------
>
> I'd add that having the VF driver loaded shouldn't make any differenc=
e.

I have tested again (this  time the server is booted on net-next which=20
is 3.9-rc8+) and the VF driver IS loaded, but stillno sign for the VF i=
n=20
the ip link show output

# lspci | grep Eth
01:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network=20
Connection (rev 01)
01:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network=20
Connection (rev 01)
05:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit=20
SFI/SFP+ Network Connection (rev 01)
05:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit=20
SFI/SFP+ Network Connection (rev 01)
05:10.0 Ethernet controller: Intel Corporation 82599 Ethernet Controlle=
r=20
Virtual Function (rev 01)
05:10.1 Ethernet controller: Intel Corporation 82599 Ethernet Controlle=
r=20
Virtual Function (rev 01)

# lsmod | grep ixgbe
ixgbevf                34062  0
ixgbe                 150783  0
hwmon                   1839  1 ixgbe
mdio                    4263  1 ixgbe
ptp                     8400  2 ixgbe,igb
dca                     6822  3 ixgbe,igb,ioatdma

# /mnt/upstream/tools/iproute2/ip/ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mod=
e=20
DEFAULT
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master br0=
=20
state UP mode DEFAULT qlen 1000
     link/ether 00:25:90:36:9c:ec brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT qlen 1000
     link/ether 00:25:90:36:9c:ed brd ff:ff:ff:ff:ff:ff
10: eth11: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT qlen 1000
     link/ether 00:1b:21:55:1d:00 brd ff:ff:ff:ff:ff:ff
11: eth10: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT qlen 1000
     link/ether 00:1b:21:55:1d:01 brd ff:ff:ff:ff:ff:ff
12: eth22: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT qlen 1000
     link/ether 3a:20:bd:09:ce:9d brd ff:ff:ff:ff:ff:ff
13: eth20: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT qlen 1000
     link/ether 52:42:81:a7:6e:da brd ff:ff:ff:ff:ff:ff
14: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state=
=20
UP mode DEFAULT
     link/ether 00:25:90:36:9c:ec brd ff:ff:ff:ff:ff:ff
17: eth16: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state=20
DOWN mode DEFAULT qlen 1000
     link/ether 00:02:c9:e6:01:11 brd ff:ff:ff:ff:ff:ff
18: eth17: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state=20
DOWN mode DEFAULT qlen 1000
     link/ether 00:02:c9:e6:01:12 brd ff:ff:ff:ff:ff:ff
19: eth18: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT qlen 1000
     link/ether 00:02:c9:e6:02:11 brd ff:ff:ff:ff:ff:ff
20: eth19: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT qlen 1000
     link/ether 00:02:c9:e6:02:12 brd ff:ff:ff:ff:ff:ff
21: eth28: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT qlen 1000
     link/ether 00:02:c9:e6:03:11 brd ff:ff:ff:ff:ff:ff
22: eth27: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT qlen 1000
     link/ether 00:02:c9:e6:03:12 brd ff:ff:ff:ff:ff:ff

# pwd

/sys/class/net

# ls -l
total 0
lrwxrwxrwx 1 root root 0 Apr 24 18:44 br0 -> ../../devices/virtual/net/=
br0
lrwxrwxrwx 1 root root 0 Apr 24 18:44 eth0 ->=20
=2E./../devices/pci0000:00/0000:00:01.0/0000:01:00.0/net/eth0
lrwxrwxrwx 1 root root 0 Apr 24 18:44 eth1 ->=20
=2E./../devices/pci0000:00/0000:00:01.0/0000:01:00.1/net/eth1
lrwxrwxrwx 1 root root 0 Apr 24 18:45 eth10 ->=20
=2E./../devices/pci0000:00/0000:00:09.0/0000:05:00.1/net/eth10
lrwxrwxrwx 1 root root 0 Apr 24 18:45 eth11 ->=20
=2E./../devices/pci0000:00/0000:00:09.0/0000:05:00.0/net/eth11
lrwxrwxrwx 1 root root 0 Apr 24 18:51 eth16 ->=20
=2E./../devices/pci0000:00/0000:00:07.0/0000:04:00.0/net/eth16
lrwxrwxrwx 1 root root 0 Apr 24 18:51 eth17 ->=20
=2E./../devices/pci0000:00/0000:00:07.0/0000:04:00.0/net/eth17
lrwxrwxrwx 1 root root 0 Apr 24 18:51 eth18 ->=20
=2E./../devices/pci0000:00/0000:00:07.0/0000:04:00.1/net/eth18
lrwxrwxrwx 1 root root 0 Apr 24 18:51 eth19 ->=20
=2E./../devices/pci0000:00/0000:00:07.0/0000:04:00.1/net/eth19
lrwxrwxrwx 1 root root 0 Apr 24 18:44 eth20 ->=20
=2E./../devices/pci0000:00/0000:00:09.0/0000:05:10.1/net/eth20
lrwxrwxrwx 1 root root 0 Apr 24 18:44 eth22 ->=20
=2E./../devices/pci0000:00/0000:00:09.0/0000:05:10.0/net/eth22
lrwxrwxrwx 1 root root 0 Apr 24 18:51 eth27 ->=20
=2E./../devices/pci0000:00/0000:00:07.0/0000:04:00.2/net/eth27
lrwxrwxrwx 1 root root 0 Apr 24 18:51 eth28 ->=20
=2E./../devices/pci0000:00/0000:00:07.0/0000:04:00.2/net/eth28
lrwxrwxrwx 1 root root 0 Apr 24 18:44 lo -> ../../devices/virtual/net/l=
o
