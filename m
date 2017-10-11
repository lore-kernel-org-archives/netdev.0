From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/5] Enable ACB for bcm_sf2 and bcmsysport
Date: Wed, 11 Oct 2017 10:57:47 -0700
Message-ID: <20171011175752.22030-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:37286 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751659AbdJKR7d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 13:59:33 -0400
Received: by mail-qt0-f196.google.com with SMTP id 32so670917qtp.4
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 10:59:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series enables Broadcom's Advanced Congestion Buffering mechanism
which requires cooperation between the CPU/Management Ethernet MAC controller
and the switch.

I took the notifier approach because ultimately the information we need to
carry to the master network device is DSA specific and I saw little room for
generalizing beyond what DSA requires. Chances are that this is highly specific
to the Broadcom HW as I don't know of any HW out there that supports something
nearly similar for similar or identical needs.

Florian Fainelli (5):
  net: dsa: Add support for DSA specific notifiers
  net: dsa: tag_brcm: Indicate to master netdevice port + queue
  net: systemport: Establish lower/upper queue mapping
  net: dsa: bcm_sf2: Turn on ACB at the switch level
  net: systemport: Turn on ACB at the SYSTEMPORT level

 drivers/net/dsa/bcm_sf2.c                  |  30 ++++++++
 drivers/net/dsa/bcm_sf2_regs.h             |  23 ++++++
 drivers/net/ethernet/broadcom/bcmsysport.c | 119 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bcmsysport.h |  11 ++-
 include/net/dsa.h                          |  50 ++++++++++++
 net/dsa/dsa.c                              |  23 ++++++
 net/dsa/slave.c                            |  13 ++++
 net/dsa/tag_brcm.c                         |   6 ++
 8 files changed, 270 insertions(+), 5 deletions(-)

-- 
2.9.3
