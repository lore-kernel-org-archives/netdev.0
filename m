From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] ATM: misplaced parentheses?
Date: Mon, 16 Feb 2009 17:02:36 -0500
Message-ID: <200902162202.n1GM2aI0009056@cmf.nrl.navy.mil>
References: <49983DB0.6040008@gmail.com>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:47558 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbZBPWPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 17:15:10 -0500
In-reply-to: <49983DB0.6040008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

that doesnt seem to make sense either.  the original code
is:

 		for (i = 128; i != 0; i >>= 1) {   /* write command out */
...
 			tmp = (lanai->conf1 & ~CONFIG1_PROMDATA) |
			    (data & i) ? CONFIG1_PROMDATA : 0;

since i is always positive here, you wouldnt need the ?: if your suggested
fix is the original intent.  it looks like setting CONFIG1_PROMDATA
means '1' and not setting it means '0' when writing the value of data
to the register.

In message <49983DB0.6040008@gmail.com>,Roel Kluin writes:
>I think below is what was intended? otherwise we could as well have written:
>
>tmp = (lanai->conf1 & ~CONFIG1_PROMDATA) ||
>	(data & i) ? CONFIG1_PROMDATA : 0;
>
>Does this fix the parsing of the EEPROM?
>
>please review.
>-------------------------->8------------------8<---------------------------
>Fix misplaced parentheses
>
>Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>---
>diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
>index 144a49f..317fb5a 100644
>--- a/drivers/atm/lanai.c
>+++ b/drivers/atm/lanai.c
>@@ -901,7 +901,7 @@ static int __devinit eeprom_read(struct lanai_dev *lanai)
> 		clock_l(); udelay(5);
> 		for (i = 128; i != 0; i >>= 1) {   /* write command out */
> 			tmp = (lanai->conf1 & ~CONFIG1_PROMDATA) |
>-			    (data & i) ? CONFIG1_PROMDATA : 0;
>+			    (data & i ? CONFIG1_PROMDATA : 0);
> 			if (lanai->conf1 != tmp) {
> 				set_config1(tmp);
> 				udelay(5);	/* Let new data settle */
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
