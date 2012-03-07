From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] atl1c: set ATL1C_WORK_EVENT_RESET bit correctly
Date: Wed, 7 Mar 2012 13:02:04 +0300
Message-ID: <20120307100204.GB25452@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Snook <chris.snook@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:20048 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726Ab2CGKCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 05:02:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ATL1C_WORK_EVENT_RESET is zero so the original code here is a nop.  The
intent was to set the zero bit.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 0f21a9b..1ef0c92 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1711,7 +1711,7 @@ static irqreturn_t atl1c_intr(int irq, void *data)
 					"atl1c hardware error (status = 0x%x)\n",
 					status & ISR_ERROR);
 			/* reset MAC */
-			adapter->work_event |= ATL1C_WORK_EVENT_RESET;
+			set_bit(ATL1C_WORK_EVENT_RESET, &adapter->work_event);
 			schedule_work(&adapter->common_task);
 			return IRQ_HANDLED;
 		}
