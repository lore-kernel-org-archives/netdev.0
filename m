From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 14 Oct 2009 15:50:39 -0700 (PDT)
Message-ID: <20091014.155039.133377829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761346AbZJNWuq@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) PHY drivers need to be linked in before the rest, otherwise built-in
   drivers won't probe properly since the PHY driver they need isn't
   ready and registered yet.

2) znet driver was taking IRQ locks around calls that sleep.

3) udp_poll() can race with recvmsg() in accessing the receive buffer
   SKB queue, fix from Eric Dumazet.

4) netlink fails to fully ininitialize a struct copied back to
   user space, fix from Jiri Pirko

5) 3c574_cs multicast handling needs spin locking, from Ken Kawasaki

6) Cisco HDLC handshaking is busted, fix from Krzysztof Halasa.

7) Wireless bug fixes via John Linville

8) netxen needs to use resource_size_t as type for resource values.
   Fix from Dhanajay Phadke

9) Pegasus driver registers erroneously for bluetooth adapters,
   fix from Chris Rankin

10) OF network drivers don't detect correctly when built modular
    because they lack MODULE_DEVICE_TABLE() entries.

11) Fix IXP 2000 driver build, from Vincent Sanders.

Please pull, thanks a lot!

The following changes since commit 80f506918fdaaca6b574ba931536a58ce015=
c7be:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alan Cox (3):
      libertas: fix build
      libertas: fix build
      ethoc: fix warning from 32bit build

Albert Herranz (1):
      b43: do not stack-allocate pio rx/tx header and tail buffers

Anton Vorontsov (1):
      net: Fix OF platform drivers coldplug/hotplug when compiled as mo=
dules

Ben Hutchings (1):
      acenic: Pass up error code from ace_load_firmware()

Bjorn Helgaas (1):
      iwlwifi: use %pM for formatted MAC addresses

Chris Rankin (1):
      net: Teach pegasus driver to ignore bluetoother adapters with cla=
shing Vendor:Product IDs

Dave Mitchell (1):
      ibm_newemac: Added 16K Tx FIFO size support for EMAC4

David S. Miller (4):
      znet: Don't claim DMA lock around free_dma() calls.
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      net: Link in PHY drivers before others.
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Dhananjay Phadke (1):
      netxen: fix pci bar mapping

Dmitry Artamonow (1):
      irda/sa1100_ir: check return value of startup hook

Eric Dumazet (3):
      net: Add patchwork URL to MAINTAINERS
      net: Fix struct sock bitfield annotation
      udp: Fix udp_poll() and ioctl()

=46elix Fietkau (1):
      mac80211: fix logic error ibss merge bssid check

Giuseppe Cavallaro (1):
      net: add support for STMicroelectronics Ethernet controllers.

Jay Sternberg (1):
      iwlwifi: incorrect method used for finding valid OTP blocks

Jiri Pirko (1):
      netlink: fix typo in initialization

Johannes Berg (5):
      mac80211: fix vlan and optimise RX
      cfg80211: fix netns error unwinding bug
      mac80211: fix ibss race
      b43: fix ieee80211_rx() context
      mac80211: document ieee80211_rx() context requirement

John Bonesio (1):
      net/fec_mpc52xx: Fix kernel panic on FEC error

Ken Kawasaki (1):
      3c574_cs: spin_lock the set_multicast_list function

Krzysztof Halasa (1):
      WAN: fix Cisco HDLC handshaking.

Larry Finger (1):
      b43: Fix PPC crash in rfkill polling on unload

Michael Buesch (2):
      b43: Don't use struct wldev after detach.
      b43: Protect sanity check against physical device removal

Randy Dunlap (1):
      net: ks8851_mll uses mii interfaces

Reinette Chatre (2):
      iwlwifi: fix compile warning
      iwlagn: fix compile warning in iwl5000_gain_computation

Roel Kluin (2):
      mac80211: fix ADM8211_SYNCTL_RFtype define
      mac80211: use kfree_skb() to free struct sk_buff pointers

Ron Mercer (7):
      qlge: Fix RSS hashing values.
      qlge: Fix frame routing issue related to bonding.
      qlge: Fix frame routing for multicast frames.
      qlge: Fix RX multicast filter settings.
      qlge: Fix chip reset process.
      qlge: Restore rx mode after internal reset.
      qlge: Add disable/enable firmare irqs to handler.

Shreyas Bhatewara (1):
      net: VMware virtual Ethernet NIC driver: vmxnet3

Sriram (1):
      TI DaVinci EMAC: Clear statistics register properly.

Vincent Sanders (1):
      net: Fix IXP 2000 network driver building.

Wey-Yi Guy (2):
      iwlwifi: fix EEPROM enhance tx power offset
      iwlwifi: change the order of freeing memory

Willy Tarreau (1):
      tcp: fix tcp_defer_accept to consider the timeout

Wolfram Sang (1):
      include/linux/netdevice.h: fix nanodoc mismatch

fran=E7ois romieu (1):
      r8169: partial support and phy init for the 8168d

jamal (1):
      pkt_sched: pedit use proper struct

 MAINTAINERS                                   |    8 +
 drivers/net/Kconfig                           |   11 +
 drivers/net/Makefile                          |   10 +-
 drivers/net/acenic.c                          |    3 +-
 drivers/net/can/sja1000/sja1000_of_platform.c |    1 +
 drivers/net/davinci_emac.c                    |   36 +-
 drivers/net/ethoc.c                           |    3 +-
 drivers/net/fec_mpc52xx.c                     |    6 -
 drivers/net/fec_mpc52xx_phy.c                 |    1 +
 drivers/net/fs_enet/fs_enet-main.c            |    1 +
 drivers/net/fs_enet/mii-bitbang.c             |    1 +
 drivers/net/fs_enet/mii-fec.c                 |    1 +
 drivers/net/fsl_pq_mdio.c                     |    1 +
 drivers/net/gianfar.c                         |    4 +-
 drivers/net/ibm_newemac/core.c                |    9 +-
 drivers/net/ibm_newemac/emac.h                |    1 +
 drivers/net/irda/sa1100_ir.c                  |    7 +-
 drivers/net/ixp2000/enp2611.c                 |   18 +-
 drivers/net/ixp2000/ixpdev.c                  |   11 +
 drivers/net/netxen/netxen_nic_main.c          |    3 +-
 drivers/net/pcmcia/3c574_cs.c                 |   13 +-
 drivers/net/phy/mdio-gpio.c                   |    1 +
 drivers/net/qlge/qlge.h                       |   10 +-
 drivers/net/qlge/qlge_main.c                  |   97 +-
 drivers/net/qlge/qlge_mpi.c                   |   93 +
 drivers/net/r8169.c                           |  987 +++++++++-
 drivers/net/stmmac/Kconfig                    |   53 +
 drivers/net/stmmac/Makefile                   |    4 +
 drivers/net/stmmac/common.h                   |  330 ++++
 drivers/net/stmmac/descs.h                    |  163 ++
 drivers/net/stmmac/gmac.c                     |  693 +++++++
 drivers/net/stmmac/gmac.h                     |  204 ++
 drivers/net/stmmac/mac100.c                   |  517 +++++
 drivers/net/stmmac/mac100.h                   |  116 ++
 drivers/net/stmmac/stmmac.h                   |   98 +
 drivers/net/stmmac/stmmac_ethtool.c           |  395 ++++
 drivers/net/stmmac/stmmac_main.c              | 2204 +++++++++++++++++=
++++
 drivers/net/stmmac/stmmac_mdio.c              |  217 +++
 drivers/net/stmmac/stmmac_timer.c             |  140 ++
 drivers/net/stmmac/stmmac_timer.h             |   41 +
 drivers/net/usb/pegasus.c                     |   13 +
 drivers/net/usb/pegasus.h                     |    6 +-
 drivers/net/vmxnet3/Makefile                  |   35 +
 drivers/net/vmxnet3/upt1_defs.h               |   96 +
 drivers/net/vmxnet3/vmxnet3_defs.h            |  535 ++++++
 drivers/net/vmxnet3/vmxnet3_drv.c             | 2556 +++++++++++++++++=
++++++++
 drivers/net/vmxnet3/vmxnet3_ethtool.c         |  566 ++++++
 drivers/net/vmxnet3/vmxnet3_int.h             |  389 ++++
 drivers/net/wan/hdlc_cisco.c                  |   18 +-
 drivers/net/wireless/adm8211.h                |    2 +-
 drivers/net/wireless/b43/b43.h                |  168 +-
 drivers/net/wireless/b43/leds.c               |    4 +-
 drivers/net/wireless/b43/leds.h               |    4 +-
 drivers/net/wireless/b43/main.c               |    7 +-
 drivers/net/wireless/b43/pio.c                |   78 +-
 drivers/net/wireless/b43/xmit.c               |    5 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c     |   23 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h     |   20 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c         |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c   |    2 +-
 drivers/net/wireless/libertas/cmdresp.c       |    1 +
 drivers/net/znet.c                            |    8 -
 include/linux/netdevice.h                     |    2 +-
 include/net/mac80211.h                        |    2 +
 include/net/sock.h                            |   10 +-
 net/ipv4/tcp_minisocks.c                      |    1 +
 net/ipv4/udp.c                                |   73 +-
 net/mac80211/ibss.c                           |    4 +-
 net/mac80211/rx.c                             |   12 +-
 net/mac80211/sta_info.c                       |    2 +
 net/mac80211/tx.c                             |    3 +-
 net/mac80211/util.c                           |    4 +-
 net/sched/act_pedit.c                         |    2 +-
 net/sched/cls_api.c                           |    2 +-
 net/wireless/nl80211.c                        |    3 +-
 80 files changed, 10835 insertions(+), 345 deletions(-)
 create mode 100644 drivers/net/stmmac/Kconfig
 create mode 100644 drivers/net/stmmac/Makefile
 create mode 100644 drivers/net/stmmac/common.h
 create mode 100644 drivers/net/stmmac/descs.h
 create mode 100644 drivers/net/stmmac/gmac.c
 create mode 100644 drivers/net/stmmac/gmac.h
 create mode 100644 drivers/net/stmmac/mac100.c
 create mode 100644 drivers/net/stmmac/mac100.h
 create mode 100644 drivers/net/stmmac/stmmac.h
 create mode 100644 drivers/net/stmmac/stmmac_ethtool.c
 create mode 100644 drivers/net/stmmac/stmmac_main.c
 create mode 100644 drivers/net/stmmac/stmmac_mdio.c
 create mode 100644 drivers/net/stmmac/stmmac_timer.c
 create mode 100644 drivers/net/stmmac/stmmac_timer.h
 create mode 100644 drivers/net/vmxnet3/Makefile
 create mode 100644 drivers/net/vmxnet3/upt1_defs.h
 create mode 100644 drivers/net/vmxnet3/vmxnet3_defs.h
 create mode 100644 drivers/net/vmxnet3/vmxnet3_drv.c
 create mode 100644 drivers/net/vmxnet3/vmxnet3_ethtool.c
 create mode 100644 drivers/net/vmxnet3/vmxnet3_int.h
