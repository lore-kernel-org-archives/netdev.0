From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 06 Apr 2010 04:33:08 -0700 (PDT)
Message-ID: <20100406.043308.112189207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44405
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752166Ab0DFLdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 07:33:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The tcp splice oops is pretty nasty... anyways.

1) Fixup rcu_deref calls done outside RCU read lock in netlabel,
   from Paul Moore.

2) gianfar fixes (memory leak on close, message alignment) from
   Andy Fleming and Kim Philips.

3) MAC address probing fix in smc91c92_cs from Ken Kawasaki.

4) Some small wireless fixes via John Linville and co. including
   a few device ID additions.
	a) iwlwifi bool conversion to flags broke regulatory handling
	b) iwlwifi tfd counting on 4965 chips fix
	c) mac80211's reg_regdb_search_lock needs to be a mutex
	d) off-by-one test fix in wireless mesh metric handling

5) New cxgb4 driver.

6) TCP doesn't maintain queue comsumed state properly across socket
   lock dropping (and thus backlog processing) during splice so this
   confuses tcp_collapse() and we crash.  Fix from Steven J. Magnani

7) bond_uninit() deadlock fix from Amerigo Wang.

8) be2net fixes (redboot flashing, big endian flashing and VLAN rx
   issues) from Ajit Khaparde.

9) stmmac needs crc32, from Carmelo AMOROSO

10) round-robin bonding does htons() on a u8 :-)  Fix from Eric
    Dumazet.

11) Missing lock release in sgisseq driver, from Julia Lawall

12) Need to validate socket address length before derefing in
    socket ->connect() handlers.  From Changli Gao.

Please pull, thanks a lot!

The following changes since commit db217dece3003df0841bacf9556b5c06aa097dae:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../davem/sparc-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (3):
      be2net: fix a bug in flashing the redboot section
      be2net: fix flashing on big endian architectures
      be2net: fix bug in vlan rx path for big endian architecture

Amerigo Wang (1):
      bonding: fix potential deadlock in bond_uninit()

Andy Fleming (1):
      gianfar: Fix a memory leak in gianfar close code

Ben Konrath (1):
      ar9170: add support for NEC WL300NU-G USB dongle

Benjamin Larsson (1):
      Add a pci-id to the mwl8k driver

Carmelo AMOROSO (1):
      stmmac: fix kconfig for crc32 build error

Changli Gao (1):
      net: check the length of the socket address passed to connect(2)

Dan Carpenter (1):
      iwlwifi: range checking issue

Daniel Mack (1):
      net/wireless/libertas: do not call wiphy_unregister() w/o wiphy_register()

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Dimitris Michailidis (6):
      cxgb4: Add register, message, and FW definitions
      cxgb4: Add HW and FW support code
      cxgb4: Add packet queues and packet DMA code
      cxgb4: Add remaining driver headers and L2T management
      cxgb4: Add main driver file and driver Makefile
      net: Hook up cxgb4 to Kconfig and Makefile

Eric Dumazet (1):
      bonding: bond_xmit_roundrobin() fix

Gertjan van Wingerde (2):
      rt2x00: Fix typo in RF register programming of rt2800.
      rt2x00: Disable powersaving by default in rt2500usb.

Giuseppe CAVALLARO (1):
      stmmac: add documentation for the driver.

Hans de Goede (1):
      Add USB ID for Thomson SpeedTouch 120g to p54usb id table

Johannes Berg (1):
      mac80211: move netdev queue enabling to correct spot

John W. Linville (2):
      wireless: convert reg_regdb_search_lock to mutex
      mac80211: correct typos in "unavailable upon resume" warning

Julia Lawall (1):
      drivers/net: Add missing unlock

Ken Kawasaki (1):
      smc91c92_cs: fix the problem of "Unable to find hardware address"

Kim Phillips (2):
      net: gianfar - initialize per-queue statistics
      net: gianfar - align BD ring size console messages

Neil Horman (1):
      r8169: clean up my printk uglyness

Paul Moore (1):
      netlabel: Fix several rcu_dereference() calls used without RCU read locks

Porsch, Marco (1):
      mac80211: fix PREQ processing and one small bug

Reinette Chatre (1):
      iwlwifi: fix regulatory

Shanyu Zhao (1):
      iwlwifi: clear unattended interrupts in tasklet

Steven J. Magnani (1):
      net: Fix oops from tcp_collapse() when using splice()

Valentin Longchamp (1):
      setup correct int pipe type in ar9170_usb_exec_cmd

Wey-Yi Guy (1):
      iwlwifi: counting number of tfds can be free for 4965

 Documentation/networking/stmmac.txt         |  143 ++
 drivers/net/Kconfig                         |   25 +
 drivers/net/Makefile                        |    1 +
 drivers/net/benet/be_cmds.c                 |    4 +-
 drivers/net/benet/be_main.c                 |   21 +-
 drivers/net/bonding/bond_main.c             |   28 +-
 drivers/net/cxgb4/Makefile                  |    7 +
 drivers/net/cxgb4/cxgb4.h                   |  741 ++++++
 drivers/net/cxgb4/cxgb4_main.c              | 3388 +++++++++++++++++++++++++++
 drivers/net/cxgb4/cxgb4_uld.h               |  239 ++
 drivers/net/cxgb4/l2t.c                     |  624 +++++
 drivers/net/cxgb4/l2t.h                     |  110 +
 drivers/net/cxgb4/sge.c                     | 2431 +++++++++++++++++++
 drivers/net/cxgb4/t4_hw.c                   | 3131 +++++++++++++++++++++++++
 drivers/net/cxgb4/t4_hw.h                   |  100 +
 drivers/net/cxgb4/t4_msg.h                  |  664 ++++++
 drivers/net/cxgb4/t4_regs.h                 |  878 +++++++
 drivers/net/cxgb4/t4fw_api.h                | 1580 +++++++++++++
 drivers/net/gianfar.c                       |   12 +-
 drivers/net/pcmcia/smc91c92_cs.c            |   12 +-
 drivers/net/r8169.c                         |    4 +-
 drivers/net/sgiseeq.c                       |    4 +-
 drivers/net/stmmac/Kconfig                  |    1 +
 drivers/net/wireless/ath/ar9170/usb.c       |    4 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   12 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    4 +-
 drivers/net/wireless/libertas/cfg.c         |    8 +-
 drivers/net/wireless/libertas/dev.h         |    1 +
 drivers/net/wireless/mwl8k.c                |    1 +
 drivers/net/wireless/p54/p54usb.c           |    1 +
 drivers/net/wireless/rt2x00/rt2500usb.c     |    5 +
 drivers/net/wireless/rt2x00/rt2800lib.c     |    4 +-
 net/bluetooth/l2cap.c                       |    3 +-
 net/bluetooth/rfcomm/sock.c                 |    3 +-
 net/bluetooth/sco.c                         |    3 +-
 net/can/bcm.c                               |    3 +
 net/ieee802154/af_ieee802154.c              |    3 +
 net/ipv4/af_inet.c                          |    5 +
 net/ipv4/tcp.c                              |    1 +
 net/mac80211/mesh_hwmp.c                    |    4 +-
 net/mac80211/tx.c                           |    6 +
 net/mac80211/util.c                         |   18 +-
 net/netlabel/netlabel_domainhash.c          |   28 +-
 net/netlabel/netlabel_unlabeled.c           |   66 +-
 net/netlink/af_netlink.c                    |    3 +
 net/wireless/reg.c                          |   12 +-
 47 files changed, 14221 insertions(+), 131 deletions(-)
 create mode 100644 Documentation/networking/stmmac.txt
 create mode 100644 drivers/net/cxgb4/Makefile
 create mode 100644 drivers/net/cxgb4/cxgb4.h
 create mode 100644 drivers/net/cxgb4/cxgb4_main.c
 create mode 100644 drivers/net/cxgb4/cxgb4_uld.h
 create mode 100644 drivers/net/cxgb4/l2t.c
 create mode 100644 drivers/net/cxgb4/l2t.h
 create mode 100644 drivers/net/cxgb4/sge.c
 create mode 100644 drivers/net/cxgb4/t4_hw.c
 create mode 100644 drivers/net/cxgb4/t4_hw.h
 create mode 100644 drivers/net/cxgb4/t4_msg.h
 create mode 100644 drivers/net/cxgb4/t4_regs.h
 create mode 100644 drivers/net/cxgb4/t4fw_api.h
