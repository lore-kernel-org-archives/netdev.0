From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH 0/6] fec: Improve resources handling
Date: Sun, 21 Jul 2013 13:24:58 -0300
Message-ID: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Cc: kernel@pengutronix.de, Frank.Li@freescale.com,
	shawn.guo@linaro.org, netdev@vger.kernel.org,
	Fabio Estevam <festevam@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:42103 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755722Ab3GUQZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 12:25:32 -0400
Received: by mail-yh0-f50.google.com with SMTP id i72so2170856yha.9
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 09:25:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series improves clock handling in the driver by not enabling/disabling
the optional ptp and enet_out clocks unconditionally, check for the return value
of clk_prepare_enable and also handle clk_ptp in suspend/resume.

Remove an unneeded check in platform_get_resource() and also use 
devm_request_irq() that can help to simplify the code.

Fabio Estevam (6):
  fec: Do not enable/disable optional clocks unconditionally
  fec: Fix the order for enabling/disabling the clocks
  fec: Enable/disable clk_ptp in suspend/resume
  fec: Check the return value from clk_prepare_enable()
  fec: Remove unneeded check in platform_get_resource()
  fec: Use devm_request_irq()

 drivers/net/ethernet/freescale/fec_main.c | 110 ++++++++++++++++++++----------
 1 file changed, 73 insertions(+), 37 deletions(-)

-- 
1.8.1.2
