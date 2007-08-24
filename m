From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] isdn capi driver broken on 64 bit.
Date: Fri, 24 Aug 2007 11:08:11 -0700
Message-ID: <20070824110811.32f266f8@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: Karsten Keil <kkeil@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54860 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762903AbXHXSIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 14:08:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following driver API is broken on any architecture with 64 bit addresses.
because of cast that loses high bits.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/isdn/capi/capidrv.c	2007-06-25 09:03:12.000000000 -0700
+++ b/drivers/isdn/capi/capidrv.c	2007-08-24 11:06:46.000000000 -0700
@@ -1855,6 +1855,9 @@ static int if_sendbuf(int id, int channe
 		return 0;
 	}
 	datahandle = nccip->datahandle;
+
+	/* This won't work on 64 bit! */
+	BUILD_BUG_ON(sizeof(skb->data) > sizeof(u32));
 	capi_fill_DATA_B3_REQ(&sendcmsg, global.ap.applid, card->msgid++,
 			      nccip->ncci,	/* adr */
 			      (u32) skb->data,	/* Data */
