From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH] gianfar: ensure ECNTRL[R100] is cleared on link state change
Date: Tue,  6 Jan 2009 14:52:51 -0600
Message-ID: <1231275171-21388-1-git-send-email-galak@kernel.crashing.org>
Cc: linuxppc-dev@ozlabs.org, afleming@freescale.com,
	davem@davemloft.net, Leo Li <leo@rock.ap.freescale.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:46067 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751390AbZAFUzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 15:55:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leo Li <leo@rock.ap.freescale.net>

When changing the link between 100Mbps and 1Gbps in SGMII mode it was
found out that the link would stop working.  The issue is that ECNTRL[R100]
needs to be cleared when in 1Gbps mode.  Older reference manuals didn't
require the explicitly clearing but has since been found it that it is
needed.

Signed-off-by: Li Yang <leoli@freescale.com>
Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---

Dave,

Please apply for 2.6.29 as it addresses a "HW" bug in real systems.

thanks

- k

 drivers/net/gianfar.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index c672ecf..7fcc3af 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1973,6 +1973,8 @@ static void adjust_link(struct net_device *dev)
 			case 1000:
 				tempval =
 				    ((tempval & ~(MACCFG2_IF)) | MACCFG2_GMII);
+
+				ecntrl &= ~(ECNTRL_R100);
 				break;
 			case 100:
 			case 10:
-- 
1.5.6.5

