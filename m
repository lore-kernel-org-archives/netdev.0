From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [net v2 0/8] gianfar: ARM port driver updates (1/2)
Date: Tue, 7 Oct 2014 10:44:27 +0300
Message-ID: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>,
	"Kim Phillips" <kim.phillips@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [157.56.111.140] ([157.56.111.140]:49664 "EHLO
	na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752497AbaJGHrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 03:47:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first round of driver portability fixes and clean-up
with the main purpose to make gianfar portable on ARM, for the ARM
based SoC that integrates the eTSEC ethernet controller - "ls1021a".
The patches primarily address compile time errors, when compiling
gianfar on ARM.  They replace PPC specific functions and macros
with architecture independent ones, solve arch specific header
inclusions, guard code that relates to PPC only, and even address
some simple endianess issues (see MAC address setup patch).
The patches addressing the bulk of remaining endianess issues,
like handling DMA fields (BD and FCB), will follow with the second
round.

Reviewed-by: Kim Phillips <kim.phillips@freescale.com>

Claudiu Manoil (8):
  net/fsl_pq_mdio: Fix asm/ucc.h compile error for ARM
  net/fsl_pq_mdio: Use ioread/iowrite32be() portable accessors
  net/fsl_pq_mdio: Replace spin_event_timeout() with arch independent
  gianfar: Include missing headers for ARM builds
  gianfar: Exclude PPC specific errata handling from ARM builds
  gianfar: Make MAC addr setup endian safe, cleanup
  gianfar: Replace spin_event_timeout() with arch independent
  gianfar: Replace eieio with wmb for non-PPC archs

 drivers/net/ethernet/freescale/fsl_pq_mdio.c | 56 ++++++++++++++---------
 drivers/net/ethernet/freescale/gianfar.c     | 68 +++++++++++++++-------------
 drivers/net/ethernet/freescale/gianfar.h     | 31 +++++++++++++
 3 files changed, 102 insertions(+), 53 deletions(-)

-- 
1.7.11.7
