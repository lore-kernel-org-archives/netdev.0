From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v2 00/20] slight optimization of addr compare for some modules
Date: Tue, 24 Dec 2013 19:27:11 +0800
Message-ID: <52B96F8F.4090503@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Joe Perches <joe@perches.com>,
	"Alexander Duyck" <alexander.h.duyck@intel.com>,
	Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:10670 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576Ab3LXL1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 06:27:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches add ether_addr_equal_unaligned to test if
possibly unaligned to u16 Ethernet addresses are equal.

If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set, this uses
the slightly faster generic routine ether_addr_equal,
otherwise this uses memcmp.

So I use the recently added and possibly more efficient
ether_addr_equal_unaligned to instead of memcmp for slight
optimization.

v2: Because a lot of places are already using 16b aligned MAC
    address for both operands, so use the ether_addr_equal to
    instead of ether_addr_equal_unaligned.Thanks for Joe, Alex
    and Antonio's opinions.
    Also remove the patch for bridge.

Regards
Ding 
     
Ding Tianhong (6):
  net: slight optimization of addr compare for some modules
  net: freescale: remove unused compare_addr()
  net: pcnet: slight optimization of addr compare
  net: atl1: slight optimization of addr compare
  hamradio: slight optimization of addr compare
  ppp: slight optimization of addr compare

Tan Xiaojun (3):
  batman-adv: use batadv_compare_eth for concise
  zd1211rw: slight optimization of addr compare
  ozwpan: slight optimization of addr compare

Wang Weidong (2):
  infiniband: slight optimization of addr compare
  mac8011: slight optimization of addr compare

Weilong Chen (6):
  hostap: slight optimization of addr compare
  cw1200: atm: slight optimization of addr compare
  ipw2x00: slight optimization of addr compare
  mwifiex: slight optimization of addr compare
  rtlwifi: slight optimization of addr compare
  wireless: slight optimization of addr compare

Yang Yingliang (3):
  atm: slight optimization of addr compare
  isdn: slight optimization of addr compare
  media: dvb_core: slight optimization of addr compare

 drivers/atm/nicstar.c                              |  4 +--
 drivers/infiniband/hw/nes/nes_cm.c                 |  3 +-
 drivers/isdn/i4l/isdn_net.c                        |  4 +--
 drivers/media/dvb-core/dvb_net.c                   |  8 ++---
 drivers/net/bonding/bond_3ad.c                     |  2 +-
 drivers/net/ethernet/3com/3c509.c                  |  3 +-
 drivers/net/ethernet/amd/pcnet32.c                 |  2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c           |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     | 10 +++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c   |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/l2t.c           |  2 +-
 drivers/net/ethernet/cisco/enic/enic_pp.c          |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |  2 +-
 drivers/net/ethernet/freescale/ucc_geth.c          |  5 ----
 drivers/net/ethernet/intel/igbvf/netdev.c          |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |  3 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  4 +--
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  2 +-
 drivers/net/ethernet/micrel/ksz884x.c              |  9 +++---
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |  2 +-
 drivers/net/ethernet/packetengines/yellowfin.c     |  8 ++---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  4 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |  4 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  4 +--
 drivers/net/ethernet/renesas/sh_eth.c              |  2 +-
 drivers/net/ethernet/seeq/sgiseeq.c                |  2 +-
 drivers/net/ethernet/sun/sunvnet.c                 |  2 +-
 drivers/net/ethernet/ti/cpsw_ale.c                 |  2 +-
 drivers/net/fddi/skfp/fplustm.c                    |  3 +-
 drivers/net/hamradio/bpqether.c                    |  2 +-
 drivers/net/plip/plip.c                            |  2 +-
 drivers/net/ppp/pppoe.c                            |  5 ++--
 drivers/net/wireless/adm8211.c                     |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |  7 ++---
 drivers/net/wireless/cw1200/sta.c                  |  5 ++--
 drivers/net/wireless/cw1200/txrx.c                 |  3 +-
 drivers/net/wireless/hostap/hostap_80211_rx.c      |  8 ++---
 drivers/net/wireless/hostap/hostap_80211_tx.c      |  4 +--
 drivers/net/wireless/hostap/hostap_ap.c            | 28 +++++++++---------
 drivers/net/wireless/hostap/hostap_hw.c            |  2 +-
 drivers/net/wireless/hostap/hostap_ioctl.c         |  4 +--
 drivers/net/wireless/hostap/hostap_main.c          |  8 ++---
 drivers/net/wireless/ipw2x00/ipw2200.c             | 34 +++++++++++-----------
 drivers/net/wireless/ipw2x00/libipw_rx.c           | 10 +++----
 drivers/net/wireless/mwifiex/11n.c                 |  2 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |  3 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |  2 +-
 drivers/net/wireless/prism54/isl_ioctl.c           |  3 +-
 drivers/net/wireless/rtlwifi/cam.c                 |  4 +--
 drivers/net/wireless/ti/wl1251/main.c              |  2 +-
 drivers/net/wireless/wl3501_cs.c                   |  4 +--
 drivers/net/wireless/zd1211rw/zd_mac.c             |  5 ++--
 drivers/staging/ozwpan/ozcdev.c                    |  2 +-
 drivers/staging/ozwpan/ozproto.c                   |  5 ++--
 net/batman-adv/originator.c                        |  2 +-
 net/batman-adv/translation-table.c                 |  2 +-
 net/caif/cfrfml.c                                  |  2 +-
 net/mac80211/iface.c                               |  7 ++---
 61 files changed, 131 insertions(+), 148 deletions(-)

-- 
1.8.0
