From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] packet: use vzalloc()
Date: Sat, 20 Nov 2010 18:31:54 +0100
Message-ID: <1290274314.2756.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53221 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541Ab0KTRcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Nov 2010 12:32:06 -0500
Received: by wyb28 with SMTP id 28so5584496wyb.19
        for <netdev@vger.kernel.org>; Sat, 20 Nov 2010 09:32:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alloc_one_pg_vec_page() is supposed to return zeroed memory, so use
vzalloc() instead of vmalloc()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
---
 net/packet/af_packet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b6372dd..422705d 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2367,7 +2367,7 @@ static inline char *alloc_one_pg_vec_page(unsigned long order,
 	 * __get_free_pages failed, fall back to vmalloc
 	 */
 	*flags |= PGV_FROM_VMALLOC;
-	buffer = vmalloc((1 << order) * PAGE_SIZE);
+	buffer = vzalloc((1 << order) * PAGE_SIZE);
 
 	if (buffer)
 		return buffer;


