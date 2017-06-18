From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 0/3] more skb_put_[data:zero] related work
Date: Sun, 18 Jun 2017 22:41:54 +0800
Message-ID: <1497796914-25053-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-17.163.com ([220.181.12.17]:43562 "EHLO m12-17.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752888AbdFROms (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Jun 2017 10:42:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>



yuan linyu (3):
  net: introduce __skb_put_[zero, data, u8]
  net: replace more place to skb_put_[data:zero]
  net: manual clean code which call skb_put_[data:zero]

 drivers/crypto/chelsio/chcr_algo.c                 | 15 +++++----------
 drivers/infiniband/hw/cxgb4/cm.c                   |  6 ++----
 drivers/infiniband/hw/cxgb4/cq.c                   |  6 ++----
 drivers/infiniband/hw/cxgb4/mem.c                  |  6 ++----
 drivers/infiniband/hw/cxgb4/qp.c                   |  3 +--
 drivers/isdn/gigaset/asyncdata.c                   |  4 ++--
 drivers/isdn/gigaset/isocdata.c                    |  2 +-
 drivers/isdn/hysdn/hycapi.c                        |  8 ++++----
 drivers/isdn/i4l/isdn_bsdcomp.c                    |  2 +-
 drivers/isdn/i4l/isdn_ppp.c                        |  2 +-
 drivers/net/bonding/bond_alb.c                     |  3 +--
 drivers/net/caif/caif_hsi.c                        |  6 ++----
 drivers/net/caif/caif_serial.c                     |  3 +--
 drivers/net/caif/caif_spi.c                        |  3 +--
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    | 12 ++++--------
 drivers/net/ethernet/chelsio/cxgb3/sge.c           |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c  |  3 +--
 drivers/net/ethernet/nxp/lpc_eth.c                 |  7 +++----
 drivers/net/ethernet/packetengines/hamachi.c       |  4 ++--
 drivers/net/ppp/ppp_synctty.c                      |  2 +-
 drivers/net/usb/asix_common.c                      |  5 ++---
 drivers/net/usb/cdc_ncm.c                          |  4 ++--
 drivers/net/usb/hso.c                              | 13 ++++++-------
 drivers/net/usb/int51x1.c                          |  2 +-
 drivers/net/wireless/ath/ath9k/wmi.c               |  3 +--
 drivers/net/wireless/marvell/libertas/if_sdio.c    |  3 +--
 .../net/wireless/quantenna/qtnfmac/qlink_util.h    |  4 +---
 drivers/net/wireless/realtek/rtlwifi/pci.c         |  3 +--
 .../wireless/realtek/rtlwifi/rtl8192c/fw_common.c  |  3 +--
 .../net/wireless/realtek/rtlwifi/rtl8192de/fw.c    |  3 +--
 .../net/wireless/realtek/rtlwifi/rtl8192ee/fw.c    |  3 +--
 .../net/wireless/realtek/rtlwifi/rtl8723ae/fw.c    |  3 +--
 .../net/wireless/realtek/rtlwifi/rtl8723be/fw.c    |  3 +--
 .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.c    |  6 ++----
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            | 10 +++-------
 drivers/net/wireless/ti/wlcore/rx.c                |  3 +--
 drivers/nfc/pn533/pn533.c                          |  4 ++--
 drivers/staging/octeon/ethernet-tx.c               |  3 +--
 drivers/staging/rtl8188eu/core/rtw_recv.c          |  4 +---
 drivers/staging/rtl8192e/rtllib_rx.c               |  5 ++---
 drivers/staging/rtl8192e/rtllib_softmac.c          | 11 ++++++-----
 drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c  |  4 +---
 .../staging/rtl8192u/ieee80211/ieee80211_softmac.c | 11 +++++------
 drivers/staging/rtl8192u/r819xU_cmdpkt.c           |  3 +--
 drivers/staging/rtl8712/rtl8712_recv.c             |  4 ++--
 drivers/staging/rtl8723bs/os_dep/recv_linux.c      |  4 +---
 drivers/staging/wlan-ng/hfa384x_usb.c              |  2 +-
 drivers/target/iscsi/cxgbit/cxgbit_cm.c            | 12 ++++--------
 drivers/usb/gadget/function/f_ncm.c                | 11 +++++------
 include/linux/skbuff.h                             | 22 ++++++++++++++++++++++
 lib/nlattr.c                                       |  6 +-----
 lib/test_bpf.c                                     |  2 +-
 net/802/garp.c                                     |  2 +-
 net/bluetooth/bnep/core.c                          | 15 ++++++---------
 net/bluetooth/bnep/netdev.c                        | 12 ++++++------
 net/bridge/br_stp_bpdu.c                           |  2 +-
 net/bridge/netfilter/nft_reject_bridge.c           |  6 ++----
 net/dsa/tag_trailer.c                              |  3 +--
 net/hsr/hsr_device.c                               |  6 +++---
 net/irda/irlap_frame.c                             |  5 ++---
 net/mac80211/mlme.c                                | 12 ++++--------
 net/mac80211/tdls.c                                | 19 +++++++++----------
 net/sctp/sm_make_chunk.c                           |  3 +--
 net/vmw_vsock/virtio_transport_common.c            |  5 ++---
 net/x25/x25_subr.c                                 | 16 ++++++++--------
 65 files changed, 166 insertions(+), 218 deletions(-)

-- 
2.7.4
