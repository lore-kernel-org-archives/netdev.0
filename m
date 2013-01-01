From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/7] fix dev->addr_assign_type setting and related code
Date: Tue,  1 Jan 2013 14:30:12 +0100
Message-ID: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	sassmann@redhat.com, kaber@trash.net, richard@nod.at
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:63597 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228Ab3AANaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2013 08:30:25 -0500
Received: by mail-ea0-f170.google.com with SMTP id d11so5641110eaa.29
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2013 05:30:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c1f79426e2df5ef96fe3e76de6c7606d15bf390b introduced addr_assign_type,
but incorrectly works with the value as if it was a bitfield. This patch corrects this.

Also, new "assign_type" is added to track that the address was changed by
dev_set_mac_address().

Jiri Pirko (7):
  rtnl: use dev_set_mac_address() instead of plain ndo_
  net: call add_device_randomness() only after successful mac change
  net: set dev->addr_assign_type correctly
  net: add address assign type "SET"
  net: remove unnecessary NET_ADDR_RANDOM "bitclean"
  um: net: use eth_hw_addr_random() to generate random mac
  ll_temac: fix mac address setting

 arch/um/drivers/net_kern.c                      | 22 +++++++-----------
 arch/um/include/shared/net_kern.h               |  1 -
 drivers/net/ethernet/adi/bfin_mac.c             |  1 -
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |  3 +--
 drivers/net/ethernet/atheros/atlx/atl1.c        |  2 +-
 drivers/net/ethernet/atheros/atlx/atlx.c        |  1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |  1 -
 drivers/net/ethernet/calxeda/xgmac.c            |  1 -
 drivers/net/ethernet/cisco/enic/enic_main.c     |  1 -
 drivers/net/ethernet/ethoc.c                    |  3 +--
 drivers/net/ethernet/intel/igbvf/netdev.c       |  1 -
 drivers/net/ethernet/lantiq_etop.c              |  2 +-
 drivers/net/ethernet/marvell/pxa168_eth.c       |  1 -
 drivers/net/ethernet/micrel/ks8842.c            |  1 -
 drivers/net/ethernet/micrel/ks8851.c            |  1 -
 drivers/net/ethernet/micrel/ks8851_mll.c        |  1 -
 drivers/net/ethernet/microchip/enc28j60.c       |  1 -
 drivers/net/ethernet/nvidia/forcedeth.c         |  1 -
 drivers/net/ethernet/octeon/octeon_mgmt.c       |  6 ++---
 drivers/net/ethernet/smsc/smsc911x.c            |  1 -
 drivers/net/ethernet/ti/davinci_emac.c          |  1 -
 drivers/net/ethernet/tile/tilepro.c             |  1 -
 drivers/net/ethernet/wiznet/w5100.c             |  1 -
 drivers/net/ethernet/wiznet/w5300.c             |  1 -
 drivers/net/ethernet/xilinx/ll_temac_main.c     | 31 ++++++++++++++-----------
 drivers/net/macvlan.c                           |  1 -
 drivers/net/team/team.c                         |  2 --
 drivers/staging/octeon/ethernet.c               |  6 ++---
 include/linux/etherdevice.h                     |  2 +-
 include/linux/netdevice.h                       |  2 ++
 net/batman-adv/soft-interface.c                 |  1 -
 net/bridge/br_device.c                          |  1 -
 net/core/dev.c                                  |  8 ++++---
 net/core/rtnetlink.c                            | 20 ++--------------
 net/ethernet/eth.c                              |  2 --
 net/openvswitch/vport-internal_dev.c            |  1 -
 36 files changed, 43 insertions(+), 90 deletions(-)

-- 
1.8.0
