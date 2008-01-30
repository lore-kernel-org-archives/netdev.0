From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [drivers/net/bnx2.c] ADVERTISE_1000XPSE_ASYM
Date: Wed, 30 Jan 2008 10:51:10 -0800
Message-ID: <1201719070.7190.4.camel@dell>
References: <47A084B0.1000301@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "lkml" <linux-kernel@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>
To: "Roel Kluin" <12o3l@tiscali.nl>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3280 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752744AbYA3Syx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 13:54:53 -0500
In-Reply-To: <47A084B0.1000301@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-01-30 at 15:07 +0100, Roel Kluin wrote:
> In drivers/net/bnx2.c:1285: it reads in function bnx2_setup_remote_phy():
> 
> if (pause_adv & (ADVERTISE_1000XPSE_ASYM | ADVERTISE_1000XPSE_ASYM))
> 
> Note that the two are the same and this is therefore equivalent to
> 
> if (pause_adv & ADVERTISE_1000XPSE_ASYM)
> 
> This appears to be incorrect, was maybe '| ADVERTISE_1000XPAUSE' intended?
> 

Thanks for catching this.  The patch below will fix it.

[BNX2]: Fix ASYM PAUSE advertisement for remote PHY.

We were checking for the ASYM_PAUSE bit for 1000Base-X twice instead
checking for both the 1000Base-X bit and the 10/100/1000Base-T bit.
The purpose of the logic is to tell the firmware that ASYM_PAUSE is
set on either the Serdes or Copper interface.

Problem was discovered by Roel Kluin <12o3l@tiscali.nl>

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index be7e8f8..77400ad 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1429,7 +1429,7 @@ bnx2_setup_remote_phy(struct bnx2 *bp, u8 port)
 
 	if (pause_adv & (ADVERTISE_1000XPAUSE | ADVERTISE_PAUSE_CAP))
 		speed_arg |= BNX2_NETLINK_SET_LINK_FC_SYM_PAUSE;
-	if (pause_adv & (ADVERTISE_1000XPSE_ASYM | ADVERTISE_1000XPSE_ASYM))
+	if (pause_adv & (ADVERTISE_1000XPSE_ASYM | ADVERTISE_PAUSE_ASYM))
 		speed_arg |= BNX2_NETLINK_SET_LINK_FC_ASYM_PAUSE;
 
 	if (port == PORT_TP)


