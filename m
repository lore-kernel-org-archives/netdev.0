From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 00/13] dsa: Broadcom Starfighter 2 switch support
Date: Mon, 25 Aug 2014 21:49:28 -0700
Message-ID: <1409028581-17399-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	linville@tuxdriver.com, jhs@mojatatu.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:54501 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755444AbaHZEu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 00:50:27 -0400
Received: by mail-pa0-f48.google.com with SMTP id et14so22341074pad.35
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 21:50:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for the Broadcom Starfighter 2 (Roboswitch
successor) using the existing DSA infrastructure. This integrated switch
is heavily used in Set Top Box, Cable gateways and DSL gateways products
from Broadcom, and to a larger extent the new ARM-based Wi-Fi routers although
slightly differently.

Changes in v4 are the introducing of an indirection level for DSA switch tag
protocols receive and transmit functions.

I intentionnaly did not address one comment from Alexander who suggested to
move port_names and port_dn in a separate structure since that involves
touching arch/arm/ and arch/blackfin/ code which I am not yet comfortable
doing.

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

Florian Fainelli (13):
  net: dsa: reduce number of protocol hooks
  net: phy: add generic UniMAC MDIO bus driver
  net: phy: provide stub for fixed_phy_set_link_update
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
 drivers/net/dsa/bcm_sf2.h                          | 140 +++++
 drivers/net/dsa/bcm_sf2_regs.h                     | 227 ++++++++
 drivers/net/phy/Kconfig                            |   8 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/mdio-bcm-unimac.c                  | 212 +++++++
 include/linux/netdevice.h                          |  26 +-
 include/linux/phy_fixed.h                          |  17 +-
 include/net/dsa.h                                  |  38 +-
 include/uapi/linux/if_ether.h                      |   1 +
 net/dsa/Kconfig                                    |   3 +
 net/dsa/Makefile                                   |   1 +
 net/dsa/dsa.c                                      |  48 +-
 net/dsa/dsa_priv.h                                 |  16 +-
 net/dsa/slave.c                                    | 165 ++++--
 net/dsa/tag_brcm.c                                 | 173 ++++++
 net/dsa/tag_dsa.c                                  |   8 +-
 net/dsa/tag_edsa.c                                 |   8 +-
 net/dsa/tag_trailer.c                              |   8 +-
 net/ethernet/eth.c                                 |   5 +-
 25 files changed, 1766 insertions(+), 111 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-mdio-unimac.txt
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-sf2.txt
 create mode 100644 drivers/net/dsa/bcm_sf2.c
 create mode 100644 drivers/net/dsa/bcm_sf2.h
 create mode 100644 drivers/net/dsa/bcm_sf2_regs.h
 create mode 100644 drivers/net/phy/mdio-bcm-unimac.c
 create mode 100644 net/dsa/tag_brcm.c

-- 
1.9.1
