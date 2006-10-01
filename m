From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: ATM bug found
Date: Sun, 01 Oct 2006 11:14:03 -0400
Message-ID: <200610011514.k91FE3ai003599@cmf.nrl.navy.mil>
References: <451FC182.6000502@garzik.org>
Cc: Netdev List <netdev@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:40849 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1750866AbWJAPO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 11:14:26 -0400
To: Jeff Garzik <jeff@garzik.org>
In-reply-to: <451FC182.6000502@garzik.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message <451FC182.6000502@garzik.org>,Jeff Garzik writes:
>If alloc_shaper() argument 'unlimited' is true, then pcr is never 
>assigned a value.  However, the caller of alloc_shaper() always tests 
>the pcr value, regardless of whether or not 'unlimited' is true.

when unlimited is true, this means ubr.  alloc_shaper() creates a queue
to use for all ubr (best effort) traffic.  ubr doesnt count against tx_bw
so its handled a bit differently.  alloc_shaper() should return a 0 for
the pcr since this gets assigned to the vcc's qos parameters.  min_pcr =
0 and max_pcr = 0 means "best effort".

still generates a warning from gcc though.

[ATM]: [zatm] always *pcr in alloc_shaper()

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index c491ec4..083c5d3 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -800,6 +800,7 @@ static int alloc_shaper(struct atm_dev *
 		i = m = 1;
 		zatm_dev->ubr_ref_cnt++;
 		zatm_dev->ubr = shaper;
+		*pcr = 0;
 	}
 	else {
 		if (min) {
