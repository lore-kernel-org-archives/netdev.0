From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH v3 net-next 09/12] bnx2x: add fan failure event
 handling
Date: Mon, 14 Nov 2011 10:28:06 +0200
Message-ID: <1321259286.4651.9.camel@lb-tlvb-dmitry>
References: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
 <1321194872-8276-10-git-send-email-dmitry@broadcom.com>
 <1321218717.15834.11.camel@Joe-Laptop>
 <80A6ED01A151614884EE6C5D6AF0F2E9099806AF42@SJEXCHCCR01.corp.ad.broadcom.com>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Joe Perches" <joe@perches.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4629 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507Ab1KNI2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 03:28:16 -0500
In-Reply-To: <80A6ED01A151614884EE6C5D6AF0F2E9099806AF42@SJEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com] 
> Sent: Sunday, November 13, 2011 11:12 PM
> To: Dmitry Kravkov
> Cc: davem@davemloft.net; netdev@vger.kernel.org; Ariel Elior; Eilon Greenstein
> Subject: Re: [PATCH v3 net-next 09/12] bnx2x: add fan failure event handling
> 
> On Sun, 2011-11-13 at 16:34 +0200, Dmitry Kravkov wrote:
> > From: Ariel Elior <ariele@broadcom.com>
> > Shut down the device in case of fan failure to prevent HW damage.
> trivia.
> > diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> []
> > @@ -8503,6 +8514,17 @@ sp_rtnl_not_reset:
> []
> > +	if (test_and_clear_bit(BNX2X_SP_RTNL_FAN_FAILURE, &bp->sp_rtnl_state)) {
> > +		DP(BNX2X_MSG_SP, "fan failure detected. Unloading driver");
> 
> Missing a trailing "\n".
> 

Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 33ff60d..c09e59a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -8520,7 +8520,7 @@ sp_rtnl_not_reset:
 	 * damage
 	 */
 	if (test_and_clear_bit(BNX2X_SP_RTNL_FAN_FAILURE, &bp->sp_rtnl_state)) {
-		DP(BNX2X_MSG_SP, "fan failure detected. Unloading driver");
+		DP(BNX2X_MSG_SP, "fan failure detected. Unloading driver\n");
 		netif_device_detach(bp->dev);
 		bnx2x_close(bp->dev);
 	}
-- 
1.7.7.2
