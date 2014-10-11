From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 03/12] isdn/gigaset: limit raw CAPI message dump length
Date: Sat, 11 Oct 2014 13:46:29 +0200 (CEST)
Message-ID: <36d3e64c941166c19c80987fcd692fece72ced17.1413021630.git.tilman@imap.cc>
References: <cover.1413021630.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:57640 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752080AbaJKLrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:47:03 -0400
In-Reply-To: <cover.1413021630.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In dump_rawmsg, the length field from a received data package was
used unscrutinized, allowing an attacker to control the size of the
allocated buffer and the number of times the output loop iterates.
Fix by limiting to a reasonable value.

Spotted with Coverity.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 044392c..47e2a91 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -250,6 +250,8 @@ static inline void dump_rawmsg(enum debuglevel level, const char *tag,
 	l -= 12;
 	if (l <= 0)
 		return;
+	if (l > 64)
+		l = 64; /* arbitrary limit */
 	dbgline = kmalloc(3 * l, GFP_ATOMIC);
 	if (!dbgline)
 		return;
-- 
1.9.2.459.g68773ac
