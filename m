From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 0/5] net: dsa: LAG support
Date: Sun,  1 Oct 2017 12:46:34 -0700
Message-ID: <20171001194639.8647-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        jiri@resnulli.us, idosch@mellanox.com, Woojung.Huh@microchip.com,
        john@phrozen.org, sean.wang@mediatek.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:54298 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751355AbdJATqr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 15:46:47 -0400
Received: by mail-oi0-f65.google.com with SMTP id u130so6265660oib.11
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 12:46:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series is sent as RFC since I have only been able to test LAG
with dsa-loop and not with real HW yet (that should be tomorrow). I also
looked at how the Marvell DSDT API is defined for adding ports to "trunk"
groups and the API proposed here should work there too. Can't speak about
QCA, Mediatek or KSZ switches though.

Few open questions that may need solving now or later:

- on Broadcom switches, we should allow enslaving a port as a LAG group
  member if its speed does not match that of the other members of the group

- not sure what to do with a switch fabric, naively, if adding two ports
  of two distinct switches as a LAG group, we may have to propagate that
  to "dsa" cross-chip interfaces as well

Thanks!

Florian Fainelli (5):
  net: dsa: Add infrastructure to support LAG
  net: dsa: b53: Define MAC trunking/bonding registers
  net: dsa: b53: Add support for LAG
  net: dsa: bcm_sf2: Add support for LAG
  net: dsa: loop: Add support for LAG

 drivers/net/dsa/b53/b53_common.c |  94 ++++++++++++++++++++++-
 drivers/net/dsa/b53/b53_priv.h   |   6 ++
 drivers/net/dsa/b53/b53_regs.h   |  18 +++++
 drivers/net/dsa/bcm_sf2.c        |   3 +
 drivers/net/dsa/dsa_loop.c       |  54 +++++++++++++-
 include/net/dsa.h                |  25 +++++++
 net/dsa/dsa2.c                   |  12 +++
 net/dsa/dsa_priv.h               |   7 ++
 net/dsa/port.c                   |  92 +++++++++++++++++++++++
 net/dsa/slave.c                  | 157 ++++++++++++++++++++++++++++++++++++---
 net/dsa/switch.c                 |  30 ++++++++
 11 files changed, 484 insertions(+), 14 deletions(-)

-- 
2.11.0
