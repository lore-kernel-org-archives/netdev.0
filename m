From: Dan Carpenter <error27@gmail.com>
Subject: [patch] isdn: strcpy() => strlcpy()
Date: Tue, 5 Oct 2010 18:34:48 +0200
Message-ID: <20101005163448.GH5692@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43992 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872Ab0JEQfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 12:35:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

setup.phone and setup.eazmsn are 32 character buffers.
rcvmsg.msg_data.byte_array is a 48 character buffer.
sc_adapter[card]->channel[rcvmsg.phy_link_no - 1].dn is 50 chars.

I changed the strcpy() so strlcpy() because that's safest.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/isdn/sc/interrupt.c b/drivers/isdn/sc/interrupt.c
index 485be8b..288073e 100644
--- a/drivers/isdn/sc/interrupt.c
+++ b/drivers/isdn/sc/interrupt.c
@@ -114,9 +114,11 @@ irqreturn_t interrupt_handler(int dummy, void *card_inst)
 			{
 				pr_debug("%s: Got Incoming Call\n",
 						sc_adapter[card]->devicename);
-				strcpy(setup.phone,&(rcvmsg.msg_data.byte_array[4]));
-				strcpy(setup.eazmsn,
-					sc_adapter[card]->channel[rcvmsg.phy_link_no-1].dn);
+				strlcpy(setup.phone, &(rcvmsg.msg_data.byte_array[4]),
+					sizeof(setup.phone));
+				strlcpy(setup.eazmsn,
+					sc_adapter[card]->channel[rcvmsg.phy_link_no - 1].dn,
+					sizeof(setup.eazmsn));
 				setup.si1 = 7;
 				setup.si2 = 0;
 				setup.plan = 0;
@@ -176,7 +178,9 @@ irqreturn_t interrupt_handler(int dummy, void *card_inst)
 		 * Handle a GetMyNumber Rsp
 		 */
 		if (IS_CE_MESSAGE(rcvmsg,Call,0,GetMyNumber)){
-			strcpy(sc_adapter[card]->channel[rcvmsg.phy_link_no-1].dn,rcvmsg.msg_data.byte_array);
+			strlcpy(sc_adapter[card]->channel[rcvmsg.phy_link_no - 1].dn,
+				rcvmsg.msg_data.byte_array,
+				sizeof(rcvmsg.msg_data.byte_array));
 			continue;
 		}
 			
