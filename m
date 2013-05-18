From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH v2 net-next 0/4] tg3: Add set_eee and get_eee handlers.
Date: Sat, 18 May 2013 09:26:51 -0700
Message-ID: <1368894415-27678-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2043 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752686Ab3ERQ1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 May 2013 12:27:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds support for modifying EEE settings via ethtool. Since this can
impact Link Flap Avoidance, the driver pulls the current hardware settings if
LFA is enabled. This is similar to how we do the link settings to avoid a flap.

v2: Fixes pointed out by Ben Hutchings.
 - Use MDIO_AN_EEE_LPABLE to set the lp_advertised field.
 - Check that tx_lpi_timer is within valid range.

Nithin Nayak Sujir (4):
  tg3: Add ethtool_eee struct and tg3_setup_eee()
  tg3: Add tg3_eee_pull_config() function
  tg3: Simplify tg3_phy_eee_config_ok() by reusing tg3_eee_pull_config()
  tg3: Implement set/get_eee handlers

 drivers/net/ethernet/broadcom/tg3.c | 227 +++++++++++++++++++++++++++---------
 drivers/net/ethernet/broadcom/tg3.h |   2 +
 2 files changed, 173 insertions(+), 56 deletions(-)

-- 
1.8.1.4
