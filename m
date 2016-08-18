From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/5] net: dsa: bcm_sf2: Platform conversion
Date: Thu, 18 Aug 2016 15:30:11 -0700
Message-ID: <1471559416-13249-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35938 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753627AbcHSE3B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 00:29:01 -0400
Received: by mail-pa0-f65.google.com with SMTP id ez1so2797976pab.3
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 21:29:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series converts the bcm_sf2 driver from a traditional DSA driver
into a platform_device driver and makes it use the new DSA binding that Andrew
introduced in the latest merge window.

Prior attempts used to coerce the code in net/dsa/dsa2.c to accept the old
binding, while really there is only one broken single user out there: bcm_sf2,
so instead, just assume the new DT binding is deployed and use it accordingly.

Florian Fainelli (5):
  net: dsa: Export suspend/resume functions
  Documentation: dt: bindings: Update Broadcom 7445 switch document
  net: dsa: bcm_sf2: Make it a real platform device driver
  net: dsa: bcm_sf2: Use device managed helpers
  net: dsa: bcm_sf2: Remove probing through old DSA binding

 .../bindings/net/brcm,bcm7445-switch-v4.0.txt      |  45 ++++-
 drivers/net/dsa/bcm_sf2.c                          | 221 ++++++++++++---------
 include/net/dsa.h                                  |  14 ++
 net/dsa/dsa.c                                      |   7 +-
 4 files changed, 189 insertions(+), 98 deletions(-)

-- 
2.7.4
