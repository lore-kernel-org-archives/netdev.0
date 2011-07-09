From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 7/7] drivers/net: static should be at beginning of
 declaration
Date: Sat, 9 Jul 2011 23:24:43 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1107092322320.25516@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1107092304160.25516@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-693533701-1310246683=:25516"
Cc: trivial@kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Marius Bjoernstad Kotsbak <marius@kotsbak.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:13457 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754991Ab1GIVeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 17:34:19 -0400
In-Reply-To: <alpine.LNX.2.00.1107092304160.25516@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-693533701-1310246683=:25516
Content-Type: TEXT/PLAIN; charset=ISO-8859-7
Content-Transfer-Encoding: 8BIT

Make sure that the 'static' keywork is at the beginning of declaration
for drivers/net/usb/kalmia.c

This gets rid of warnings like
  warning: ¡static¢ is not at beginning of declaration
when building with -Wold-style-declaration (and/or -Wextra which also
enables it).

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/usb/kalmia.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/kalmia.c b/drivers/net/usb/kalmia.c
index a9b6c63..5a6d0f8 100644
--- a/drivers/net/usb/kalmia.c
+++ b/drivers/net/usb/kalmia.c
@@ -100,13 +100,13 @@ kalmia_send_init_packet(struct usbnet *dev, u8 *init_msg, u8 init_msg_len,
 static int
 kalmia_init_and_get_ethernet_addr(struct usbnet *dev, u8 *ethernet_addr)
 {
-	const static char init_msg_1[] =
+	static const char init_msg_1[] =
 		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00,
 		0x00, 0x00 };
-	const static char init_msg_2[] =
+	static const char init_msg_2[] =
 		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0xf4,
 		0x00, 0x00 };
-	const static int buflen = 28;
+	static const int buflen = 28;
 	char *usb_buf;
 	int status;
 
@@ -239,11 +239,11 @@ kalmia_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	 * Our task here is to strip off framing, leaving skb with one
 	 * data frame for the usbnet framework code to process.
 	 */
-	const static u8 HEADER_END_OF_USB_PACKET[] =
+	static const u8 HEADER_END_OF_USB_PACKET[] =
 		{ 0x57, 0x5a, 0x00, 0x00, 0x08, 0x00 };
-	const static u8 EXPECTED_UNKNOWN_HEADER_1[] =
+	static const u8 EXPECTED_UNKNOWN_HEADER_1[] =
 		{ 0x57, 0x43, 0x1e, 0x00, 0x15, 0x02 };
-	const static u8 EXPECTED_UNKNOWN_HEADER_2[] =
+	static const u8 EXPECTED_UNKNOWN_HEADER_2[] =
 		{ 0x57, 0x50, 0x0e, 0x00, 0x00, 0x00 };
 	int i = 0;
 
-- 
1.7.6


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

--8323328-693533701-1310246683=:25516--
