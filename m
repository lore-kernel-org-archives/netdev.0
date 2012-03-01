From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 0/7] validate MAC address before call .ndo_set_mac_address
Date: Thu,  1 Mar 2012 17:52:20 +0100
Message-ID: <1330620747-4047-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Validate the given MAC address directly in dev_set_mac_address()
if a .ndo_validate_addr function is available before calling
the .ndo_set_mac_address function.

Changed .ndo_validate_addr to take a second parameter containing
a sockaddr struct to be checked instead of the net_device dev_addr.
The behaviour of .ndo_validate_addr is now: if the second parameter
is NULL the net_device->dev_addr gets validate, if != NULL
the given parameter/sockaddr gets validated instead.

This patch series include adaptations for some drivers which
use .ndo_set_mac_address functions directly - to prevent double
checks and to enable validations via .ndo_validate_addr.

If these patches get accepted, an other series will follow
to cleanup the validation checks in the .ndo_set_mac_address
functions.

v2: - merged two patches to ensure kernel build at each stage
    - collect parameter for bnx2x_is_valid_ether_addr() and
      is_valid_ether_addr() and call them only once at end of
      the functions.

Danny Kukawka (7):
  net: validate MAC address directly in dev_set_mac_address()
  cris/eth_v10: use dev_set_mac_address() instead of
    e100_set_mac_address()
  bcm63xx_enet: use dev_set_mac_address() instead of
    bcm_enet_set_mac_address()
  ethoc: add .ndo_validate_addr to net_device_ops
  lantiq_etop: use dev_set_mac_address() instead of
    ltq_etop_set_mac_address()
  neterion/s2io: fix s2io_set_mac_addr() to prevent double checks
  octeon: use dev_set_mac_address() instead of
    octeon_mgmt_set_mac_address()

 drivers/net/cris/eth_v10.c                       |    3 +--
 drivers/net/ethernet/broadcom/bcm63xx_enet.c     |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   11 +++++++++--
 drivers/net/ethernet/ethoc.c                     |    4 +---
 drivers/net/ethernet/lantiq_etop.c               |    4 ++--
 drivers/net/ethernet/neterion/s2io.c             |    5 +----
 drivers/net/ethernet/octeon/octeon_mgmt.c        |    6 ++----
 include/linux/etherdevice.h                      |    2 +-
 include/linux/netdevice.h                        |    7 +++++--
 net/core/dev.c                                   |    7 ++++++-
 net/ethernet/eth.c                               |   13 +++++++++----
 11 files changed, 38 insertions(+), 26 deletions(-)

-- 
1.7.8.3
