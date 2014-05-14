From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 00/11] net: dsa: add support for Broadcom Starfighter 2
Date: Tue, 13 May 2014 22:00:26 -0700
Message-ID: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	nhorman@tuxdriver.com, andy@greyhouse.net, tgraf@suug.ch,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@cumulusnetworks.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:42906 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873AbaENFBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:01:10 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so1207396pbb.11
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 22:01:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patchset adds support for Broadcom's Starfighter 2 switch which is used in
a wide number of recent ARM-based SoCs from different groups within Broadcom.

This switch is usually integrated in that sort of hardware setup:

Integrated GPHY <=> Port 0
External RGMII/MII devices <=> Ports 1 to 6
MoCA PHY <=> Port 7
CPU <=> Port 8

An internal MDIO bus is used to configure the integrated GPHY as well as
external (RG)MII entities which are connected to the switch, hence the UniMAC
MDIO driver

I am sending this as a RFC although most of the dsa changes should not be too
controversial as they basically just leverage Device Tree to help us fetch
platform-specific informations.

The switch driver is fairly simple, but if accepted, future features will be
added (classification engine, Wake-on-LAN support, power management ...)

This switch is used with the recently submitted SYSTEMPORT Ethernet MAC driver
which supports hardare insertion/extraction of switch tags, hence avoiding the
memmove() on the packet contents in both directions, I will send RFC patches
for this as well in case other NICs out there also support a similar feature.

Thanks!

Florian Fainelli (11):
  net: phy: add generic UniMAC MDIO bus driver
  net: dsa: add Broadcom tag hook
  net: dsa: provide a switch device device tree node pointer
  net: dsa: retain a per-port device_node pointer
  net: dsa: allow for more complex PHY setups
  net: dsa: allow switches to working without tagging
  net: dsa: allow drivers to do link adjustment
  net: dsa: allow updating fixed PHY link information
  net: dsa: add Broadcom SF2 switch driver
  net: dsa: add Broadcom tag RX/TX handler
  net: dsa: bcm_sf2: enable Broadcom tags

 .../bindings/net/broadcom-mdio-unimac.txt          |  33 ++
 drivers/net/dsa/Kconfig                            |  11 +
 drivers/net/dsa/Makefile                           |   1 +
 drivers/net/dsa/bcm_sf2.c                          | 497 +++++++++++++++++++++
 drivers/net/dsa/bcm_sf2.h                          | 135 ++++++
 drivers/net/dsa/bcm_sf2_regs.h                     | 207 +++++++++
 drivers/net/phy/Kconfig                            |   6 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/mdio-unimac.c                      | 210 +++++++++
 include/linux/netdevice.h                          |  10 +
 include/net/dsa.h                                  |  23 +
 include/uapi/linux/if_ether.h                      |   1 +
 net/dsa/Kconfig                                    |   3 +
 net/dsa/Makefile                                   |   1 +
 net/dsa/dsa.c                                      |   9 +
 net/dsa/dsa_priv.h                                 |   8 +
 net/dsa/slave.c                                    | 120 ++++-
 net/dsa/tag_brcm.c                                 | 170 +++++++
 net/ethernet/eth.c                                 |   2 +
 19 files changed, 1446 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-mdio-unimac.txt
 create mode 100644 drivers/net/dsa/bcm_sf2.c
 create mode 100644 drivers/net/dsa/bcm_sf2.h
 create mode 100644 drivers/net/dsa/bcm_sf2_regs.h
 create mode 100644 drivers/net/phy/mdio-unimac.c
 create mode 100644 net/dsa/tag_brcm.c

-- 
1.9.1
