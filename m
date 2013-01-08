From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] net: init perm_addr properly and on one place
Date: Tue,  8 Jan 2013 12:38:24 +0100
Message-ID: <1357645106-1976-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	ebiederm@xmission.com, amwang@redhat.com, sassmann@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:64722 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab3AHLnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 06:43:46 -0500
Received: by mail-we0-f171.google.com with SMTP id u3so256205wey.16
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 03:43:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far, it has been driver's responsibility to initialize ->perm_addr. Many
of them does not do that though. So benefit from ->addr_assign_type existence
and in case the type is NET_ADDR_PERM, set the ->perm_addr during dev register
process. That allows to remove most of the driver's initializations (that what
happen before register_netdevice() call).

Jiri Pirko (2):
  net: init perm_addr in register_netdevice()
  remove init of dev->perm_addr in drivers

 drivers/infiniband/hw/nes/nes_nic.c                |  1 -
 drivers/net/ethernet/3com/3c59x.c                  |  1 -
 drivers/net/ethernet/8390/ne2k-pci.c               |  1 -
 drivers/net/ethernet/amd/pcnet32.c                 |  3 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |  1 -
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |  1 -
 drivers/net/ethernet/atheros/atlx/atl2.c           |  7 ----
 drivers/net/ethernet/broadcom/b44.c                |  2 -
 drivers/net/ethernet/broadcom/bnx2.c               |  1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  1 -
 drivers/net/ethernet/broadcom/tg3.c                |  3 --
 drivers/net/ethernet/chelsio/cxgb3/t3_hw.c         |  2 -
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  1 -
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |  1 -
 drivers/net/ethernet/dlink/sundance.c              |  1 -
 drivers/net/ethernet/intel/e100.c                  |  3 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c      |  3 +-
 drivers/net/ethernet/intel/e1000e/netdev.c         |  5 +--
 drivers/net/ethernet/intel/igb/igb_main.c          |  3 +-
 drivers/net/ethernet/intel/igbvf/netdev.c          |  2 -
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |  3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  3 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |  2 -
 drivers/net/ethernet/marvell/skge.c                |  1 -
 drivers/net/ethernet/marvell/sky2.c                |  1 -
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  4 +-
 drivers/net/ethernet/natsemi/natsemi.c             |  3 --
 drivers/net/ethernet/neterion/s2io.c               |  1 -
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |  1 -
 drivers/net/ethernet/nvidia/forcedeth.c            |  3 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |  3 +-
 drivers/net/ethernet/qlogic/qla3xxx.c              |  1 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  3 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |  1 -
 drivers/net/ethernet/rdc/r6040.c                   |  3 --
 drivers/net/ethernet/realtek/8139cp.c              |  1 -
 drivers/net/ethernet/realtek/8139too.c             |  1 -
 drivers/net/ethernet/realtek/r8169.c               |  1 -
 drivers/net/ethernet/silan/sc92031.c               | 12 +++---
 drivers/net/ethernet/sis/sis900.c                  | 22 ++---------
 drivers/net/ethernet/sun/niu.c                     | 46 ++++++++++------------
 drivers/net/ethernet/sun/sunvnet.c                 |  2 -
 drivers/net/ethernet/toshiba/tc35815.c             |  1 -
 drivers/net/ethernet/via/via-rhine.c               |  1 -
 drivers/net/ieee802154/fakehard.c                  |  1 -
 drivers/net/usb/kalmia.c                           |  1 -
 drivers/net/usb/rndis_host.c                       |  1 -
 drivers/net/wimax/i2400m/fw.c                      |  1 -
 drivers/net/wireless/ipw2x00/ipw2200.c             |  1 -
 drivers/net/wireless/mwifiex/cfg80211.c            |  1 -
 drivers/net/wireless/orinoco/main.c                |  1 -
 net/core/dev.c                                     |  7 ++++
 52 files changed, 49 insertions(+), 128 deletions(-)

-- 
1.8.1
