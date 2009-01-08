From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 08 Jan 2009 14:21:27 -0800 (PST)
Message-ID: <20090108.142127.07019641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47733
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759546AbZAHWV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 17:21:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The majority of this series is a bunch of net_device_ops
conversions from Stephen Hemmingers and some other helpers.

Outside of that we have bug fixes in various drivers: r6040,
bnx2x, wimax, gianfar, bfin_mac, dm9601 and mlx4_en.

More GRO enhancements from Herbert Xu.

And oh yeah I got rid of that acenic_firmware.h file that
got mucked up last time around :)

Please pull, thanks a lot!

The following changes since commit 85da1fb545e5fe51c35e0576f71780cc557f4277:
  Linus Torvalds (1):
        Merge branch 'next' of git://git.kernel.org/.../benh/powerpc

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (3):
      acenic: Missed delete of acenic_firmware.h
      Merge branch 'master' of master.kernel.org:/.../torvalds/linux-2.6

Eilon Greenstein (1):
      bnx2x: Prevent eeprom set when driver is down

Florian Fainelli (4):
      r6040: make printks consistent with DRV_NAME
      r6040: check PHY status when bringing interface up
      r6040: warn about MAC address being unset
      r6040: bump release number to 0.20

Frank Blaschka (2):
      vlan: add neigh_setup
      qeth: convert to net_device_ops

Herbert Xu (4):
      gro: Add internal interfaces for VLAN
      vlan: Add GRO interfaces
      ipv6: Add GRO support
      tcp6: Add GRO support

Inaky Perez-Gonzalez (5):
      wimax: fix '#ifndef CONFIG_BUG' layout to avoid warning
      wimax: fix kconfig interactions with rfkill and input layers
      wimax: testing for rfkill support should also test for CONFIG_RFKILL_MODULE
      i2400m/usb: wrap USB power saving in #ifdef CONFIG_PM
      wimax: fix kernel-doc for debufs_dentry member of struct wimax_dev

Jaswinder Singh Rajput (1):
      firmware: convert e100 driver to request_firmware()

Kumar Gala (1):
      gianfar: Fixup use of BUS_ID_SIZE

Li Yang (1):
      gianfar: ensure ECNTRL[R100] is cleared on link state change

Oliver Hartkopp (1):
      can: omit unneeded skb_clone() calls

Oliver Neukum (2):
      net: switch kaweth driver to netdevops
      net: convert pegasus driver to net_device_ops

Sonic Zhang (1):
      netdev: bfin_mac: enable bfin_mac net dev driver for BF51x

Stephen Hemminger (52):
      irda: convert to internal stats
      bonding: use net_device_ops
      wireless: convert wireless ioctl to net_device_ops
      virtio: convert to net_device_ops
      xen-netfront: convert to net_device_ops
      sch_teql: convert to net_device_ops
      dsa: convert to net_device_ops (v2)
      ieee1394: convert to net_device_ops
      ieee1394: remove unneeded last_rx
      ieee1394: use internal network device stats
      appletalk: convert aarp to net_device_ops
      appletalk: convert ipddp to net_device_ops
      bluetooth: driver API update
      phonet: update to net_device_ops
      cassini: update to net_device_ops
      ipg: update to net_device_ops
      plip: update to net_device_ops
      tlan: update to net_device_ops
      epic100: update to net_device_ops
      sunhme: update to net_device_ops
      sungem: update to net_device_ops
      pcnet32: update to net_device_ops
      typhoon: update to net_device_ops
      enc28j60: update to net_device_ops
      de600: update to net_device_ops
      sis190: update to net_device_ops
      ns83820: fix net_device_ops support
      sb1000: update to net_device_ops
      natsemi: update to net_device_ops
      fealnx: update to net_device_ops
      starfire: update to net_device_ops
      sundance: update to net_device_ops
      tulip: convert devices to new API
      de2104x: convert to net_device_ops
      de4x5: convert to net_device_ops
      xircom: convert devices to new API
      dmfe: convert to new API
      uli526x: convert devices to new API
      windbond: convert devices to new API
      dvb: update network device to current API
      hysdn: convert to net_device_ops and other updates
      I4l: convert to net_device_ops
      fusion: convert devices to new API
      xpnet: convert devices to new API
      gadget: convert devices to new API
      uwb: convert devices to net_device_ops
      slip: convert to net_device_ops
      amd8111e: convert to net_device_ops
      atp: convert to net_device_ops
      b44: convert to net_device_ops
      hp100: update to net_device_ops
      pcnet32: round off carrier watch timer

Stephen Rothwell (2):
      net/ehea: use consistant type
      ibmveth: use consistent types

Wu Fengguang (4):
      dm9601: handle corrupt mac address
      dm9601: bring datasheet URL up to date
      dm9601: tell HW about random generated mac address
      dm9601: warn on invalid mac address

Yevgeny Petrilin (2):
      mlx4_en: Consider inline packets on completion
      mlx4_en: Returning real Max in get_ringparam

 drivers/ieee1394/eth1394.c                |   54 +-
 drivers/ieee1394/eth1394.h                |    1 -
 drivers/isdn/hysdn/hysdn_net.c            |   77 +-
 drivers/isdn/i4l/isdn_net.c               |   69 +-
 drivers/media/dvb/dvb-core/dvb_net.c      |   57 +-
 drivers/message/fusion/mptlan.c           |   44 +-
 drivers/misc/sgi-xp/xpnet.c               |   68 +-
 drivers/net/Kconfig                       |    2 +-
 drivers/net/acenic_firmware.h             | 9456 -----------------------------
 drivers/net/amd8111e.c                    |   35 +-
 drivers/net/appletalk/ipddp.c             |   25 +-
 drivers/net/atp.c                         |   32 +-
 drivers/net/b44.c                         |   29 +-
 drivers/net/bnx2x_main.c                  |    3 +
 drivers/net/bonding/bond_main.c           |    2 +-
 drivers/net/cassini.c                     |   29 +-
 drivers/net/de600.c                       |   14 +-
 drivers/net/de620.c                       |   17 +-
 drivers/net/e100.c                        |  289 +-
 drivers/net/ehea/ehea_phyp.c              |   16 +-
 drivers/net/enc28j60.c                    |   18 +-
 drivers/net/epic100.c                     |   21 +-
 drivers/net/fealnx.c                      |   21 +-
 drivers/net/gianfar.c                     |    8 +-
 drivers/net/hp100.c                       |   32 +-
 drivers/net/ibmveth.c                     |    4 +-
 drivers/net/ibmveth.h                     |   10 +-
 drivers/net/ipg.c                         |   23 +-
 drivers/net/irda/ali-ircc.c               |   45 +-
 drivers/net/irda/ali-ircc.h               |    1 -
 drivers/net/irda/au1000_ircc.h            |    1 -
 drivers/net/irda/au1k_ir.c                |    9 -
 drivers/net/irda/donauboe.h               |    1 -
 drivers/net/irda/irda-usb.c               |   28 +-
 drivers/net/irda/irda-usb.h               |    1 -
 drivers/net/irda/kingsun-sir.c            |   20 +-
 drivers/net/irda/ks959-sir.c              |   22 +-
 drivers/net/irda/ksdazzle-sir.c           |   26 +-
 drivers/net/irda/mcs7780.c                |   49 +-
 drivers/net/irda/mcs7780.h                |    2 -
 drivers/net/irda/nsc-ircc.c               |   45 +-
 drivers/net/irda/nsc-ircc.h               |    1 -
 drivers/net/irda/pxaficp_ir.c             |   52 +-
 drivers/net/irda/sa1100_ir.c              |   46 +-
 drivers/net/irda/sir-dev.h                |    1 -
 drivers/net/irda/sir_dev.c                |   26 +-
 drivers/net/irda/smsc-ircc2.c             |   38 +-
 drivers/net/irda/stir4200.c               |   44 +-
 drivers/net/irda/via-ircc.c               |   47 +-
 drivers/net/irda/via-ircc.h               |    1 -
 drivers/net/irda/vlsi_ir.c                |   78 +-
 drivers/net/irda/vlsi_ir.h                |    1 -
 drivers/net/irda/w83977af_ir.c            |   35 +-
 drivers/net/irda/w83977af_ir.h            |    1 -
 drivers/net/mlx4/en_params.c              |    6 +-
 drivers/net/mlx4/en_tx.c                  |   59 +-
 drivers/net/mlx4/mlx4_en.h                |    5 +
 drivers/net/natsemi.c                     |   29 +-
 drivers/net/ns83820.c                     |    4 +-
 drivers/net/pcnet32.c                     |   32 +-
 drivers/net/plip.c                        |   13 +-
 drivers/net/r6040.c                       |   27 +-
 drivers/net/sb1000.c                      |   16 +-
 drivers/net/sis190.c                      |   28 +-
 drivers/net/slip.c                        |   28 +-
 drivers/net/starfire.c                    |   34 +-
 drivers/net/sundance.c                    |   23 +-
 drivers/net/sungem.c                      |   22 +-
 drivers/net/sunhme.c                      |   26 +-
 drivers/net/tlan.c                        |   26 +-
 drivers/net/tulip/de2104x.c               |   19 +-
 drivers/net/tulip/de4x5.c                 |   20 +-
 drivers/net/tulip/dmfe.c                  |   62 +-
 drivers/net/tulip/tulip_core.c            |   27 +-
 drivers/net/tulip/uli526x.c               |   63 +-
 drivers/net/tulip/winbond-840.c           |   23 +-
 drivers/net/tulip/xircom_cb.c             |   43 +-
 drivers/net/typhoon.c                     |   22 +-
 drivers/net/usb/dm9601.c                  |   29 +-
 drivers/net/usb/kaweth.c                  |   23 +-
 drivers/net/usb/pegasus.c                 |   21 +-
 drivers/net/virtio_net.c                  |   20 +-
 drivers/net/wimax/i2400m/usb.c            |    6 +
 drivers/net/xen-netfront.c                |   17 +-
 drivers/s390/net/qeth_l2_main.c           |   27 +-
 drivers/s390/net/qeth_l3_main.c           |   53 +-
 drivers/usb/gadget/f_phonet.c             |   12 +-
 drivers/usb/gadget/u_ether.c              |   16 +-
 drivers/uwb/i1480/i1480u-wlp/i1480u-wlp.h |    2 -
 drivers/uwb/i1480/i1480u-wlp/lc.c         |   17 +-
 drivers/uwb/i1480/i1480u-wlp/netdev.c     |    9 -
 drivers/uwb/i1480/i1480u-wlp/rx.c         |    8 +-
 drivers/uwb/i1480/i1480u-wlp/tx.c         |    6 +-
 firmware/Makefile                         |    2 +
 firmware/WHENCE                           |   12 +
 firmware/e100/d101m_ucode.bin.ihex        |   38 +
 firmware/e100/d101s_ucode.bin.ihex        |   38 +
 firmware/e100/d102e_ucode.bin.ihex        |   38 +
 include/linux/can/core.h                  |    2 +-
 include/linux/if_vlan.h                   |   19 +
 include/linux/netdevice.h                 |    6 +
 include/net/protocol.h                    |    3 +
 include/net/wimax.h                       |    3 +
 net/8021q/vlan_core.c                     |  111 +-
 net/8021q/vlan_dev.c                      |   14 +
 net/appletalk/aarp.c                      |    5 +-
 net/bluetooth/bnep/bnep.h                 |    1 -
 net/bluetooth/bnep/core.c                 |   12 +-
 net/bluetooth/bnep/netdev.c               |   33 +-
 net/can/af_can.c                          |   15 +-
 net/can/bcm.c                             |   12 +-
 net/can/raw.c                             |   15 +-
 net/core/dev.c                            |   82 +-
 net/dsa/slave.c                           |   51 +-
 net/ipv4/tcp.c                            |    2 +
 net/ipv6/af_inet6.c                       |  107 +-
 net/ipv6/tcp_ipv6.c                       |   45 +-
 net/phonet/pep-gprs.c                     |   12 +-
 net/sched/sch_teql.c                      |   20 +-
 net/wimax/Kconfig                         |   14 +
 net/wimax/id-table.c                      |    8 +-
 net/wimax/op-rfkill.c                     |    2 +-
 net/wireless/wext.c                       |    4 +-
 123 files changed, 1821 insertions(+), 10905 deletions(-)
 delete mode 100644 drivers/net/acenic_firmware.h
 create mode 100644 firmware/e100/d101m_ucode.bin.ihex
 create mode 100644 firmware/e100/d101s_ucode.bin.ihex
 create mode 100644 firmware/e100/d102e_ucode.bin.ihex
