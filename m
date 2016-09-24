From: Eric Nelson <eric@nelint.com>
Subject: [PATCH 0/3] net: fec: updates to align IP header
Date: Sat, 24 Sep 2016 07:42:16 -0700
Message-ID: <1474728139-9335-1-git-send-email-eric@nelint.com>
References: <AM4PR0401MB22609D8151C2B63CA7768A1AFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Cc: linux@arm.linux.org.uk, andrew@lunn.ch, fugang.duan@nxp.com,
        otavio@ossystems.com.br, edumazet@google.com,
        troy.kisky@boundarydevices.com, davem@davemloft.net,
        u.kleine-koenig@pengutronix.de, Eric Nelson <eric@nelint.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fed1rmwml107.cox.net ([68.230.241.177]:57866 "EHLO
        fed1rmwml107.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754881AbcIXO6N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 10:58:13 -0400
Received: from fed1rmimpo306.cox.net ([68.230.241.174])
          by fed1rmfepo101.cox.net
          (InterMail vM.8.01.05.28 201-2260-151-171-20160122) with ESMTP
          id <20160924144424.UYQD2641.fed1rmfepo101.cox.net@fed1rmimpo306.cox.net>
          for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 10:44:24 -0400
In-Reply-To: <AM4PR0401MB22609D8151C2B63CA7768A1AFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is the outcome of investigation into very high
numbers of alignment faults on kernel 4.1.33 from the linux-fslc
tree:
    https://github.com/freescale/linux-fslc/tree/4.1-1.0.x-imx

The first two patches remove support for the receive accelerator (RACC) from
the i.MX25 and i.MX27 SoCs which don't support the function.

The third patch enables hardware alignment of the ethernet packet payload
(and especially the IP header) to prevent alignment faults in the IP stack.

Testing on i.MX6UL on the 4.1.33 kernel showed that this patch removed
on the order of 70k alignment faults during a 100MiB transfer using 
wget.

Testing on an i.MX6Q (SABRE Lite) board on net-next (4.8.0-rc7) showed
a much more modest improvement from 10's of faults, and it's not clear
why that's the case.

Eric Nelson (3):
  net: fec: remove QUIRK_HAS_RACC from i.mx25
  net: fec: remove QUIRK_HAS_RACC from i.mx27
  net: fec: align IP header in hardware

 drivers/net/ethernet/freescale/fec_main.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

-- 
2.7.4
