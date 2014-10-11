From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 07/12] isdn/capi: prevent index overrun from command_2_index()
Date: Sat, 11 Oct 2014 13:46:30 +0200 (CEST)
Message-ID: <a92156a6bd79e5a3339b10fe3ae465785a918fbb.1413021630.git.tilman@imap.cc>
References: <cover.1413021630.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:49806 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116AbaJKLrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:47:03 -0400
In-Reply-To: <cover.1413021630.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The result of the function command_2_index() is used to index two
arrays mnames[] and cpars[] with max. index 0x4e but in its current
form that function can produce results up to 3*(0x9+0x9)+0x7f =
0xb5.
Fix by clamping all result values potentially overrunning the arrays
to zero which is already handled as an invalid value.

Re-spotted with Coverity.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capiutil.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/isdn/capi/capiutil.c b/drivers/isdn/capi/capiutil.c
index 4073d16..b501d76 100644
--- a/drivers/isdn/capi/capiutil.c
+++ b/drivers/isdn/capi/capiutil.c
@@ -207,6 +207,8 @@ static unsigned command_2_index(unsigned c, unsigned sc)
 		c = 0x9 + (c & 0x0f);
 	else if (c == 0x41)
 		c = 0x9 + 0x1;
+	if (c > 0x18)
+		c = 0x00;
 	return (sc & 3) * (0x9 + 0x9) + c;
 }
 
-- 
1.9.2.459.g68773ac
