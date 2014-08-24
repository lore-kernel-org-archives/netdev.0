From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 00/12] dsa: support for Broadcom Starfighter 2
Date: Sun, 24 Aug 2014 11:44:17 -0700
Message-ID: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemlof.net, jhs@mojatatu.com, linville@tuxdriver.com,
	alexander.h.duyck@intel.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:37512 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517AbaHXSpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 14:45:03 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so18923454pdj.36
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 11:45:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for the Broadcom Starfighter 2 (Roboswitch
successor) using the existing DSA infrastructure. This integrated switch
is heavily used in Set Top Box, Cable gateways and DSL gateways products
from Broadcom, and to a larger extent the new ARM-based Wi-Fi routers although
slightly differently.

Notable changes in v3 is the preliminary patch that reworks the skb->protocol
override helpers for non-Ethertype switch tags, based on feedback from
Alexander Duyck.

The biggest changes from v1 of this patch series are:

- use the new fixed PHY helpers
- improved the switch driver with more complete features (interrupts,
  (RG)MII configuration, memory arrays power down/up, port disabling/enable
  VLAN separation

Future work will focus on bringing the upstream driver in feature parity with
the current downstream driver, including:

- adding Wake-on-LAN support to the switch
- adding suspend/resume callbacks for S2/S3 Power Management modes
- extending the switch register interface to cover BCM5310X SoCs

Florian Fainelli (12):
  net: dsa: rework skb->protocol override helpers
  net: phy: add generic UniMAC MDIO bus driver
  net: dsa: provide a switch device device tree node pointer
  net: dsa: retain a per-port device_node pointer
  net: dsa: allow for more complex PHY setups
  net: dsa: allow switches to work without tagging
  net: dsa: allow drivers to do link adjustment
  net: dsa: allow updating fixed PHY link information
  net: dsa: add Broadcom tag RX/TX handler
  net: dsa: add Broadcom SF2 switch driver
  Documentation: devicetree: update dsa binding with optional properties
  Documentation: devicetree: add Broadcom Starfighter 2 binding

 .../bindings/net/broadcom-mdio-unimac.txt          |  39 ++
 .../devicetree/bindings/net/broadcom-sf2.txt       |  78 +++
 Documentation/devicetree/bindings/net/dsa/dsa.txt  |  17 +
 drivers/net/dsa/Kconfig                            |  11 +
 drivers/net/dsa/Makefile                           |   1 +
 drivers/net/dsa/bcm_sf2.c                          | 626 +++++++++++++++++++++
 drivers/net/dsa/bcm_sf2.h                          | 139 +++++
 drivers/net/dsa/bcm_sf2_regs.h                     | 228 ++++++++
 drivers/net/phy/Kconfig                            |   6 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/mdio-bcm-unimac.c                  | 212 +++++++
 include/linux/netdevice.h                          |  16 +-
 include/net/dsa.h                                  |  30 +-
 include/uapi/linux/if_ether.h                      |   1 +
 net/dsa/Kconfig                                    |   3 +
 net/dsa/Makefile                                   |   1 +
 net/dsa/dsa.c                                      |  15 +
 net/dsa/dsa_priv.h                                 |   8 +
 net/dsa/slave.c                                    | 140 ++++-
 net/dsa/tag_brcm.c                                 | 173 ++++++
 net/ethernet/eth.c                                 |   7 +-
 21 files changed, 1729 insertions(+), 23 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-mdio-unimac.txt
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-sf2.txt
 create mode 100644 drivers/net/dsa/bcm_sf2.c
 create mode 100644 drivers/net/dsa/bcm_sf2.h
 create mode 100644 drivers/net/dsa/bcm_sf2_regs.h
 create mode 100644 drivers/net/phy/mdio-bcm-unimac.c
 create mode 100644 net/dsa/tag_brcm.c

-- 
1.9.1
