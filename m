From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 29 Jul 2014 16:55:32 -0700 (PDT)
Message-ID: <20140729.165532.599552078692796545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Make fragmentation IDs less predictable, from Eric Dumazet.

2) TSO tunneling can crash in bnx2x driver, fix from Dmitry Kravkov.

3) Don't allow NULL msg->msg_name just because msg->msg_namelen is non-zero,
   from Andrey Ryabinin.

4) ndm->ndm_type set using wrong macros, from Jun Zhao.

5) cdc-ether devices can come up with entries in their address filter,
   so explicitly clear the filter after the device initializes.  From
   Oliver Neukum.

6) Forgotten refcount bump in xfrm_lookup(), from Steffen Klassert.

7) Short packets not padded properly, exposing random data, in bcmgenet
   driver.  Fix from Florian Fainelli.

8) xgbe_probe() doesn't return an error code, but rather zero, when
   netif_set_real_num_tx_queues() fails.  Fix from Wei Yongjun.

9) USB speed not probed properly in r8152 driver, from Hayes Wang.

10) Transmit logic choosing the outgoing port in the sunvnet driver needs
    to consider a) is the port actually up and b) whether it is a switch
    port.  Fix from David L Stevens.

Please pull, thanks a lot!

The following changes since commit 15ba2236f3556fc01b9ca91394465152b5ea74b6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-07-21 22:46:01 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to d92f5dec6325079c550889883af51db1b77d5623:

  net: phy: re-apply PHY fixups during phy_register_device (2014-07-29 12:25:57 -0700)

----------------------------------------------------------------
Alexey Khoroshilov (1):
      isdn/bas_gigaset: fix a leak on failure path in gigaset_probe()

Andrey Ryabinin (1):
      net: sendmsg: fix NULL pointer dereference

Daniel Borkmann (1):
      net: sctp: inherit auth_capable on INIT collisions

David L Stevens (1):
      sunvnet: only use connected ports when sending

David S. Miller (5):
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'mdio_module_unload'
      Merge tag 'master-2014-07-23' of git://git.kernel.org/.../linville/wireless
      Merge tag 'linux-can-fixes-for-3.16-20140725' of git://gitorious.org/linux-can/linux-can

Dmitry Kravkov (1):
      bnx2x: fix crash during TSO tunneling

Eliad Peller (2):
      cfg80211: fix mic_failure tracing
      iwlwifi: mvm: pass beacons from foreign APs

Emmanuel Grumbach (1):
      iwlwifi: mvm: fix merge damage

Eric Dumazet (1):
      ip: make IP identifiers less predictable

Ezequiel Garcia (2):
      net: phy: Set the driver when registering an MDIO bus device
      net: phy: Ensure the MDIO bus module is held

Felix Fietkau (2):
      mac80211: fix crash on getting sta info with uninitialized rate control
      ath9k: fix aggregation session lockup

Florian Fainelli (2):
      net: bcmgenet: correctly pad short packets
      net: phy: re-apply PHY fixups during phy_register_device

George Cherian (1):
      can: c_can_platform: Fix raminit, use devm_ioremap() instead of devm_ioremap_resource()

Johannes Berg (1):
      Revert "mac80211: move "bufferable MMPDU" check to fix AP mode scan"

John W. Linville (3):
      Merge git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211

Julian Anastasov (1):
      ipvs: avoid netns exit crash on ip_vs_conn_drop_conntrack

Jun Zhao (1):
      neighbour : fix ndm_type type error issue

Oliver Neukum (2):
      cdc_subset: deal with a device that needs reset for timeout
      cdc-ether: clean packet filter upon probe

Steffen Klassert (1):
      xfrm: Fix refcount imbalance in xfrm_lookup

Tobias Brunner (1):
      xfrm: Fix installation of AH IPsec SAs

Wei Yongjun (2):
      amd-xgbe: Fix error return code in xgbe_probe()
      hyperv: Fix error return code in netvsc_init_buf()

Yaniv Rosner (1):
      bnx2x: fix set_setting for some PHYs

hayeswang (1):
      r8152: fix the checking of the usb speed

 drivers/isdn/gigaset/bas-gigaset.c                  |  1 +
 drivers/net/can/c_can/c_can_platform.c              |  3 ++-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c           |  3 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h         |  1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |  9 +++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |  1 +
 drivers/net/ethernet/broadcom/genet/bcmgenet.c      |  5 +++++
 drivers/net/ethernet/sun/sunvnet.c                  | 22 +++++++++++++++++-----
 drivers/net/hyperv/netvsc.c                         |  4 +++-
 drivers/net/phy/mdio_bus.c                          |  1 +
 drivers/net/phy/phy_device.c                        | 15 ++++++++++++++-
 drivers/net/usb/cdc_ether.c                         | 16 ++++++++++++++++
 drivers/net/usb/cdc_subset.c                        | 27 +++++++++++++++++++++++++++
 drivers/net/usb/r8152.c                             |  7 +++----
 drivers/net/usb/usbnet.c                            |  8 ++++++--
 drivers/net/vxlan.c                                 |  2 +-
 drivers/net/wireless/ath/ath9k/xmit.c               |  9 +++++++++
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c         | 15 +++++++++++++--
 drivers/net/wireless/iwlwifi/mvm/mac80211.c         |  7 -------
 include/linux/usb/usbnet.h                          |  3 +++
 include/net/ip.h                                    | 11 +----------
 net/compat.c                                        |  9 +++++----
 net/core/iovec.c                                    |  6 +++---
 net/core/neighbour.c                                |  2 +-
 net/ipv4/route.c                                    | 32 +++++++++++++++++++++++++++++---
 net/ipv6/ip6_output.c                               |  2 ++
 net/mac80211/cfg.c                                  |  5 ++++-
 net/mac80211/tx.c                                   | 20 ++++++++++----------
 net/netfilter/ipvs/ip_vs_conn.c                     |  1 -
 net/sctp/associola.c                                |  1 +
 net/wireless/trace.h                                |  3 ++-
 net/xfrm/xfrm_policy.c                              |  2 ++
 net/xfrm/xfrm_user.c                                |  7 +++----
 33 files changed, 197 insertions(+), 63 deletions(-)
