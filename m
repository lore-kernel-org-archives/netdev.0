From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 21 Nov 2012 12:36:56 -0500 (EST)
Message-ID: <20121121.123656.455774002301921111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) inet6_csk_update_pmtu() must return NULL or non-NULL, so translate
   ERR_PTR to NULL, as needed.  Fix from Eric Dumazet.

2) Fix copy&paste error in IRDA sir_dev ->set_speed method invocation,
   it was testing the NULL'ness of a different method to guard the call.
   Fix from Alexander Shiyan.

3) Fix build regression of xilinx driver, from Jeff Mahoney.

4) Make XEN netfront (like XEN netback) handle compound pages
   in SKBs properly.  From Ian Campbell.

5) Fix inverted logic of team_dev_queue_xmit() return value checks,
   from Jiri Pirko and Dan Carpenter.

6) dma_poll_create() no longer allows a NULL device argument, breaking
   both ixp4xx drivers.  Fix from Xi Wang.

7) ne2000 driver doesn't hook up the parent device properly, breaking
   udev matching.  Fix from Alan Cox.

8) Locking and memory leak fixes in Near Field Communications layer.
   From Thierry Escande, Szymon Janc, and Waldemar Rymarkiewicz.

9) sis900 resume regression, sis900_set_mode() is being called with
   the iomem pointer instead of the expected device private.  Fix
   from Francois Romieu.

10) Fix IBSS regression caused by uninitializing the ibss-internals
    before performing an emptyness check, from Simon WUnderlich.

11) Fix SNIFFER mode regression in iwlwifi driver, from Johannes Berg.

12) Fix task wedges in mwifiex_cmd_timeout_func(), from Bing Zhao.

13) Add back wireless sysfs directory, too much stuff depends upon it
    being there.  (actually I'd say it never should have been removed
    to begin with)  From Johannes Berg.

14) Fix hang introduced by suspend/resume changes in ath9k.  Fix from
    Sujith Manoharan.

Please pull, thanks a lot!

The following changes since commit 3587b1b097d70c2eb9fee95ea7995d13c05f66e5:

  fanotify: fix FAN_Q_OVERFLOW case of fanotify_read() (2012-11-18 09:30:00 -1000)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 403f43c937d24832b18524f65415c0bbba6b5064:

  team: bcast: convert return value of team_dev_queue_xmit() to bool correctly (2012-11-21 11:55:07 -0500)

----------------------------------------------------------------
Alan Cox (1):
      ne2000: add the right platform device

Albert Pool (1):
      rtlwifi: rtl8192cu: Add new USB ID

Alexander Shiyan (1):
      irda: sir_dev: Fix copy/paste typo

Bing Zhao (2):
      mwifiex: fix system hang issue in cmd timeout error case
      mwifiex: report error to MMC core if we cannot suspend

Emmanuel Grumbach (1):
      iwlwifi: don't WARN when a non empty queue is disabled

Eric Dumazet (1):
      ipv6: fix inet6_csk_update_pmtu() return value

Francois Romieu (1):
      sis900: fix sis900_set_mode call parameters.

Ian Campbell (1):
      xen/netfront: handle compound page fragments on transmit

Jeff Mahoney (1):
      net: fix build failure in xilinx

Jiri Pirko (1):
      team: bcast: convert return value of team_dev_queue_xmit() to bool correctly

Johannes Berg (2):
      iwlwifi: fix monitor mode FCS flag
      wireless: add back sysfs directory

John W. Linville (4):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge tag 'nfc-fixes-3.7-1' of git://git.kernel.org/.../sameo/nfc-3.0
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Sarveshwar Bandi (1):
      bonding: Bonding driver does not consider the gso_max_size/gso_max_segs setting of slave devices.

Simon Wunderlich (1):
      mac80211: deinitialize ibss-internals after emptiness check

Srinivas Kandagatla (1):
      of/net/mdio-gpio: Fix pdev->id issue when using devicetrees.

Sujith Manoharan (1):
      ath9k_hw: Fix regression in device reset

Szymon Janc (2):
      NFC: pn533: Fix missing lock while operating on commands list
      NFC: pn533: Fix use after free

Thierry Escande (2):
      NFC: Fix nfc_llcp_local chained list insertion
      NFC: Fix pn533 target mode memory leak

Waldemar Rymarkiewicz (1):
      NFC: pn533: Fix mem leak in pn533_in_dep_link_up

Xi Wang (2):
      ixp4xx_eth: avoid calling dma_pool_create() with NULL dev
      ixp4xx_hss: avoid calling dma_pool_create() with NULL dev

 Documentation/devicetree/bindings/net/mdio-gpio.txt |  9 +++++-
 drivers/net/bonding/bond_main.c                     |  7 +++++
 drivers/net/ethernet/8390/ne.c                      |  1 +
 drivers/net/ethernet/sis/sis900.c                   |  2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c   |  2 ++
 drivers/net/ethernet/xscale/ixp4xx_eth.c            |  8 +++--
 drivers/net/irda/sir_dev.c                          |  2 +-
 drivers/net/phy/mdio-gpio.c                         | 11 ++++---
 drivers/net/team/team_mode_broadcast.c              |  6 ++--
 drivers/net/wan/ixp4xx_hss.c                        |  8 +++--
 drivers/net/wireless/ath/ath9k/hw.c                 |  2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c         | 14 +++++++++
 drivers/net/wireless/iwlwifi/pcie/tx.c              |  8 -----
 drivers/net/wireless/mwifiex/cmdevt.c               | 11 +++++--
 drivers/net/wireless/mwifiex/sdio.c                 | 11 ++++---
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c         |  1 +
 drivers/net/xen-netfront.c                          | 98 +++++++++++++++++++++++++++++++++++++++++++++-------------
 drivers/nfc/pn533.c                                 | 25 ++++++++-------
 net/core/net-sysfs.c                                | 20 ++++++++++++
 net/ipv6/inet6_connection_sock.c                    |  3 +-
 net/mac80211/ibss.c                                 |  8 ++---
 net/nfc/llcp/llcp.c                                 |  2 +-
 22 files changed, 188 insertions(+), 71 deletions(-)
