From: Ulrich Kunitz <kune@deine-taler.de>
Subject: [PATCH 5/6] zd1211rw: Fixed endianess issue with length info tag detection
Date: Tue, 01 Aug 2006 23:43:34 +0200
Message-ID: <1154468616527-git-send-email-kune@deine-taler.de>
References: <1154468615618-git-send-email-kune@deine-taler.de>
Reply-To: Ulrich Kunitz <kune@deine-taler.de>
Cc: netdev@vger.kernel.org, dsd@gentoo.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:29636 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1751132AbWHAVnh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 17:43:37 -0400
To: linville@tuxdriver.com
In-Reply-To: <1154468615618-git-send-email-kune@deine-taler.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Discovered a problem while accessing www.python.org on my PPC32.
The problem was pretty consistent for all sticks. The reason was
that while testing for the length info tag, I ignored the
endianess of the host system.

Please recognize that converting the constant to little endian, we
create faster code.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
---
 drivers/net/wireless/zd1211rw/zd_usb.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 2e3d77e..96551da 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -546,11 +546,11 @@ static void handle_rx_packet(struct zd_u
 	 * be padded. Unaligned access might also happen if the length_info
 	 * structure is not present.
 	 */
-	if (get_unaligned(&length_info->tag) == RX_LENGTH_INFO_TAG) {
+	if (get_unaligned(&length_info->tag) == cpu_to_le16(RX_LENGTH_INFO_TAG))
+	{
 		unsigned int l, k, n;
 		for (i = 0, l = 0;; i++) {
-			k = le16_to_cpu(get_unaligned(
-				&length_info->length[i]));
+			k = le16_to_cpu(get_unaligned(&length_info->length[i]));
 			n = l+k;
 			if (n > length)
 				return;
-- 
1.4.1

