From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 RESEND 0/4] net: dsa: Allow switch drivers to indicate number of TX queues
Date: Sun,  3 Sep 2017 20:26:59 -0700
Message-ID: <20170904032703.4593-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:37278 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753124AbdIDD1J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 23:27:09 -0400
Received: by mail-oi0-f67.google.com with SMTP id b184so4158913oih.4
        for <netdev@vger.kernel.org>; Sun, 03 Sep 2017 20:27:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series extracts the parts of the patch set that are likely not to be
controversial and actually bringing multi-queue support to DSA-created network
devices.

With these patches, we can now use sch_multiq as documented under
Documentation/networking/multique.txt and let applications dedice the switch
port output queue they want to use. Currently only Broadcom tags utilize that
information.

Resending based on David's feedback regarding the patches not in patchwork.

Changes in v2:
- use a proper define for the number of TX queues in bcm_sf2.c (Andrew)

Changes from RFC:

- dropped the ability to configure RX queues since we don't do anything with
  those just yet
- dropped the patches that dealt with binding the DSA slave network devices
  queues with their master network devices queues this will be worked on
  separately.

Florian Fainelli (4):
  net: dsa: Allow switch drivers to indicate number of TX queues
  net: dsa: tag_brcm: Set output queue from skb queue mapping
  net: dsa: bcm_sf2: Advertise number of egress queues
  net: dsa: bcm_sf2: Configure IMP port TC2QOS mapping

 drivers/net/dsa/bcm_sf2.c      | 14 +++++++++++++-
 drivers/net/dsa/bcm_sf2_regs.h |  3 +++
 include/net/dsa.h              |  3 +++
 net/dsa/slave.c                |  8 ++++++--
 net/dsa/tag_brcm.c             |  3 ++-
 5 files changed, 27 insertions(+), 4 deletions(-)

-- 
2.11.0
