From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 12 Aug 2010 16:10:50 -0700 (PDT)
Message-ID: <20100812.161050.246523792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) qlcnic driver using way too much stack space during probe, fix
   from Dan Carpenter.

2) sfq was oops'able during config because it only partially provided
   the classful qdisc interfaces.  Fix this, and also add validation
   code during qdisc registry so that we can catch this ahead of time
   in the future.  From Jarek Poplawski.

3) Properly undo pci_enable_device() when PCI driver probe fails in
   ISDN.  From Kulikov Vasiliy.

4) Buffer overflow fix in CAN protocol from Oliver Kartkopp.

5) kernel-doc and Kconfig dependency fixups from Randy Dunlap.

6) s390 driver use macros named READ/WRITE, fix to avoid namespace
   conflicts.  From Heiko Carstens and Ursula Braun.

7) Minor fixes to CAIF protocol stack from Sjur Braendeland.

8) The usual assortment of wireless fixes via John Linville and co.

Please pull, thanks a lot.

The following changes since commit ad41a1e0cab07c5125456e8d38e5b1ab148d04aa:

  Merge branch 'io_remap_pfn_range' of git://www.jni.nu/cris (2010-08-12 10:17:19 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ben Greear (1):
      net: Use NET_XMIT_SUCCESS where possible.

Dan Carpenter (2):
      qlcnic: clean up qlcnic_init_pci_info()
      qlcnic: using too much stack

David S. Miller (3):
      farsync: Fix compile warnings.
      usbnet: rx_submit() should return an error code.
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Heiko Carstens (1):
      claw: rename READ/WRITE defines to avoid redefinitions

Jarek Poplawski (4):
      pkt_sched: sch_sfq: Add dummy unbind_tcf and put handles. Was: [PATCH] sfq: add dummy bind/unbind handles
      pkt_sched: Add some basic qdisc class ops verification. Was: [PATCH] sfq: add dummy bind/unbind handles
      pkt_sched: Fix sch_sfq vs tc_modify_qdisc oops
      pkt_sched: Check .walk and .leaf class handlers

Johannes Berg (2):
      cfg80211: fix locking in action frame TX
      iwlagn: fix rts cts protection

John W. Linville (4):
      Revert "p54pci: Add PCI ID for SMC2802W"
      libertas: fix build break by including linux/sched.h
      Merge branch 'master' of git://git.kernel.org/.../holtmann/bluetooth-2.6
      net: make netpoll_rx return bool for !CONFIG_NETPOLL

Kulikov Vasiliy (3):
      isdn: avm: call pci_disable_device() if pci_probe() failed
      isdn: avm: call pci_disable_device() if pci_probe() failed
      isdn: mISDN: call pci_disable_device() if pci_probe() failed

Mat Martineau (4):
      Bluetooth: Fix endianness issue with L2CAP MPS configuration
      Bluetooth: Change default L2CAP ERTM retransmit timeout
      Bluetooth: Fix incorrect setting of remote_tx_win for L2CAP ERTM
      Bluetooth: Use 3-DH5 payload size for default ERTM max PDU size

Oliver Hartkopp (1):
      can: add limit for nframes and clean up signed/unsigned variables

Randy Dunlap (4):
      etherdevice.h: fix kernel-doc typo
      net/sock.h: add missing kernel-doc notation
      phy.c: fix kernel-doc warnings
      phylib: available for any speed ethernet

Sjur Braendeland (2):
      caif: Bugfix - Increase default headroom size for control channel.
      caif-spi: Bugfix SPI_DATA_POS settings were inverted.

Ursula Braun (1):
      ctcm: rename READ/WRITE defines to avoid redefinitions

 drivers/isdn/hardware/avm/c4.c              |    1 +
 drivers/isdn/hardware/avm/t1pci.c           |    1 +
 drivers/isdn/hardware/mISDN/mISDNinfineon.c |    5 +-
 drivers/net/caif/caif_spi_slave.c           |    4 +-
 drivers/net/phy/Kconfig                     |    2 +-
 drivers/net/phy/phy.c                       |    2 +-
 drivers/net/qlcnic/qlcnic_main.c            |   72 ++++++++++-------
 drivers/net/usb/usbnet.c                    |   22 ++++--
 drivers/net/wan/farsync.c                   |   15 ++--
 drivers/net/wireless/iwlwifi/iwl-1000.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |   18 +----
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |   10 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c     |   16 ++--
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c |   19 ++++-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c   |   20 +-----
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   85 +++++---------------
 drivers/net/wireless/iwlwifi/iwl-core.c     |   29 ++++++-
 drivers/net/wireless/iwlwifi/iwl-core.h     |   14 ++--
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    5 +-
 drivers/net/wireless/libertas/cfg.c         |    1 +
 drivers/net/wireless/p54/p54pci.c           |    2 -
 drivers/s390/net/claw.c                     |  118 +++++++++++++-------------
 drivers/s390/net/claw.h                     |    4 +-
 drivers/s390/net/ctcm_fsms.c                |   60 +++++++-------
 drivers/s390/net/ctcm_main.c                |   80 +++++++++---------
 drivers/s390/net/ctcm_main.h                |    4 +-
 drivers/s390/net/ctcm_mpc.c                 |   64 ++++++++-------
 drivers/s390/net/ctcm_sysfs.c               |   20 +++---
 include/linux/etherdevice.h                 |    2 +-
 include/linux/netpoll.h                     |    2 +-
 include/net/bluetooth/l2cap.h               |    4 +-
 include/net/sock.h                          |    4 +-
 net/bluetooth/l2cap.c                       |   11 +--
 net/caif/cfpkt_skbuff.c                     |    2 +-
 net/can/bcm.c                               |   41 ++++++---
 net/dsa/Kconfig                             |    2 +-
 net/sched/sch_api.c                         |   22 ++++-
 net/sched/sch_atm.c                         |    4 +-
 net/sched/sch_sfq.c                         |   14 +++-
 net/sched/sch_tbf.c                         |    4 +-
 net/sched/sch_teql.c                        |    2 +-
 net/wireless/mlme.c                         |    8 ++-
 43 files changed, 428 insertions(+), 391 deletions(-)
