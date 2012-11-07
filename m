From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 0/8] at91_ether share stats/address setting with macb
Date: Wed,  7 Nov 2012 19:14:49 +0100
Message-ID: <1352312097-31320-1-git-send-email-manabian@gmail.com>
Cc: plagnioj@jcrosoft.com, netdev@vger.kernel.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:38659 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732Ab2KGSPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 13:15:13 -0500
Received: by mail-la0-f46.google.com with SMTP id h6so1452444lag.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 10:15:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1-2 add support for some special at91_ether features to macb address setting code. This will allow us to have one address setting function that can be shared.

Patch 4 removes the at91_ether address set/get code and make use of the exported functions for macb.

Patch 5 remove the at91_ether statistics functions and replace them with equivalent function from macb.

Patch 6 removes an unused member from the at91_ether/macb private struct.

Patch 7 is a clean up of the print outs from at91_ether.

Patch 8 is a misc clean up patch which fixes some comment and style issues.


Most of the code left in at91_ether now deal with configuration and DMA rx/tx which is hard to share with macb since this is specific for the IP block in AT91RM9200.

Next I'll work on adding PHY GPIO interrupt to the macb driver. at91_ether had this functionality before it began using mdio functions from macb.


Joachim Eastwood (8):
  net/macb: check all address registers sets
  net/macb: support reversed hw addr
  net/macb: export macb_set_hwaddr and macb_get_hwaddr
  net/at91_ether: use macb functions for get/set hwaddr
  net/at91_ether: use stat function from macb
  net/at91_ether: drop board_data private struct member
  net/at91_ether: clean up print outs
  net/at91_ether: fix comment and style issues

 drivers/net/ethernet/cadence/at91_ether.c | 289 +++++++-----------------------
 drivers/net/ethernet/cadence/macb.c       |  54 ++++--
 drivers/net/ethernet/cadence/macb.h       |  10 +-
 3 files changed, 109 insertions(+), 244 deletions(-)

-- 
1.8.0
