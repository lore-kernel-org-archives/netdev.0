From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v3 0/1] net: fec: ptp: avoid register access when ipg clock is disabled
Date: Fri, 15 Aug 2014 13:52:54 +0800
Message-ID: <1408081975-15087-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<b38611@freescale.com>
To: <richardcochran@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0240.outbound.protection.outlook.com ([207.46.163.240]:24729
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751290AbaHOGII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 02:08:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V3:
* Suggest from Richard Cochran, time_keep work is COMPLETELY INDEPENDENT from time stamping,
  let it always run. In .fec_ptp_gettime() function will return an error when ptp physical
  clock is disabled.

V2:
* As Richard Cochran's suggestion, use schedule_delayed_work instead of period timer.
* Stop delayed work before ipg clock disable like suspend, ethx close.

Fugang Duan (1):
  net: fec: ptp: avoid register access when ipg clock is disabled

 drivers/net/ethernet/freescale/fec.h      |    3 ++-
 drivers/net/ethernet/freescale/fec_main.c |    8 ++++++--
 drivers/net/ethernet/freescale/fec_ptp.c  |   27 ++++++++++++++++-----------
 3 files changed, 24 insertions(+), 14 deletions(-)

-- 
1.7.8
