From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: TG3 driver failure on HP 16-way
Date: Mon, 20 Dec 2004 14:55:33 +1100
Message-ID: <16838.19765.583047.997351@berry.gelato.unsw.EDU.AU>
Reply-To: peterc@gelato.unsw.edu.au
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
	I'm  seeing interesting behaviour with the TG3 driver on an HP
16-way IA64 box.  The driver detects the BCM5701 NICs, but then cannot
bring them up.  (I'm using the current head of tree linux 2.6.10-rc3
or thereabouts; driver version 3.14)

lspci says:
 Ethernet controller: Broadcom Corporation NetXtreme BCM5701 Gigabit Ethernet (rev 15)


I see:
# modprobe tg3
tg3.c:v3.14 (November 15, 2004)
ACPI: PCI interrupt 0000:00:01.0[A] -> GSI 28 (level, low) -> IRQ 59
eth0: Tigon3 [partno(A7109-60001) rev 0105 PHY(5701)] (PCI:33MHz:64-bit) 10/100/1000BaseT Ethernet 00:0e:7f:ed:91:8f
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[0] 
ACPI: PCI interrupt 0001:00:01.0[A] -> GSI 132 (level, low) -> IRQ 60
eth1: Tigon3 [partno(A7109-60001) rev 0105 PHY(5701)] (PCI:33MHz:64-bit) 10/100/1000BaseT Ethernet 00:0e:7f:ed:71:b9
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[0] 
# ifup eth0
# ethtool eth0
Settings for eth0:
        Supported ports: [ MII ]
        Supported link modes:   10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Advertised auto-negotiation: Yes
        Speed: Unknown! (65535)
        Duplex: Unknown! (255)
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Current message level: 0x000000ff (255)
        Link detected: no
# ethtool -s eth0 autoneg off speed 100 duplex full
# ethtool eth0
Settings for eth0:
        Supported ports: [ MII ]
        Supported link modes:   10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Supports auto-negotiation: Yes
        Advertised link modes:  Not reported
        Advertised auto-negotiation: No
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: off
        Supports Wake-on: g
        Wake-on: d
        Current message level: 0x000000ff (255)
        Link detected: no
# mii-tool eth0
eth0: 100 Mbit, full duplex, link ok
# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:0E:7F:ED:91:8F  
          inet addr:192.168.3.5  Bcast:192.168.3.255  Mask:255.255.255.0
          inet6 addr: fe80::20e:7fff:feed:918f/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:2
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Interrupt:59 


The card is plugged into a 100Mb switch.


The BCM5700 driver from broadcom also fails to autonegotiate, but
works when I use ethtool to set up the correct parameters.
