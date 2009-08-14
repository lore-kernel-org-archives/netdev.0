From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] via-velocity: Fix test of mii_status bit VELOCITY_DUPLEX_FULL
Date: Fri, 14 Aug 2009 14:09:56 +0200
Message-ID: <4A855414.10007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:38894 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbZHNMFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 08:05:47 -0400
Received: by ewy10 with SMTP id 10so1447935ewy.37
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 05:05:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Test whether VELOCITY_DUPLEX_FULL bit is set in mii_status.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
// vi drivers/net/via-velocity.h +1448
#define     VELOCITY_DUPLEX_FULL           0x00000010UL

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 3ba3595..cee08a1 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1778,7 +1778,7 @@ static void velocity_error(struct velocity_info *vptr, int status)
 			 *	 mode
 			 */
 			if (vptr->rev_id < REV_ID_VT3216_A0) {
-				if (vptr->mii_status | VELOCITY_DUPLEX_FULL)
+				if (vptr->mii_status & VELOCITY_DUPLEX_FULL)
 					BYTE_REG_BITS_ON(TCR_TB2BDIS, &regs->TCR);
 				else
 					BYTE_REG_BITS_OFF(TCR_TB2BDIS, &regs->TCR);
