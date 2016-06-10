From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: dsa: bcm_sf2: add VLAN support
Date: Thu,  9 Jun 2016 17:42:04 -0700
Message-ID: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, jiri@mellanox.com,
	idosch@mellanox.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33083 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbcFJAmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 20:42:36 -0400
Received: by mail-pf0-f194.google.com with SMTP id c74so3814056pfb.0
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 17:42:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This is long overdue, finally add support for VLANs in the Broadcom Starfigther
2 switch driver.

There are a few things that make us differ from e.g; mv88e6xxx.c:

- we keep a software cache of which VLANs are enabled and which are not to
  dramatically speed up the VLAN dump operation, we do not have any HW operation
  which would only return the list of valid VLAN entries, they would have to be
  all queried one by one, with 4K vlans, this takes a while

- the default behavior is equivalent to setting VLAN filtering to 1, still working
  on implementing a proper port_vlan_filtering callback, but I figured the most
  conservative behavior is probably okay anyway

- without enabling VLANs, the default behavior is to receive any 802.1q frames
  (per the DSA documentation), however, once we start enabling VLAN support, if
  an interface leaves the bridge, we still want it to receive all 802.1q frames
  so we utiliez the "Join all VLAN" feature of the switch to perform that

Thanks!

Florian Fainelli (4):
  net: dsa: bcm_sf2: Split fast age into a helper function
  net: dsa: bcm_sf2: Move setup function at the far end
  net: dsa: bcm_sf2: Add VLAN registers definitions
  net: dsa: bcm_sf2: Add VLAN support

 drivers/net/dsa/bcm_sf2.c      | 524 +++++++++++++++++++++++++++++++----------
 drivers/net/dsa/bcm_sf2.h      |  10 +
 drivers/net/dsa/bcm_sf2_regs.h |  70 ++++++
 3 files changed, 477 insertions(+), 127 deletions(-)

-- 
2.7.4
