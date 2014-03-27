From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net v2 1/3] xen-netback: remove pointless clause from if statement
Date: Thu, 27 Mar 2014 12:56:11 +0000
Message-ID: <1395924973-42904-2-git-send-email-paul.durrant@citrix.com>
References: <1395924973-42904-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:39776 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753943AbaC0M4d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 08:56:33 -0400
In-Reply-To: <1395924973-42904-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes a test in start_new_rx_buffer() that checks whether
a copy operation is less than MAX_BUFFER_OFFSET in length, since
MAX_BUFFER_OFFSET is defined to be PAGE_SIZE and the only caller of
start_new_rx_buffer() already limits copy operations to PAGE_SIZE or less.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Sander Eikelenboom <linux@eikelenboom.it>
---

v2:
 - Add BUG_ON() as suggested by Ian Campbell

 drivers/net/xen-netback/netback.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 438d0c0..72314c7 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -192,8 +192,8 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
 	 * into multiple copies tend to give large frags their
 	 * own buffers as before.
 	 */
-	if ((offset + size > MAX_BUFFER_OFFSET) &&
-	    (size <= MAX_BUFFER_OFFSET) && offset && !head)
+	BUG_ON(size > MAX_BUFFER_OFFSET);
+	if ((offset + size > MAX_BUFFER_OFFSET) && offset && !head)
 		return true;
 
 	return false;
-- 
1.7.10.4
