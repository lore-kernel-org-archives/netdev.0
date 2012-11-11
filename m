From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH v2 0/3] macb add support for phy gpio interrupt
Date: Mon, 12 Nov 2012 00:56:25 +0100
Message-ID: <1352678188-18647-1-git-send-email-manabian@gmail.com>
Cc: plagnioj@jcrosoft.com, netdev@vger.kernel.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:41155 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355Ab2KKX4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 18:56:33 -0500
Received: by mail-lb0-f174.google.com with SMTP id n3so4243267lbo.19
        for <netdev@vger.kernel.org>; Sun, 11 Nov 2012 15:56:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Main feature of this patch set is phy gpio interrupt for macb.

There is a couple of concerns about this patch series.
* PHY interrupt support has never been supported with macb before but many board have set phy_irq_pin variable. These board will be swapped over to interrupt handing now and while this should work but one can never be 100% certain.
* at91_ether driver supported interrupt on some PHYs which does not have PHY drivers in phylib or doesn't have interrupt support hooked up.

Patch 1 add interrupt handing to a couple of Davicom PHY that is used on most (all?) Atmel eval boards and was also popular on custom boards.

If the 2nd patch breaks any boards there are 2 possible ways to fix the issue. One would be to go back to polling by setting phy_irq_pin to EINVAL. The other would be add a proper PHY driver with interrupt support for the PHY in question.

I would be grateful if anyone can test the 2 first patches on any AT91 boards that they might have access to. If there is any breakage I am more than willing to help out.
Patch series was tested on a custom board with DM9161AEP and AT91RM9200 EMAC.


Last patch in this series is unrelated to the phy stuff. It's is a small fix for macb hw set addr functions when used in at91_ether.

v2: set PHY_HAS_INTERRUPT in phy_driver flags.

Joachim Eastwood (3):
  net/phy/davicom: add irq functions to DM9161E and DM9161A
  net/macb: add support for phy irq via gpio pin
  net/macb: clear unused address register

 drivers/net/ethernet/cadence/macb.c | 20 +++++++++++++++++++-
 drivers/net/ethernet/cadence/macb.h |  6 ++++++
 drivers/net/phy/davicom.c           |  6 ++++++
 3 files changed, 31 insertions(+), 1 deletion(-)

-- 
1.8.0
