From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Fri, 25 Apr 2008 03:24:32 -0700 (PDT)
Message-ID: <20080425.032432.258306463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35702
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752353AbYDYKYd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 06:24:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


More fixes and improvements:

1) Various spots don't check the copy_*_user() return value correctly
   and pass non-zere returns back to userspace as if it were an error.
   From Tom Quetchenbach and Pavel Emelyanov.

2) tehuti driver security fix, grrr it lets any user read any chip
   register... From Jeff Garzik.

3) Fix enforcement of RFC3542 rules in ipv6 socket option processing,
   from Yoshifuji HIDEAKI.

4) Fix EEPROM ethtool dumping regression, from Mandeep Singh Baines.

5) Fix net/key/af_key.c compiler warning, from Brian Haley.

6) net/ipv6/Kconfig type fix from Michael Beasley

7) IPSEC algorithm key length signedness tweak from Eric Dumazet.

8) Several wired networking fixes from Jeff Garzik.

Please pull, thanks a lot!

The following changes since commit 9edb74cc6ccb3a893c3d40727b7003c3c16f=
85a0:
  David S. Miller (1):
        tun: Multicast handling in tun_chr_ioctl() needs proper locking=
=2E

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andrew Morton (1):
      ehea: make things static

Andy Fleming (3):
      ucc_geth: Fix sneaky merge conflict regarding bus_id
      phylib: Add support for board-level PHY fixups
      gianfar: Fix skb allocation strategy

Auke Kok (3):
      e1000e: Add interrupt moderation run-time ethtool interface
      e1000e: lower ring minimum size to 64
      igb: save and restore pcie/msi state to support EEH recovery

Ayaz Abdulla (2):
      forcedeth: new backoff implementation
      forcedeth: realtek phy crossover detection

Benjamin Herrenschmidt (1):
      ibm_newemac: Increase MDIO timeouts

Brian Haley (1):
      af_key: Fix af_key.c compiler warning

Bruce Allan (1):
      e1000e: cleanup several stats issues

Chris Snook (2):
      atlx: remove flash vendor parameter
      [netdrvr] atlx: code movement: move atl1 parameter parsing

C=C3=A9dric Augonnet (1):
      Removing dead code in drivers/net/wan/hdlc_fr.c

David Graham (1):
      e1000e: Fix HW Error on es2lan, ARP capture issue by BMC

David S. Miller (1):
      Merge branch 'upstream-davem' of master.kernel.org:/.../jgarzik/n=
etdev-2.6

Eric Dumazet (2):
      tg3: sparse cleanup
      xfrm: alg_key_len & alg_icv_len should be unsigned

=46rancois Romieu (4):
      tehuti: check register size
      korina: fix misplaced return statement
      korina: misc cleanup
      via-velocity: fix vlan receipt

Grant Grundler (1):
      [netdrvr] typhoon: typhoon_resume - remove call to start_queue

Harvey Harrison (1):
      netxen: reduce stack usage of netxen_nic_flash_print

Jeff Garzik (1):
      [netdrvr] tehuti: move ioctl perm check closer to function start

Jesse Brandeburg (1):
      e1000e: Increment version to 0.2.1

Josh Boyer (2):
      ibm_newemac: Fix section mismatch warnings
      ibm_newemac Use status property for unused/unwired EMACs

Kay Sievers (1):
      net drivers: fix platform driver hotplug/coldplug

Krzysztof Halasa (1):
      WAN: Fix confusing insmod error code for C101 too.

Mandeep Singh Baines (1):
      ethtool: EEPROM dump no longer works for tg3 and natsemi

Matheos Worku (2):
      niu: Determine the # of ports from the card's VPD data
      niu: Add support for Neptune FEM/NEM cards for C10 server blades

Michael Beasley (1):
      ipv6: Fix typo in net/ipv6/Kconfig

Pavel Emelyanov (1):
      net: Fix wrong interpretation of some copy_to_user() results.

Roel Kluin (1):
      smc911x: test after postfix decrement fails in smc911x_{reset,dro=
p_pkt}

Sreenivasa Honnur (4):
      S2io: Fix memory leak during free_tx_buffers
      S2io: Version update for memory leak fix during free_tx_buffers
      S2io: Removed receive buffer replenishment tasklet
      S2io: Removed rx_lock and put_lock

Stefan Roese (2):
      ibm_newemac: Fix problem with jumbo frame support and EMAC V4.pat=
ch
      ibm_newemac: Add support for 460EX/GT-type MAL rx-channel handlin=
g

Tom Quetchenbach (1):
      tcp: tcp_probe buffer overflow and incorrect return value

Valentine Barshak (2):
      ibm_newemac: PowerPC 440GX EMAC PHY clock workaround
      ibm_newemac: PowerPC 440EP/440GR EMAC PHY clock workaround

Wendy Xiong (2):
      ixgbe: save and restore pcie/msi state to support EEH recovery
      e1000e: save and restore pcie/msi state to support EEH recovery

YOSHIFUJI Hideaki (1):
      ipv6 RAW: Disallow IPPROTO_IPV6-level IPV6_CHECKSUM socket option=
 on ICMPv6 sockets.

 Documentation/networking/phy.txt   |   38 +++-
 drivers/net/arm/at91_ether.c       |    1 +
 drivers/net/arm/ep93xx_eth.c       |    2 +
 drivers/net/atlx/atl1.c            |  138 ++++++++++++
 drivers/net/atlx/atlx.c            |  177 ---------------
 drivers/net/ax88796.c              |    1 +
 drivers/net/bfin_mac.c             |    7 +-
 drivers/net/cpmac.c                |    2 +
 drivers/net/dm9000.c               |    1 +
 drivers/net/e1000e/82571.c         |    6 -
 drivers/net/e1000e/defines.h       |    3 +
 drivers/net/e1000e/e1000.h         |   34 +++-
 drivers/net/e1000e/es2lan.c        |  129 ++++++++---
 drivers/net/e1000e/ethtool.c       |   49 ++++-
 drivers/net/e1000e/hw.h            |   12 +-
 drivers/net/e1000e/netdev.c        |  159 ++++++++-----
 drivers/net/e1000e/phy.c           |   73 ++++---
 drivers/net/ehea/ehea_main.c       |    4 +-
 drivers/net/forcedeth.c            |  432 ++++++++++++++++++++++++++++=
+-------
 drivers/net/gianfar.c              |  104 ++++++---
 drivers/net/ibm_newemac/core.c     |   83 ++++++-
 drivers/net/ibm_newemac/core.h     |   14 +-
 drivers/net/ibm_newemac/mal.c      |   20 ++-
 drivers/net/ibm_newemac/rgmii.c    |    2 +-
 drivers/net/ibm_newemac/tah.c      |    2 +-
 drivers/net/ibm_newemac/zmii.c     |    2 +-
 drivers/net/igb/igb_main.c         |    2 +
 drivers/net/irda/ali-ircc.c        |    2 +
 drivers/net/irda/pxaficp_ir.c      |    2 +
 drivers/net/irda/sa1100_ir.c       |    2 +
 drivers/net/ixgbe/ixgbe_main.c     |    2 +
 drivers/net/jazzsonic.c            |    2 +
 drivers/net/korina.c               |   39 ++--
 drivers/net/macb.c                 |    2 +
 drivers/net/meth.c                 |    2 +
 drivers/net/mv643xx_eth.c          |    5 +-
 drivers/net/netx-eth.c             |    2 +-
 drivers/net/netxen/netxen_nic_hw.c |   15 +-
 drivers/net/niu.c                  |  371 +++++++++++++++++++++++++++-=
---
 drivers/net/niu.h                  |   12 +
 drivers/net/phy/mdio_bus.c         |    3 +
 drivers/net/phy/phy.c              |    4 +-
 drivers/net/phy/phy_device.c       |  129 ++++++++++-
 drivers/net/s2io.c                 |  128 +----------
 drivers/net/s2io.h                 |    9 -
 drivers/net/sgiseeq.c              |    4 +-
 drivers/net/smc911x.c              |    8 +-
 drivers/net/smc91x.c               |    2 +
 drivers/net/sni_82596.c            |    2 +
 drivers/net/tehuti.c               |   15 ++
 drivers/net/tg3.c                  |    2 +
 drivers/net/tsi108_eth.c           |    2 +
 drivers/net/typhoon.c              |    1 -
 drivers/net/ucc_geth.c             |    2 +-
 drivers/net/via-velocity.c         |   46 +++--
 drivers/net/wan/c101.c             |    6 +-
 drivers/net/wan/hdlc_fr.c          |    4 -
 include/linux/phy.h                |   24 ++-
 include/linux/xfrm.h               |    8 +-
 net/can/raw.c                      |    3 +-
 net/core/ethtool.c                 |    5 +
 net/dccp/probe.c                   |    2 +-
 net/ipv4/tcp_probe.c               |    9 +-
 net/ipv6/Kconfig                   |    2 +-
 net/ipv6/raw.c                     |   18 ++
 net/key/af_key.c                   |    5 +-
 net/tipc/socket.c                  |    4 +-
 67 files changed, 1673 insertions(+), 729 deletions(-)
