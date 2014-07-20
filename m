From: Shawn Guo <shawn.guo@freescale.com>
Subject: FEC driver hangs hardware on i.MX6SX
Date: Sun, 20 Jul 2014 10:57:33 +0800
Message-ID: <20140720025732.GF8537@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Li <Frank.li@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	Shawn Guo <shawn.guo@freescale.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Fugang Duan <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0244.outbound.protection.outlook.com ([207.46.163.244]:12805
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751544AbaGTC5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jul 2014 22:57:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fugang,

Your commit e8fcfcd5684a (net: fec: optimize the clock management to
save power) landed on mainline with v3.16-rc1.  It causes a hardware
hang on i.MX6SX, if the rootfs is not on NFS but something else like
MMC.

I think the cause is that PTP is still accessing registers after FEC
driver calls fec_enet_clk_enable(ndev, false) to disable FEC clocks.
Can you please try to provide a fix for this regression soon?

Shawn
