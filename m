From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] Intel Wired LAN Driver Updates
Date: Fri, 24 Feb 2012 02:12:53 -0800
Message-ID: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34282 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670Ab2BXKNN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series contains most of Ben Greear's low-level
Ethernet debugging features patch series.  Problems were found
with the e100 and one of the e1000 patches in the series, so they
have been dropped and will be pushed later once the problems get
ironed out.  There are 4 additional patches added to this pull
request which do the following:

e1000e - cosmetic changes
e1000 - cleanup e1000_dump and e1000_config_dsp_after_link_change
        functions

Here is the patch summary for Ben's low-level Ethernet debugging
patches:

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

The following are changes since commit 7c3a95a15ad2a5278498a72df0463131048926a3:
  davinci_mdio: Correct bitmask for clock divider value
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Ben Greear (12):
  net: Support RXFCS feature flag.
  e1000e: Support RXFCS feature flag.
  net: Add framework to allow sending packets with customized CRC.
  e1000e: Support sending custom Ethernet CRC.
  net: Support RX-ALL feature flag.
  e1000e: Support RXALL feature flag.
  e1000: Support sending custom Ethernet CRC.
  e1000: Support RX-FCS flag.
  8139too: Support RX-ALL logic.
  8139too: Support RX-FCS flag.
  r8169: Support RX-ALL flag.
  r8169: Support RX-FCS flag.

Bruce Allan (2):
  e1000e: cosmetic change to boolean comparisons
  e1000e: cosmetic comment changes to make lines less than 80
    characters

Joe Perches (1):
  e1000: Neaten e1000_config_dsp_after_link_change

Tushar Dave (1):
  v2 e1000: Neaten e1000_dump function

 Documentation/networking/netdev-features.txt    |   13 ++
 arch/alpha/include/asm/socket.h                 |    3 +
 arch/arm/include/asm/socket.h                   |    3 +
 arch/avr32/include/asm/socket.h                 |    3 +
 arch/cris/include/asm/socket.h                  |    3 +
 arch/frv/include/asm/socket.h                   |    3 +
 arch/h8300/include/asm/socket.h                 |    3 +
 arch/ia64/include/asm/socket.h                  |    3 +
 arch/m32r/include/asm/socket.h                  |    3 +
 arch/m68k/include/asm/socket.h                  |    3 +
 arch/mips/include/asm/socket.h                  |    3 +
 arch/mn10300/include/asm/socket.h               |    3 +
 arch/parisc/include/asm/socket.h                |    4 +
 arch/powerpc/include/asm/socket.h               |    3 +
 arch/s390/include/asm/socket.h                  |    3 +
 arch/sparc/include/asm/socket.h                 |    4 +
 arch/xtensa/include/asm/socket.h                |    3 +
 drivers/net/ethernet/intel/e1000/e1000_hw.c     |  156 +++++++++++------------
 drivers/net/ethernet/intel/e1000/e1000_main.c   |  147 +++++++++++-----------
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |    8 +-
 drivers/net/ethernet/intel/e1000e/defines.h     |    1 +
 drivers/net/ethernet/intel/e1000e/e1000.h       |    1 +
 drivers/net/ethernet/intel/e1000e/netdev.c      |   80 ++++++++++--
 drivers/net/ethernet/intel/e1000e/param.c       |    5 +-
 drivers/net/ethernet/realtek/8139too.c          |   58 ++++++++-
 drivers/net/ethernet/realtek/r8169.c            |   55 ++++++--
 include/asm-generic/socket.h                    |    4 +
 include/linux/if.h                              |    2 +
 include/linux/netdev_features.h                 |    4 +
 include/linux/netdevice.h                       |    8 +-
 include/linux/skbuff.h                          |    4 +-
 include/net/sock.h                              |    4 +
 net/core/ethtool.c                              |    2 +
 net/core/skbuff.c                               |    1 +
 net/core/sock.c                                 |    5 +
 net/packet/af_packet.c                          |   32 ++++-
 36 files changed, 449 insertions(+), 191 deletions(-)

-- 
1.7.7.6
