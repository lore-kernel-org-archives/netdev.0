From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v4 0/1] net: fec: ptp: avoid register access when ipg clock is disabled
Date: Tue, 19 Aug 2014 11:20:52 +0800
Message-ID: <1408418453-28012-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<b38611@freescale.com>
To: <richardcochran@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0188.outbound.protection.outlook.com ([207.46.163.188]:24837
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751880AbaHSDhy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 23:37:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V4:
* Init the ptp_clk_on flag to false in .probe(), and add mutex to protect the ptp clock
  status.

V3:
* Suggest from Richard Cochran, time_keep work is COMPLETELY INDEPENDENT from time stamping,
  let it always run. In .fec_ptp_gettime() function will return an error when ptp physical
  clock is disabled.

V2:
* As Richard Cochran's suggestion, use schedule_delayed_work instead of period timer.
* Stop delayed work before ipg clock disable like suspend, ethx close.

Fugang Duan (1):
  net: fec: ptp: avoid register access when ipg clock is disabled

 drivers/net/ethernet/freescale/fec.h      |    5 +++-
 drivers/net/ethernet/freescale/fec_main.c |   18 ++++++++++++++--
 drivers/net/ethernet/freescale/fec_ptp.c  |   31 ++++++++++++++++++----------
 3 files changed, 39 insertions(+), 15 deletions(-)

-- 
1.7.8
