From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 00/13] Protect dev_kfree_skb_irq from NULL and remove unnecessary NULL checks
Date: Sat,  2 Nov 2013 19:17:41 +0530
Message-ID: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	schwidefsky@de.ibm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	IvDoorn@gmail.com, sbhatewara@vmware.com, samuel@sortiz.org,
	chas@cmf.nrl.navy.mil, roland@kernel.org, isdn@linux-pingi.de,
	jcliburn@gmail.com, benve@cisco.com, ssujith@cisco.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shahed.shaikh@qlogic.com, joe@perches.com, apw@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:44867 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474Ab3KBNr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 09:47:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_kfree_skb_irq is not NULL safe. The following patch checks skb for NULL in
dev_kfree_skb_irq. 

At many places we check for NULL before calling dev_kfree_skb_*(). Moving the
check to dev_kfree_skb_irq_*() removes the reddundant if condition and makes
code simpler. 

Also dev_kfree_skb_any either calls dev_kfree_skb_irq or dev_kfree_skb
depending on where your code is running. dev_kfree_skb is NULL safe but
dev_kfree_skb_irq is not. This patch fixes it. 

Govindarajulu Varadarajan (13):
  net: Check skb for NULL in dev_kfree_skb_irq
  driver: net: remove unnecessary skb NULL check before calling    
    dev_kfree_skb_irq
  driver: atm: remove unnecessary skb NULL check before calling    
    dev_kfree_skb_irq
  driver: staging:  remove unnecessary skb NULL check before calling
    dev_kfree_skb_irq
  driver: net: remove unnecessary skb NULL check before calling    
    dev_kfree_skb_irq
  driver: net: remove unnecessary NULL check before dev_kfree_skb_any
  driver: staging: remove unnecessary NULL check before
    dev_kfree_skb_any
  driver: isdn: remove unnecessary NULL check before dev_kfree_skb_any
  driver: s390: remove unnecessary NULL check before dev_kfree_skb_any
  driver: infiniband: remove unnecessary NULL check before    
    dev_kfree_skb_any
  driver: usb: remove unnecessary NULL check before dev_kfree_skb_any
  driver: net: fix space before '(' and remove extra variable
  scripts/checkpatch.pl: Add dev_kfree_skb*(NULL) check to ckeckpatch

 drivers/atm/eni.c                                    |  2 +-
 drivers/infiniband/hw/amso1100/c2.c                  |  6 ++----
 drivers/infiniband/hw/nes/nes_hw.c                   |  3 +--
 drivers/isdn/gigaset/ser-gigaset.c                   |  3 +--
 drivers/isdn/hisax/hfc_usb.c                         |  6 ++----
 drivers/isdn/hisax/icc.c                             |  6 ++----
 drivers/isdn/hisax/ipacx.c                           |  6 ++----
 drivers/isdn/hisax/isac.c                            |  6 ++----
 drivers/isdn/hisax/st5481_b.c                        |  6 ++----
 drivers/isdn/hisax/w6692.c                           |  6 ++----
 drivers/net/ethernet/amd/lance.c                     |  9 +++------
 drivers/net/ethernet/amd/ni65.c                      |  6 ++----
 drivers/net/ethernet/atheros/alx/main.c              |  6 ++----
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c      | 10 ++++------
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c      | 12 ++++--------
 drivers/net/ethernet/atheros/atlx/atl1.c             | 12 ++++--------
 drivers/net/ethernet/cisco/enic/enic_main.c          |  3 +--
 drivers/net/ethernet/freescale/fec_main.c            |  6 ++----
 drivers/net/ethernet/hp/hp100.c                      |  3 +--
 drivers/net/ethernet/icplus/ipg.c                    |  6 ++----
 drivers/net/ethernet/intel/e1000/e1000_main.c        |  6 ++----
 drivers/net/ethernet/intel/e1000e/netdev.c           | 15 +++++----------
 drivers/net/ethernet/intel/igb/igb_ptp.c             |  6 ++----
 drivers/net/ethernet/intel/igbvf/netdev.c            |  6 ++----
 drivers/net/ethernet/intel/ixgb/ixgb_main.c          |  6 ++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c         |  6 ++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c    |  6 ++----
 drivers/net/ethernet/korina.c                        | 12 ++++--------
 drivers/net/ethernet/marvell/pxa168_eth.c            |  3 +--
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 12 ++++--------
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c |  9 +++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c     |  6 ++----
 drivers/net/ethernet/seeq/sgiseeq.c                  |  6 ++----
 drivers/net/ethernet/sgi/ioc3-eth.c                  | 11 +++--------
 drivers/net/ethernet/smsc/smsc9420.c                 |  3 +--
 drivers/net/ethernet/sun/sunbmac.c                   | 12 ++++--------
 drivers/net/ethernet/ti/cpmac.c                      |  6 ++----
 drivers/net/ethernet/xilinx/ll_temac_main.c          |  3 +--
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c    |  6 ++----
 drivers/net/hamradio/scc.c                           | 10 +++-------
 drivers/net/hyperv/netvsc_drv.c                      |  3 +--
 drivers/net/irda/vlsi_ir.c                           | 15 +++++----------
 drivers/net/usb/cdc_mbim.c                           |  3 +--
 drivers/net/usb/cdc_ncm.c                            | 15 +++++----------
 drivers/net/usb/lg-vl600.c                           |  6 ++----
 drivers/net/usb/usbnet.c                             |  3 +--
 drivers/net/vmxnet3/vmxnet3_drv.c                    |  9 +++------
 drivers/net/wireless/ath/ar5523/ar5523.c             |  6 ++----
 drivers/net/wireless/ath/ath10k/mac.c                |  6 ++----
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c        |  3 +--
 drivers/net/wireless/ath/ath9k/main.c                |  6 ++----
 drivers/net/wireless/ath/ath9k/recv.c                |  6 ++----
 drivers/net/wireless/ath/wil6210/txrx.c              |  6 ++----
 drivers/net/wireless/b43/main.c                      |  9 +++------
 drivers/net/wireless/b43legacy/main.c                |  9 +++------
 drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c  |  3 +--
 drivers/net/wireless/brcm80211/brcmsmac/main.c       | 12 ++++--------
 drivers/net/wireless/ipw2x00/ipw2200.c               |  6 ++----
 drivers/net/wireless/ipw2x00/libipw_rx.c             |  3 +--
 drivers/net/wireless/ipw2x00/libipw_tx.c             |  3 +--
 drivers/net/wireless/mwifiex/init.c                  |  3 +--
 drivers/s390/net/claw.c                              |  6 ++----
 drivers/s390/net/ctcm_mpc.c                          |  6 ++----
 drivers/s390/net/qeth_core_main.c                    |  6 ++----
 drivers/staging/rtl8187se/ieee80211/ieee80211_rx.c   |  3 +--
 drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c   |  3 +--
 drivers/staging/rtl8188eu/core/rtw_recv.c            |  6 ++----
 drivers/staging/rtl8192e/rtllib_rx.c                 |  3 +--
 drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c    |  3 +--
 drivers/staging/rtl8712/recv_linux.c                 |  3 +--
 drivers/staging/rtl8712/rtl8712_recv.c               |  6 ++----
 drivers/staging/rtl8712/xmit_linux.c                 |  3 +--
 drivers/staging/sbe-2t3e3/dc.c                       | 12 ++++--------
 drivers/staging/slicoss/slicoss.c                    |  3 +--
 drivers/usb/gadget/f_phonet.c                        |  6 ++----
 drivers/usb/gadget/u_ether.c                         |  6 ++----
 net/core/dev.c                                       |  2 +-
 scripts/checkpatch.pl                                |  2 +-
 78 files changed, 163 insertions(+), 324 deletions(-)

-- 
1.8.4.2
