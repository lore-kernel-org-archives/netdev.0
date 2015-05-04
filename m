From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 0/8] Convert some skb_<foo> functions to void
Date: Mon,  4 May 2015 13:05:44 -0700
Message-ID: <cover.1430769294.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0113.hostedemail.com ([216.40.44.113]:42964 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752117AbbEDUGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:06:04 -0400
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay03.hostedemail.com (Postfix) with ESMTP id 789176A93A
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:03 +0000 (UTC)
Received: from joe-laptop.perches.com (pool-173-51-221-2.lsanca.fios.verizon.net [173.51.221.2])
	(Authenticated sender: joe@perches.com)
	by omf02.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:02 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

unsigned char * return values are sometimes awkward to work with.
Changing the return to void * is sometimes clearer.

The only uses of the return type is to do sets like
    *skb_puts(skb, 1) = char;
    
Adding another function specifically for that purpose allows the return
type to become void.

Joe Perches (8):
  skb: Add skb_put_uchar
  treewide: Use skb_put_uchar
  skb: Add skb_push_uchar
  treewide: Use skb_push_uchar
  skbuff: Convert skb_put to return void *
  treewide: Remove unnecessary casts from skb_puts
  skbuff: Convert skb_push to return void *
  treewide: Remove unnecessary casts from skb_push

 drivers/atm/atmtcp.c                               |   4 +-
 drivers/atm/solos-pci.c                            |  14 +--
 drivers/bluetooth/bfusb.c                          |   2 +-
 drivers/bluetooth/bluecard_cs.c                    |   4 +-
 drivers/bluetooth/bpa10x.c                         |   2 +-
 drivers/bluetooth/bt3c_cs.c                        |   4 +-
 drivers/bluetooth/btmrvl_main.c                    |   2 +-
 drivers/bluetooth/btuart_cs.c                      |   4 +-
 drivers/bluetooth/btusb.c                          |   6 +-
 drivers/bluetooth/btwilink.c                       |   2 +-
 drivers/bluetooth/dtl1_cs.c                        |   4 +-
 drivers/bluetooth/hci_ath.c                        |   2 +-
 drivers/bluetooth/hci_bcm.c                        |   2 +-
 drivers/bluetooth/hci_bcsp.c                       |  12 +-
 drivers/bluetooth/hci_h4.c                         |   2 +-
 drivers/bluetooth/hci_h5.c                         |   4 +-
 drivers/bluetooth/hci_ll.c                         |   4 +-
 drivers/bluetooth/hci_vhci.c                       |   6 +-
 drivers/firewire/net.c                             |   8 +-
 drivers/infiniband/hw/cxgb3/cxio_hal.c             |   4 +-
 drivers/infiniband/hw/cxgb3/iwch_cm.c              |  30 ++---
 drivers/infiniband/hw/cxgb3/iwch_qp.c              |   4 +-
 drivers/infiniband/hw/cxgb4/cm.c                   |  26 ++---
 drivers/infiniband/ulp/ipoib/ipoib_main.c          |   2 +-
 drivers/isdn/act2000/capi.c                        |   4 +-
 drivers/isdn/act2000/module.c                      |   2 +-
 drivers/isdn/hisax/isar.c                          |   6 +-
 drivers/isdn/i4l/isdn_audio.c                      |   4 +-
 drivers/media/dvb-core/dvb_net.c                   |   2 +-
 drivers/media/radio/wl128x/fmdrv_common.c          |   4 +-
 drivers/net/arcnet/arc-rawmode.c                   |   2 +-
 drivers/net/arcnet/capmode.c                       |   2 +-
 drivers/net/arcnet/rfc1051.c                       |   2 +-
 drivers/net/arcnet/rfc1201.c                       |   2 +-
 drivers/net/bonding/bond_3ad.c                     |   4 +-
 drivers/net/can/dev.c                              |   4 +-
 drivers/net/ethernet/allwinner/sun4i-emac.c        |   2 +-
 drivers/net/ethernet/broadcom/bcmsysport.c         |   2 +-
 drivers/net/ethernet/chelsio/cxgb/sge.c            |   2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |   2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |   2 +-
 drivers/net/ethernet/davicom/dm9000.c              |   2 +-
 drivers/net/ethernet/dnet.c                        |   2 +-
 drivers/net/ethernet/freescale/gianfar.c           |   2 +-
 drivers/net/ethernet/hp/hp100.c                    |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c   |   4 +-
 drivers/net/ethernet/micrel/ks8842.c               |   4 +-
 drivers/net/ethernet/sfc/selftest.c                |   3 +-
 drivers/net/ethernet/sun/niu.c                     |   2 +-
 drivers/net/ethernet/sun/sunvnet.c                 |   2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_net.c       |   2 +-
 drivers/net/hippi/rrunner.c                        |   2 +-
 drivers/net/ppp/ppp_generic.c                      |   2 +-
 drivers/net/ppp/pppoe.c                            |   2 +-
 drivers/net/usb/cdc_ncm.c                          |   2 +-
 drivers/net/usb/gl620a.c                           |   2 +-
 drivers/net/usb/lg-vl600.c                         |   2 +-
 drivers/net/usb/net1080.c                          |   6 +-
 drivers/net/usb/zaurus.c                           |   8 +-
 drivers/net/vxlan.c                                |   2 +-
 drivers/net/wan/hdlc_ppp.c                         |   2 +-
 drivers/net/wimax/i2400m/netdev.c                  |   2 +-
 drivers/net/wireless/adm8211.c                     |   2 +-
 drivers/net/wireless/airo.c                        |   4 +-
 drivers/net/wireless/ath/ar5523/ar5523.c           |   4 +-
 drivers/net/wireless/ath/ath6kl/debug.c            |   2 +-
 drivers/net/wireless/ath/ath6kl/htc_pipe.c         |   9 +-
 drivers/net/wireless/ath/ath9k/channel.c           |   2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |   2 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |  12 +-
 drivers/net/wireless/ath/ath9k/wmi.c               |   4 +-
 drivers/net/wireless/ath/carl9170/tx.c             |   2 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |   2 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   2 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   2 +-
 drivers/net/wireless/cw1200/txrx.c                 |   2 +-
 drivers/net/wireless/hostap/hostap_80211_rx.c      |   8 +-
 drivers/net/wireless/hostap/hostap_ap.c            |   4 +-
 drivers/net/wireless/hostap/hostap_main.c          |   3 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |   2 +-
 drivers/net/wireless/ipw2x00/libipw_tx.c           |   6 +-
 drivers/net/wireless/libertas/rx.c                 |   2 +-
 drivers/net/wireless/libertas_tf/main.c            |   2 +-
 drivers/net/wireless/mac80211_hwsim.c              |  12 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |   2 +-
 drivers/net/wireless/mwifiex/tdls.c                |  30 ++---
 drivers/net/wireless/orinoco/main.c                |   7 +-
 drivers/net/wireless/p54/fwio.c                    |  43 ++++---
 drivers/net/wireless/p54/txrx.c                    |   4 +-
 drivers/net/wireless/prism54/islpci_eth.c          |   5 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |   2 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |   6 +-
 drivers/net/wireless/rtlwifi/base.c                |   4 +-
 drivers/net/wireless/rtlwifi/pci.c                 |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/fw.c        |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.c        |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192se/fw.c        |   5 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c        |   4 +-
 drivers/net/wireless/rtlwifi/rtl8723be/fw.c        |   4 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/fw.c        |   8 +-
 drivers/net/wireless/ti/wl1251/tx.c                |   3 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |   4 +-
 drivers/net/wireless/ti/wlcore/main.c              |   2 +-
 drivers/net/wireless/ti/wlcore/tx.c                |   3 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |   3 +-
 drivers/nfc/microread/i2c.c                        |   6 +-
 drivers/nfc/microread/microread.c                  |   8 +-
 drivers/nfc/nfcwilink.c                            |   3 +-
 drivers/nfc/pn533.c                                |  30 ++---
 drivers/nfc/pn544/i2c.c                            |   8 +-
 drivers/nfc/pn544/pn544.c                          |   8 +-
 drivers/nfc/port100.c                              |   4 +-
 drivers/nfc/st21nfca/i2c.c                         |  10 +-
 drivers/nfc/st21nfca/st21nfca.c                    |   6 +-
 drivers/nfc/st21nfca/st21nfca_dep.c                |  30 ++---
 drivers/nfc/st21nfcb/ndlc.c                        |   2 +-
 drivers/s390/net/qeth_l2_main.c                    |   3 +-
 drivers/s390/net/qeth_l3_main.c                    |   6 +-
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c                  |   2 +-
 drivers/scsi/fcoe/fcoe.c                           |   2 +-
 drivers/scsi/fcoe/fcoe_ctlr.c                      |   4 +-
 drivers/scsi/fnic/fnic_fcs.c                       |   7 +-
 drivers/staging/ft1000/ft1000-pcmcia/ft1000_hw.c   |   2 +-
 drivers/staging/ft1000/ft1000-usb/ft1000_hw.c      |   2 +-
 drivers/staging/ozwpan/ozpd.c                      |   6 +-
 drivers/staging/ozwpan/ozproto.c                   |   2 +-
 drivers/staging/rtl8188eu/core/rtw_recv.c          |   2 +-
 drivers/staging/rtl8192e/rtl819x_BAProc.c          |  10 +-
 drivers/staging/rtl8192e/rtllib_rx.c               |   4 +-
 drivers/staging/rtl8192e/rtllib_softmac.c          |  34 ++----
 drivers/staging/rtl8192e/rtllib_tx.c               |   3 +-
 drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c  |   2 +-
 .../staging/rtl8192u/ieee80211/ieee80211_softmac.c |  21 ++--
 drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c  |   2 +-
 .../staging/rtl8192u/ieee80211/rtl819x_BAProc.c    |   8 +-
 drivers/staging/rtl8712/rtl8712_recv.c             |   2 +-
 drivers/staging/wlan-ng/p80211conv.c               |  14 +--
 drivers/usb/gadget/function/f_ncm.c                |  19 ++--
 drivers/usb/gadget/function/rndis.c                |   2 +-
 include/linux/if_vlan.h                            |   2 +-
 include/linux/skbuff.h                             |   6 +-
 lib/nlattr.c                                       |   2 +-
 net/802/fc.c                                       |   4 +-
 net/802/fddi.c                                     |   2 +-
 net/802/hippi.c                                    |   2 +-
 net/8021q/vlan_dev.c                               |   2 +-
 net/appletalk/ddp.c                                |   4 +-
 net/atm/clip.c                                     |   2 +-
 net/atm/signaling.c                                |   2 +-
 net/ax25/af_ax25.c                                 |   2 +-
 net/batman-adv/icmp_socket.c                       |   2 +-
 net/bluetooth/hci_request.c                        |   2 +-
 net/bluetooth/hci_sock.c                           |  12 +-
 net/bluetooth/hidp/core.c                          |   2 +-
 net/bluetooth/l2cap_core.c                         |  16 +--
 net/bluetooth/mgmt_util.c                          |  10 +-
 net/bluetooth/rfcomm/core.c                        |   4 +-
 net/bridge/netfilter/nft_reject_bridge.c           |   6 +-
 net/core/netpoll.c                                 |   4 +-
 net/core/pktgen.c                                  |  38 ++++---
 net/core/skbuff.c                                  |  48 ++++++++
 net/dccp/options.c                                 |   2 +-
 net/decnet/dn_dev.c                                |   6 +-
 net/decnet/dn_nsp_out.c                            |  18 +--
 net/ethernet/eth.c                                 |   2 +-
 net/ipv4/arp.c                                     |   2 +-
 net/ipv4/igmp.c                                    |   6 +-
 net/ipv4/ip_gre.c                                  |   2 +-
 net/ipv4/ipconfig.c                                |   2 +-
 net/ipv4/ipmr.c                                    |   2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c                  |  10 +-
 net/ipv4/netfilter/nf_reject_ipv4.c                |   4 +-
 net/ipv6/exthdrs.c                                 |   4 +-
 net/ipv6/ip6_gre.c                                 |   2 +-
 net/ipv6/mcast.c                                   |   6 +-
 net/ipv6/ndisc.c                                   |   8 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c                 |  10 +-
 net/ipv6/netfilter/nf_reject_ipv6.c                |   2 +-
 net/ipv6/tcp_ipv6.c                                |   2 +-
 net/irda/irlap_frame.c                             |  17 ++-
 net/iucv/af_iucv.c                                 |   3 +-
 net/key/af_key.c                                   | 124 +++++++++------------
 net/mac80211/agg-rx.c                              |   2 +-
 net/mac80211/agg-tx.c                              |   4 +-
 net/mac80211/cfg.c                                 |   4 +-
 net/mac80211/debugfs_netdev.c                      |   2 +-
 net/mac80211/ht.c                                  |   4 +-
 net/mac80211/mesh.c                                |   4 +-
 net/mac80211/mesh_hwmp.c                           |   4 +-
 net/mac80211/mesh_plink.c                          |   2 +-
 net/mac80211/mesh_ps.c                             |   2 +-
 net/mac80211/mlme.c                                |   4 +-
 net/mac80211/rx.c                                  |   4 +-
 net/mac80211/spectmgmt.c                           |   2 +-
 net/mac80211/sta_info.c                            |   2 +-
 net/mac80211/status.c                              |   2 +-
 net/mac80211/tdls.c                                |  14 +--
 net/mac80211/tx.c                                  |  11 +-
 net/mac80211/util.c                                |   4 +-
 net/mac80211/wpa.c                                 |   6 +-
 net/netfilter/nfnetlink_log.c                      |   2 +-
 net/netfilter/nfnetlink_queue_core.c               |   2 +-
 net/netlink/af_netlink.c                           |   2 +-
 net/nfc/digital_core.c                             |   4 +-
 net/nfc/digital_dep.c                              |   2 +-
 net/nfc/digital_technology.c                       |  20 ++--
 net/nfc/hci/core.c                                 |   4 +-
 net/nfc/hci/llc_shdlc.c                            |  12 +-
 net/nfc/llcp_commands.c                            |   2 +-
 net/nfc/nci/core.c                                 |   2 +-
 net/nfc/nci/data.c                                 |   2 +-
 net/nfc/nci/hci.c                                  |   6 +-
 net/nfc/nci/spi.c                                  |  12 +-
 net/phonet/datagram.c                              |   2 +-
 net/sctp/output.c                                  |   2 +-
 net/sctp/sm_make_chunk.c                           |   2 +-
 net/sctp/sm_statefuns.c                            |   4 +-
 net/sctp/ulpevent.c                                |  29 ++---
 net/wireless/util.c                                |   2 +-
 223 files changed, 674 insertions(+), 706 deletions(-)

-- 
2.1.4
