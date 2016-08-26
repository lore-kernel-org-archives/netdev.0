From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next-v3 0/6] net: dsa: Make bcm_sf2 utilize b53_common
Date: Fri, 26 Aug 2016 12:18:28 -0700
Message-ID: <1472239114-26212-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jonas.gorski@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35141 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752302AbcHZTSq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 15:18:46 -0400
Received: by mail-pf0-f196.google.com with SMTP id h186so5312716pfg.2
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 12:18:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series makes the bcm_sf2 driver utilize a large number of the core
functions offered by the b53_common driver since the SWITCH_CORE registers are
mostly register compatible with the switches driven by b53_common.

In order to accomplish that, we just override the dsa_driver_ops callbacks that
we need to. There are still integration specific logic from the bcm_sf2 that we
cannot absorb into b53_common because it is just not there, mostly in the area
of link management and power management, but most of the features are within
b53_common now: VLAN, FDB, bridge

Along the process, we also improve support for the BCM58xx SoCs, since those
also have the same version of the switching IP that 7445 has (for which bcm_sf2
was developed).

Changes in v3:

- rebase against 145dd5f9c88f6ee645662df0be003e8f04bdae93 ("net: flush the
  softnet backlog in process context")

Changes in v2:

- rebased against "net: dsa: rename switch operations structure"

Florian Fainelli (6):
  net: dsa: b53: Initialize ds->ops in b53_switch_alloc
  net: dsa: b53: Prepare to support 7445 switch
  net: dsa: b53: Define SF2 MIB layout
  net: dsa: b53: Add JOIN_ALL_VLAN support
  net: dsa: bcm_sf2: Utilize core B53 driver when possible
  net: dsa: bcm_sf2: Remove duplicate code

 drivers/net/dsa/Kconfig          |   1 +
 drivers/net/dsa/b53/b53_common.c | 108 ++++-
 drivers/net/dsa/b53/b53_priv.h   |   7 +
 drivers/net/dsa/b53/b53_regs.h   |   3 +
 drivers/net/dsa/bcm_sf2.c        | 932 +++++++--------------------------------
 drivers/net/dsa/bcm_sf2.h        |  82 +---
 drivers/net/dsa/bcm_sf2_regs.h   | 122 -----
 7 files changed, 288 insertions(+), 967 deletions(-)

-- 
2.7.4
