From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: dsa: Allow switch drivers to indicate number of TX queues
Date: Fri,  1 Sep 2017 16:59:10 -0700
Message-ID: <1504310354-42773-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33129 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752213AbdIBAFQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 20:05:16 -0400
Received: by mail-qk0-f195.google.com with SMTP id k126so1226055qkb.0
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 17:05:16 -0700 (PDT)
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

 drivers/net/dsa/bcm_sf2.c | 12 ++++++++++++
 include/net/dsa.h         |  3 +++
 net/dsa/slave.c           |  8 ++++++--
 net/dsa/tag_brcm.c        |  3 ++-
 4 files changed, 23 insertions(+), 3 deletions(-)

-- 
1.9.1
