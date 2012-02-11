From: greearb@candelatech.com
Subject: [PATCH v3 00/16] Low-level Ethernet debugging features.
Date: Fri, 10 Feb 2012 17:04:18 -0800
Message-ID: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55822 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491Ab2BKBEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 20:04:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This patch series enables some features designed to make
testing ethernet devices and debugging link-level errors
easier.

First, support is added for receiving the Ethernet FCS.  This
allows stock wireshark to show you the actual Ethernet FCS.

Second, allow sending packets with user-specified Ethernet
FCS.  The user can specify bad FCS in order to test network
equipments' handling of FCS errors, or, in strange cases,
users might want to implement their own FCS scheme.

Third, allow configuring a NIC to receive errored (and possibly
other types of packets not normally passed up the stack).  This
allows sniffers to show packets with bad FCS, for instance.

Changes from V2:

*  Fix e100 to properly not count the FCS in the rx-bytes counter.

*  Add rx-fcs and rx-all support for e1000 driver (tested with bad FCS pkts).

*  Add realtek 8139too and r8169 support for rx-all and rx-fcs features.
   It appears these drivers cannot do per-packet FCS tx config, so I
   have no plans to implement the 'send custom fcs' logic in them.

Ben Greear (16):
  net: Support RXFCS feature flag.
  e100: Support RXFCS feature flag.
  e1000e:  Support RXFCS feature flag.
  net: Add framework to allow sending packets with customized CRC.
  e100: Support sending custom Ethernet CRC
  e1000e:  Support sending custom Ethernet CRC.
  net:  Support RX-ALL feature flag.
  e1000e:  Support RXALL feature flag.
  e100:  Support RXALL feature flag.
  e1000: Support sending custom Ethernet CRC.
  e1000:  Support RX-ALL flag.
  e1000:  Support RX-FCS flag.
  8139too:  Support RX-ALL logic.
  8139too:  Support RX-FCS flag.
  r8169:  Support RX-ALL flag.
  r8169:  Support RX-FCS flag.

 Documentation/networking/netdev-features.txt  |   13 ++++
 arch/alpha/include/asm/socket.h               |    3 +
 arch/arm/include/asm/socket.h                 |    3 +
 arch/avr32/include/asm/socket.h               |    3 +
 arch/cris/include/asm/socket.h                |    3 +
 arch/frv/include/asm/socket.h                 |    3 +
 arch/h8300/include/asm/socket.h               |    3 +
 arch/ia64/include/asm/socket.h                |    3 +
 arch/m32r/include/asm/socket.h                |    3 +
 arch/m68k/include/asm/socket.h                |    3 +
 arch/mips/include/asm/socket.h                |    3 +
 arch/mn10300/include/asm/socket.h             |    3 +
 arch/parisc/include/asm/socket.h              |    4 +
 arch/powerpc/include/asm/socket.h             |    3 +
 arch/s390/include/asm/socket.h                |    3 +
 arch/sparc/include/asm/socket.h               |    4 +
 arch/xtensa/include/asm/socket.h              |    3 +
 drivers/net/ethernet/intel/e100.c             |   68 +++++++++++++++++++--
 drivers/net/ethernet/intel/e1000/e1000_main.c |   59 +++++++++++++++----
 drivers/net/ethernet/intel/e1000e/defines.h   |    1 +
 drivers/net/ethernet/intel/e1000e/e1000.h     |    1 +
 drivers/net/ethernet/intel/e1000e/netdev.c    |   80 +++++++++++++++++++++---
 drivers/net/ethernet/intel/e1000e/param.c     |    5 +-
 drivers/net/ethernet/realtek/8139too.c        |   58 ++++++++++++++++++-
 drivers/net/ethernet/realtek/r8169.c          |   55 +++++++++++++----
 include/asm-generic/socket.h                  |    4 +
 include/linux/if.h                            |    2 +
 include/linux/netdev_features.h               |    4 +
 include/linux/netdevice.h                     |    8 ++-
 include/linux/skbuff.h                        |    4 +-
 include/net/sock.h                            |    4 +
 net/core/ethtool.c                            |    2 +
 net/core/skbuff.c                             |    1 +
 net/core/sock.c                               |    4 +
 net/packet/af_packet.c                        |   32 +++++++++-
 35 files changed, 408 insertions(+), 47 deletions(-)

-- 
1.7.3.4
