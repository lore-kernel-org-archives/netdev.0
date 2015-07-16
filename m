From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/6] net: bcmgenet: PHY initialization rework
Date: Thu, 16 Jul 2015 15:51:13 -0700
Message-ID: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:32885 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbbGPWxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:53:19 -0400
Received: by padck2 with SMTP id ck2so49662502pad.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:53:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Petri, Jaedon,

This patch series reworks how we perform PHY initialization and resets in the
GENET driver. Although this contains mostly fixes, some of the changes are a
bit too intrusive to be backported to 'net' at the moment.

Some of the motivations behind these changes were to reduce the time spent in how
performing MDIO transactions, since it is better to perform then when we have
interrupts enabled. This reduces the bring-up time of GENET from ~600 msecs down
to ~8 msecs, and about the same time for suspend/resume.

Since I do not currently have a system which is not DT-aware, can you (Petri,
Jaedon) give this a try and confirm things keep working as expected?

Thanks!

Florian Fainelli (6):
  net: bcmgenet: Remove excessive PHY reset
  net: bcmgenet: Use correct dev_id for free_irq
  net: bcmgenet: Power on integrated GPHY in bcmgenet_power_up()
  net: bcmgenet: Determine PHY type before scanning MDIO bus
  net: bcmgenet: Delay PHY initialization to bcmgenet_open()
  net: bcmgenet: Remove init parameter from bcmgenet_mii_config

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 33 +++++-----
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  5 +-
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 84 ++++++++++++--------------
 3 files changed, 59 insertions(+), 63 deletions(-)

-- 
2.1.0
