From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: e1000e, 3.4.1, , jumbo frames are not working
Date: Fri, 08 Jun 2012 17:59:01 +0300
Message-ID: <87ed034d58606650514bdd3b88b0b002@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <jeffrey.t.kirsher@intel.com>, <rkagan@parallels.com>,
	<stable@vger.kernel.org>, <jesse.brandeburg@intel.com>,
	<bruce.w.allan@intel.com>, <carolyn.wyborny@intel.com>,
	<donald.c.skidmore@intel.com>, <gregory.v.rose@intel.com>,
	<peter.p.waskiewicz.jr@intel.com>, <alexander.h.duyck@intel.com>,
	<john.ronciak@intel.com>, <dnelson@redhat.com>,
	<e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just tried to enable larger mtu on interface, and failed, even i try to 
disable both of mentioned in dmesg offloads.

05:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit 
Ethernet Controller (Copper) (rev 01)
05:00.1 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit 
Ethernet Controller (Copper) (rev 01)

L2TP ~ # ethtool -i eth0
driver: e1000e
version: 1.9.5-k
firmware-version: 1.0-0
bus-info: 0000:05:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes

Here is what i did:
ifconfig eth1 mtu 2000
got dmesg:
[ 9160.679354] e1000e 0000:05:00.0: eth0: Jumbo frames cannot be 
enabled when both receive checksum offload and receive hashing are 
enabled.  Disable one of the receive offload features before enabling 
jumbos.

ethtool -K eth1 rxhash off
dmesg:
[ 9194.208856] e1000e 0000:05:00.1: eth1: Reset adapter
[ 9197.295425] e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow 
Control: None

Lost connectivity for few seconds, then again i tried to:
ifconfig eth1 mtu 2000

dmesg:
[ 9207.797616] e1000e 0000:05:00.0: eth0: Jumbo frames cannot be 
enabled when both receive checksum offload and receive hashing are 
enabled.  Disable one of the receive offload features before enabling 
jumbos.

ethtool -K eth1 rx off
[ 9222.398034] e1000e 0000:05:00.1: eth1: Reset adapter
[ 9225.497550] e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow 
Control: None

Again, tried: ifconfig eth1 mtu 2000
dmesg:
[ 9254.795445] e1000e 0000:05:00.0: eth0: Jumbo frames cannot be 
enabled when both receive checksum offload and receive hashing are 
enabled.  Disable one of the receive offload features before enabling 
jumbos.

L2TP ~ # ethtool -k eth1
Offload parameters for eth1:
rx-checksumming: off
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: off

L2TP ~ # ethtool -d eth1
MAC Registers
-------------
0x00000: CTRL (Device control register)  0x40144241
       Endian mode (buffers):             little
       Link reset:                        normal
       Set link up:                       1
       Invert Loss-Of-Signal:             no
       Receive flow control:              disabled
       Transmit flow control:             disabled
       VLAN mode:                         enabled
       Auto speed detect:                 disabled
       Speed select:                      1000Mb/s
       Force speed:                       no
       Force duplex:                      no
0x00008: STATUS (Device status register) 0x02080787
       Duplex:                            full
       Link up:                           link config
       TBI mode:                          disabled
       Link speed:                        1000Mb/s
       Bus type:                          PCI Express
       Port number:                       1
0x00100: RCTL (Receive control register) 0x04008002
       Receiver:                          enabled
       Store bad packets:                 disabled
       Unicast promiscuous:               disabled
       Multicast promiscuous:             disabled
       Long packet:                       disabled
       Descriptor minimum threshold size: 1/2
       Broadcast accept mode:             accept
       VLAN filter:                       disabled
       Canonical form indicator:          disabled
       Discard pause frames:              filtered
       Pass MAC control frames:           don't pass
       Receive buffer size:               2048
0x02808: RDLEN (Receive desc length)     0x00001000
0x02810: RDH   (Receive desc head)       0x00000046
0x02818: RDT   (Receive desc tail)       0x00000040
0x02820: RDTR  (Receive delay timer)     0x00000020
0x00400: TCTL (Transmit ctrl register)   0x3103F0FA
       Transmitter:                       enabled
       Pad short packets:                 enabled
       Software XOFF Transmission:        disabled
       Re-transmit on late collision:     enabled
0x03808: TDLEN (Transmit desc length)    0x00001000
0x03810: TDH   (Transmit desc head)      0x00000098
0x03818: TDT   (Transmit desc tail)      0x00000099
0x03820: TIDV  (Transmit delay timer)    0x00000008
PHY type:                                unknown


---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
