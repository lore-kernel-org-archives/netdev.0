From: Jeff Raubitschek <jeff@raubitschek.org>
Subject: tg3 link not detected on first interface up with mtu change
Date: Fri, 5 Mar 2004 07:10:26 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040305121026.GF14914@raubitschek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

using the tg3 (v2.8) driver on 2.4.26-pre1, with dual port NetXtreme BCM5704 (rev 03), if you configure the interfaces with the a non default mtu, link will not be detected (no gigE switch required to reproduce, 100 Mbps switch will produce the same problem)

some observations:

- if you bring the interface down and bring it up again, link will be detected.
- on some machines when bringing up both interfaces at the same time,
  one of the dual interfaces will detect link while the other will not
- if you bring up the interface with the default mtu, then immediately
  change the mtu using ifconfig, link will not be detected
- if you bring up the interface with the default mtu, then wait 2
  seconds before changing the mtu using ifconfig, link WILL be detected
- the broadcom driver bcm5700.o driver detects link correctly in this case.

Reproduce with these steps:

insmod tg3
ifconfig eth1 10.9.0.98 mtu 1000
# wait a bit and check link with: ethtool eth1 (it will be "no")

dmesg output:
tg3.c:v2.8 (February 23, 2004)
PCI: Found IRQ 5 for device 00:09.1
PCI: Sharing IRQ 5 with 00:0b.0
eth1: Tigon3 [partno(BCM95704CA40-I) rev 2003 PHY(5704)] (PCI:33MHz:32-bit) 10/100/1000BaseT Ethernet 00:10:18:06:d4:88
PCI: Found IRQ 12 for device 00:09.0
eth2: Tigon3 [partno(BCM95704CA40-I) rev 2003 PHY(5704)] (PCI:33MHz:32-bit) 10/100/1000BaseT Ethernet 00:10:18:06:d4:89

please let me know if i can provide more information, i will continue to
dig through the driver trying to understand where the timing condition
with tg3_change_mtu might be.

-jeff
