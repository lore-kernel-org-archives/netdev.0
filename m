From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sun, 25 May 2008 23:08:32 -0700 (PDT)
Message-ID: <20080525.230832.193722426.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753744AbYEZGIu@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix netlink attribute validation, from Thomas Graf.

2) Make the VLAN hw device attribute inhertance easier for
   drivers to use, and be able to handle future features
   more cleanly.  From Patrick McHardy.

3) Merge in wired driver bug fixes from Jeff Garzik and co.

Please pull, thanks a lot!

The following changes since commit 071f92d05967a0c8422f1c8587ce0b4d90a8=
b447:
  Rami Rosen (1):
        net: The world is not perfect patch.

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (1):
      make myri10ge_get_firmware_capabilities() static

Andrew Morton (4):
      [netdrvr] dm9000: use delayed work to update mii phy state fix
      pcnet32: fix warning
      drivers/net/tokenring/3c359.c: squish a warning
      drivers/net/tokenring/olympic.c: fix warning

Andy Fleming (1):
      ucc_geth: Fix arguments to dma map/unmap functions

Anton Vorontsov (1):
      uli526x: add support for netpoll

Aurelien Nephtali (1):
      net/usb: add support for Apple USB Ethernet Adapter

Becky Bruce (1):
      e1000e: use resource_size_t, not unsigned long, for phys addrs

Ben Hutchings (16):
      sfc: Use mod_timer() to set expiry and add_timer() together
      sfc: Removed casts to void
      sfc: Simplified efx_rx_calc_buffer_size() using get_order()
      sfc: Removed unncesssary UL suffixes on 0 literals
      sfc: Added and removed braces to comply with kernel style
      sfc: Replaced various macros with inline functions
      sfc: Merged efx_page_offset() into efx_rx_buf_offset()
      sfc: Use resource_size_t for PCI bus address
      sfc: Correct and expand some comments
      sfc: Use DMA_BIT_MASK() instead of our own DMA mask macros
      sfc: Do not define inline macro
      sfc: Use __packed macro
      sfc: Change type of efx_nic::nic_data to struct falcon_nic_data *
      sfc: Remove redundant casts to and from void *
      sfc: Added checks for heap allocation failure
      sfc: Remove sub-minor component from driver version

Brian King (1):
      ehea: Fix use after free on reboot

David S. Miller (1):
      Merge branch 'upstream-davem' of master.kernel.org:/.../jgarzik/n=
etdev-2.6

=46rancois Romieu (1):
      au1000_eth: remove useless check

Gerrit Renker (1):
      [SC92031] Using padto turned driver into an IPv6-only interface

Huang Weiyi (1):
      Blackfin EMAC Driver: Removed duplicated include <linux/ethtool.h=
>

Ilpo J=C3=A4rvinen (2):
      hamradio/scc: add missing block braces to multi-statement if
      s2io: add missing block braces to multistatement if statement

Joe Perches (1):
      drivers/net/ehea - remove unnecessary memset after kzalloc

Julia Lawall (1):
      drivers/net/fs_enet: remove null pointer dereference

Komuro (2):
      xirc2ps_cs: re-initialize the multicast address in do_reset
      fmvj18x_cs: add NextCom NC5310 rev B support

Krzysztof Halasa (2):
      WAN: protect Cisco HDLC state changes with a spinlock.
      WAN: protect HDLC proto list while insmod/rmmod

Maciej W. Rozycki (1):
      PHYLIB: Kconfig: Fix the dependency on S390

Matteo Croce (1):
      cpmac bugfixes and enhancements

Patrick McHardy (1):
      vlan: Use bitmask of feature flags instead of seperate feature bi=
ts

Paul Gortmaker (1):
      phylib: do EXPORT_SYMBOL on get_phy_id

Pierre Ynard (1):
      rndis_host: increase delay in command response loop

Sreenivasa Honnur (3):
      S2io: Move all the transmit completions to a single msi-x (alarm)=
 vector
      S2io: Added napi support when MSIX is enabled.
      S2io: Version update for napi and MSI-X patches

Stephen Hemminger (2):
      sky2: restore vlan acceleration on reset
      sb1250: use netdev_alloc_skb

Thomas Graf (1):
      netlink: Fix nla_parse_nested_compat() to call nla_parse() direct=
ly

Tobias Diedrich (1):
      [netdrvr] forcedeth: Restore multicast settings on resume

Wang Chen (3):
      VIRTIO: Use __skb_queue_purge()
      NETFRONT: Use __skb_queue_purge()
      3C509: rx_bytes should not be increased when alloc_skb failed

 drivers/net/3c509.c                |    2 +-
 drivers/net/au1000_eth.c           |    7 +-
 drivers/net/bfin_mac.c             |    1 -
 drivers/net/cpmac.c                |  234 +++++++++++++----
 drivers/net/dm9000.c               |    2 +-
 drivers/net/e1000e/netdev.c        |    4 +-
 drivers/net/ehea/ehea_main.c       |    5 +-
 drivers/net/forcedeth.c            |    1 +
 drivers/net/fs_enet/fs_enet-main.c |    2 +-
 drivers/net/hamradio/scc.c         |    3 +-
 drivers/net/myri10ge/myri10ge.c    |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c    |    4 +-
 drivers/net/pcmcia/xirc2ps_cs.c    |   12 +-
 drivers/net/pcnet32.c              |    4 +-
 drivers/net/phy/Kconfig            |    2 +-
 drivers/net/phy/phy_device.c       |    1 +
 drivers/net/s2io-regs.h            |    2 +-
 drivers/net/s2io.c                 |  494 +++++++++++++++++++++-------=
--------
 drivers/net/s2io.h                 |   22 +-
 drivers/net/sb1250-mac.c           |   67 +++---
 drivers/net/sc92031.c              |    8 +-
 drivers/net/sfc/bitfield.h         |    7 +-
 drivers/net/sfc/boards.c           |    9 +-
 drivers/net/sfc/efx.c              |   84 +++----
 drivers/net/sfc/falcon.c           |   87 +++----
 drivers/net/sfc/falcon.h           |    5 +-
 drivers/net/sfc/falcon_hwdefs.h    |    4 +-
 drivers/net/sfc/falcon_io.h        |   29 ++-
 drivers/net/sfc/falcon_xmac.c      |   10 +-
 drivers/net/sfc/net_driver.h       |   44 ++--
 drivers/net/sfc/rx.c               |   48 ++--
 drivers/net/sfc/selftest.c         |   14 +-
 drivers/net/sfc/sfe4001.c          |   14 +-
 drivers/net/sfc/tenxpress.c        |    4 +-
 drivers/net/sfc/tx.c               |   11 +-
 drivers/net/sfc/workarounds.h      |    2 +-
 drivers/net/sfc/xfp_phy.c          |    4 +-
 drivers/net/sky2.c                 |   29 ++-
 drivers/net/tokenring/3c359.h      |    2 +-
 drivers/net/tokenring/olympic.h    |    2 +-
 drivers/net/tulip/uli526x.c        |   16 +-
 drivers/net/ucc_geth.c             |    9 +-
 drivers/net/usb/asix.c             |    4 +
 drivers/net/usb/rndis_host.c       |    2 +-
 drivers/net/virtio_net.c           |    3 +-
 drivers/net/wan/hdlc.c             |   19 +-
 drivers/net/wan/hdlc_cisco.c       |   82 ++++---
 drivers/net/xen-netfront.c         |    6 +-
 include/linux/netdevice.h          |    9 +-
 include/net/netlink.h              |   11 +-
 net/8021q/vlan.c                   |   10 +-
 net/8021q/vlan.h                   |    2 -
 net/8021q/vlan_dev.c               |    5 +-
 53 files changed, 867 insertions(+), 599 deletions(-)
