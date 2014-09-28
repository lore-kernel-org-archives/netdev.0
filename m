From: Luwei Zhou <b45643@freescale.com>
Subject: [PATCH v2 0/4] net: fec: ptp: Add FEC PPS ouput support.
Date: Sun, 28 Sep 2014 12:20:07 +0800
Message-ID: <1411878011-21767-1-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<bhutchings@solarflare.com>, <R49496@freescale.com>,
	<b38611@freescale.com>, <b20596@freescale.com>,
	<stephen@networkplumber.org>
To: <davem@davemloft.net>, <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0110.outbound.protection.outlook.com ([157.56.111.110]:52256
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751341AbaI1FZS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Sep 2014 01:25:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches use hardeware adjustment to ptp timer and add pps ouput
support.

Change from v1 to v2:
	- Fix the potential 32-bit multiplication overflow issue.
	- Optimize the hareware adjustment code to improve efficiency as Richard suggested
	- Use ptp PTP_PIN_SET/GETFUNC interface to set PPS channel not device tree
	  and add PTP_PF_PPS enumeration
	- Modify comments style
	
Luwei Zhou (4):
  net: fec: ptp: Use the 31-bit ptp timer.
  net: fec: ptp: Use hardware algorithm to adjust PTP counter.
  ptp: Add PTP_PF_PPS enumeration to ptp_pin_function.
  net: fec: ptp: Enalbe PPS ouput based on ptp clock

 drivers/net/ethernet/freescale/fec.h      |  10 +
 drivers/net/ethernet/freescale/fec_main.c |   2 +
 drivers/net/ethernet/freescale/fec_ptp.c  | 293 ++++++++++++++++++++++++++++--
 drivers/ptp/ptp_chardev.c                 |   8 +
 include/linux/ptp_clock_kernel.h          |   2 +
 include/uapi/linux/ptp_clock.h            |   1 +
 6 files changed, 298 insertions(+), 18 deletions(-)

-- 
1.9.1
