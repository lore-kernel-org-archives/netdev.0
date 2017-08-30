From: Tim Harvey <tharvey@gateworks.com>
Subject: DSA mv88e6xxx RX frame errors and TCP/IP RX failure
Date: Wed, 30 Aug 2017 12:53:56 -0700
Message-ID: <CAJ+vNU0VzgDkH-ksHgaA0cn3nbCOfcUs_BU90v6xw_QappssgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings,

I'm seeing RX frame errors when using the mv88e6xxx DSA driver on
4.13-rc7. The board I'm using is a GW5904 [1] which has an IMX6 FEC
MAC (eth0) connected via RGMII to a MV88E6176 with its downstream
P0/P1/P2/P3 to front panel RJ45's (lan1-lan4).

What I see is the following:
- bring up eth0/lan1
- DHCP ipv4 on lan1
- iperf client to server on network connected to lan1 shows ~150mbps
TX without any errors/overruns/frame but 10 or so dropped
- iperf server with a 100mbps TCP client test shows
- iperf server will hang when connected to from iperf client on lan1
network and I see frame errors from ifconfig:

root@xenial:/# ifconfig lan1
lan1      Link encap:Ethernet  HWaddr 00:D0:12:41:F3:E7
          inet addr:172.24.22.125  Bcast:172.24.255.255  Mask:255.240.0.0
          inet6 addr: fe80::2d0:12ff:fe41:f3e7/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:148 errors:0 dropped:30 overruns:0 frame:0
          TX packets:15 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:8780 (8.5 KiB)  TX bytes:1762 (1.7 KiB)

root@xenial:/# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:D0:12:41:F3:E7
          inet6 addr: fe80::2d0:12ff:fe41:f3e7/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:386 errors:19 dropped:39 overruns:0 frame:57
          TX packets:24 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:39484 (38.5 KiB)  TX bytes:2880 (2.8 KiB)

It doesn't appear that this is a new issue as it exists on also on
older kernels.

Note that the IMX6 has an errata (ERR004512) [2] that limits the
theoretical max performance of the FEC to 470mbps (total TX+RX) and if
the TX and RK peak datarate is higher than ~400mps there is a risk of
ENET RX FIFO overrun but I don't think this is the issue here. It
would be the cause of the relatively low throughput of ~150 TX though
I would assume.

Best Regards,

Tim

[1] - https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm/boot/dts/imx6qdl-gw5904.dtsi
[2] - http://cache.nxp.com/docs/en/errata/IMX6DQCE.pdf - ERR004512
