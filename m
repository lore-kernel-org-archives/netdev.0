From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 18 Apr 2014 19:30:17 -0400 (EDT)
Message-ID: <20140418.193017.695468666239255075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix mlx4_en_netpoll implementation, it needs to schedule a NAPI
   context, not synchronize it.  From Chris Mason.

2) Ipv4 flow input interface should never be zero, it should be
   LOOPBACK_IFINDEX instead.  From Cong Wang and Julian
   Anastasov.

3) Properly configure MAC to PHY connection in mvneta devices, from
   Thomas Petazzoni.

4) sys_recv should use SYSCALL_DEFINE.  From Jan Glauber.

5) Tunnel driver ioctls do not use the correct namespace, fix
   from Nicolas Dichtel.

6) Fix memory leak on seccomp filter attach, from Kees Cook.

7) Fix lockdep warning for nested vlans, from Ding Tianhong.

8) Crashes can happen in SCTP due to how the auth_enable value
   is managed, fix from Vlad Yasevich.

9) Wireless fixes from John W. Linville and co.

Please pull, thanks a lot!

The following changes since commit 10ec34fcb100412ab186c141a9c3557d1270effd:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-04-15 20:30:30 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to b14878ccb7fac0242db82720b784ab62c467c0dc:

  net: sctp: cache auth_enable per endpoint (2014-04-18 18:32:00 -0400)

----------------------------------------------------------------
Amitkumar Karwar (2):
      mwifiex: process event before command response
      mwifiex: fix hung task on command timeout

Chris Mason (1):
      mlx4_en: don't use napi_synchronize inside mlx4_en_netpoll

Christian Engelmayer (2):
      rsi: Fix a potential memory leak in rsi_set_channel()
      rsi: Fix a potential memory leak in rsi_send_auto_rate_request()

Chun-Yeow Yeoh (1):
      mac80211: update last_tx_rate only for data frame

Cong Wang (2):
      ipv4, fib: pass LOOPBACK_IFINDEX instead of 0 to flowi4_iif
      ipv4, route: pass 0 instead of LOOPBACK_IFINDEX to fib_validate_source()

Dan Carpenter (1):
      isdn: icn: buffer overflow in icn_command()

David S. Miller (4):
      Merge branch 'mvneta_qsgmii'
      Merge branch 'fib_validate_loopback'
      Merge branch 'mdio-gpio'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless

Edward Cree (1):
      sfc:On MCDI timeout, issue an FLR (and mark MCDI to fail-fast)

Eliad Peller (1):
      wl18xx: align event mailbox with current fw

Emmanuel Grumbach (4):
      iwlwifi: mvm: BT Coex - send the new LUT upon antenna coupling change
      iwlwifi: 7000: bump API to 9
      iwlwifi: add MODULE_FIRMWARE for 7265
      iwlwifi: mvm: BT Coex - fix Look Up Table

Eyal Shapira (7):
      iwlwifi: mvm: rs: fix mimo delimiter in LQ cmd
      iwlwifi: mvm: rs: use correct max expected throughput figures
      iwlwifi: mvm: rs: fix and cleanup rs_get_rate_action
      iwlwifi: mvm: rs: reinit rs if no tx for a long time
      iwlwifi: mvm: rs: fallback to legacy Tx columns
      iwlwifi: mvm: avoid searching unnecessary columns
      iwlwifi: mvm: rs: clear per rate stats when aggregation changes

Felix Fietkau (2):
      mac80211: suppress BSS info change notifications for AP_VLAN
      mac80211: exclude AP_VLAN interfaces from tx power calculation

Frederic Danis (1):
      cw1200: Fix cw1200_debug_link_id

Geert Uytterhoeven (1):
      rsi: Add missing initialization of ii

Guenter Roeck (3):
      net: mdio-gpio: Use devm_ functions where possible
      net: mdio-gpio: Add support for active low gpio pins
      net: mdio-gpio: Add support for separate MDI and MDO gpio pins

Ido Yariv (1):
      mac80211: Disable SMPS for the monitor interface

Ivan Vecera (1):
      tg3: update rx_jumbo_pending ring param only when jumbo frames are enabled

Jan Glauber (1):
      net: use SYSCALL_DEFINEx for sys_recv

Johannes Berg (2):
      mac80211: fix software remain-on-channel implementation
      iwlwifi: mvm: delay enabling smart FIFO until after beacon RX

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Kees Cook (1):
      seccomp: fix memory leak on filter attach

Luciano Coelho (1):
      wlcore: ignore dummy packet events in PLT mode

Michal Kazior (1):
      mac80211: fix radar_enabled propagation

Nicolas Dichtel (3):
      ip_tunnel: use the right netns in ioctl handler
      sit: use the right netns in ioctl handler
      ip6_tunnel: use the right netns in ioctl handler

Oren Givon (1):
      iwlwifi: add new 7265 HW IDs

Thomas Petazzoni (2):
      net: phy: add minimal support for QSGMII PHY
      net: mvneta: properly configure the MAC <-> PHY connection in all situations

Vlad Yasevich (1):
      net: sctp: cache auth_enable per endpoint

dingtianhong (1):
      vlan: Fix lockdep warning when vlan dev handle notification

 Documentation/devicetree/bindings/net/ethernet.txt |    2 +-
 drivers/isdn/icn/icn.c                             |   11 ++-
 drivers/net/ethernet/broadcom/tg3.c                |    4 +-
 drivers/net/ethernet/marvell/mvneta.c              |   73 +++++++++---------
 drivers/net/ethernet/mellanox/mlx4/en_cq.c         |    1 -
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    6 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    1 -
 drivers/net/ethernet/sfc/ef10.c                    |   12 ++-
 drivers/net/ethernet/sfc/efx.c                     |   19 ++++-
 drivers/net/ethernet/sfc/enum.h                    |   23 ++++--
 drivers/net/ethernet/sfc/falcon.c                  |    4 +
 drivers/net/ethernet/sfc/farch.c                   |   22 ++++++
 drivers/net/ethernet/sfc/mcdi.c                    |   55 +++++++++++---
 drivers/net/ethernet/sfc/mcdi.h                    |   13 ++++
 drivers/net/ethernet/sfc/net_driver.h              |    4 +
 drivers/net/ethernet/sfc/nic.h                     |    1 +
 drivers/net/ethernet/sfc/siena.c                   |    2 +
 drivers/net/phy/mdio-gpio.c                        |   68 +++++++++++------
 drivers/net/wireless/cw1200/debug.c                |    2 +
 drivers/net/wireless/iwlwifi/iwl-7000.c            |    5 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c            |   18 +++--
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |    1 +
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  261 ++++++++++++++++++++++++++++++++++++++++------------------------
 drivers/net/wireless/iwlwifi/mvm/rs.h              |   14 +++-
 drivers/net/wireless/iwlwifi/mvm/sf.c              |    3 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |    2 +
 drivers/net/wireless/mwifiex/main.c                |   12 +--
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    7 +-
 drivers/net/wireless/rsi/rsi_91x_core.c            |    2 +-
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            |   21 +++---
 drivers/net/wireless/ti/wl18xx/event.h             |   20 +++++
 drivers/net/wireless/ti/wlcore/event.c             |    5 ++
 include/linux/mdio-gpio.h                          |    5 ++
 include/linux/phy.h                                |    3 +
 include/net/flow.h                                 |   10 ++-
 include/net/net_namespace.h                        |    9 +--
 include/net/sctp/structs.h                         |    4 +-
 kernel/seccomp.c                                   |    2 +
 net/8021q/vlan_dev.c                               |   46 ++++++++++--
 net/core/dev.c                                     |    1 +
 net/ipv4/fib_frontend.c                            |    2 +-
 net/ipv4/fib_semantics.c                           |    1 +
 net/ipv4/ip_tunnel.c                               |   15 ++--
 net/ipv4/ipmr.c                                    |    2 +-
 net/ipv4/netfilter/ipt_rpfilter.c                  |    5 +-
 net/ipv4/route.c                                   |    3 +-
 net/ipv6/ip6_tunnel.c                              |    8 +-
 net/ipv6/ip6mr.c                                   |    2 +-
 net/ipv6/sit.c                                     |   17 +----
 net/mac80211/chan.c                                |   11 ++-
 net/mac80211/main.c                                |    4 +-
 net/mac80211/offchannel.c                          |    1 +
 net/mac80211/status.c                              |    1 +
 net/sctp/auth.c                                    |   17 ++---
 net/sctp/endpointola.c                             |    3 +-
 net/sctp/sm_make_chunk.c                           |   32 ++++----
 net/sctp/sm_statefuns.c                            |    6 +-
 net/sctp/socket.c                                  |   54 +++++++-------
 net/sctp/sysctl.c                                  |   36 ++++++++-
 net/socket.c                                       |    4 +-
 60 files changed, 659 insertions(+), 339 deletions(-)
