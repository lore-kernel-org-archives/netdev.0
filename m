From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v5 0/3] add fec support for imx6q
Date: Fri, 23 Sep 2011 20:12:45 +0800
Message-ID: <1316779968-21390-1-git-send-email-shawn.guo@linaro.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@linaro.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:39464 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753658Ab1IWMLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 08:11:04 -0400
Received: by gyg10 with SMTP id 10so2477814gyg.19
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2011 05:11:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds imx6q enet support.  The imx6q enet is a derivative of
imx28 enet controller.  It fixes the frame endian issue found on imx28,
and adds 1 Gbps support.

Changes since v4:
 * Confirmed with design team that i.MX28 Reference Manual has an error
   on MII_SPEED formula.  FEC uses 'ref_freq / (MII_SPEED x 2)' while
   ENET-MAC uses 'ref_freq / ((MII_SPEED + 1) x 2)', so that minus one
   should really apply for just FEC_QUIRK_ENET_MAC.

Changes since v3:
 * The minus one on phy_speed should happen before left shift.

Changes since v2:
 * Refine patch #1 to get fec_reset_phy() return void

Changes since v1:
 * Fix typo pointed out by Francois Romieu
 * Drop patch #3 in the v1
 * Rebase on net-next tree

Thanks.

Shawn Guo (3):
      net/fec: fec_reset_phy() does not need to always succeed
      net/fec: fix fec1 check in fec_enet_mii_init()
      net/fec: add imx6q enet support

 drivers/net/ethernet/freescale/Kconfig |    9 ++--
 drivers/net/ethernet/freescale/fec.c   |   81 +++++++++++++++++++++++---------
 2 files changed, 63 insertions(+), 27 deletions(-)
