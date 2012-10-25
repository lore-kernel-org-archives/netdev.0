From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] isdn: remove dead code
Date: Thu, 25 Oct 2012 15:30:52 +0100
Message-ID: <20121025143031.16991.81337.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: isdn@linux-pingi.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:53789 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759749Ab2JYO3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 10:29:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

multi is assigned to 0 and then acts as a constant. Remove the dead
code.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/isdn/mISDN/l1oip_core.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
index db50f78..f8e405c 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -277,7 +277,6 @@ l1oip_socket_send(struct l1oip *hc, u8 localcodec, u8 channel, u32 chanmask,
 		  u16 timebase, u8 *buf, int len)
 {
 	u8 *p;
-	int multi = 0;
 	u8 frame[len + 32];
 	struct socket *socket = NULL;
 
@@ -317,9 +316,7 @@ l1oip_socket_send(struct l1oip *hc, u8 localcodec, u8 channel, u32 chanmask,
 		*p++ = hc->id >> 8;
 		*p++ = hc->id;
 	}
-	*p++ = (multi == 1) ? 0x80 : 0x00 + channel; /* m-flag, channel */
-	if (multi == 1)
-		*p++ = len; /* length */
+	*p++ =  0x00 + channel; /* m-flag, channel */
 	*p++ = timebase >> 8; /* time base */
 	*p++ = timebase;
 
