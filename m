From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 11/12] isdn/capi: don't return NULL from capi_cmd2str()
Date: Sat, 11 Oct 2014 13:46:30 +0200 (CEST)
Message-ID: <937f46dfacacd354b31440e0842334308edcfe0b.1413021631.git.tilman@imap.cc>
References: <cover.1413021630.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:52712 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049AbaJKLrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:47:03 -0400
In-Reply-To: <cover.1413021630.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

capi_cmd2str() is used in many places to build log messages.
None of them is prepared to handle NULL as a result.
Change the function to return printable string "INVALID_COMMAND"
instead.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capiutil.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/capi/capiutil.c b/drivers/isdn/capi/capiutil.c
index 36835ef..36c1b37 100644
--- a/drivers/isdn/capi/capiutil.c
+++ b/drivers/isdn/capi/capiutil.c
@@ -489,12 +489,17 @@ static char *mnames[] =
  * @cmd:	command number
  * @subcmd:	subcommand number
  *
- * Return value: static string, NULL if command/subcommand unknown
+ * Return value: static string
  */
 
 char *capi_cmd2str(u8 cmd, u8 subcmd)
 {
-	return mnames[command_2_index(cmd, subcmd)];
+	char *result;
+
+	result = mnames[command_2_index(cmd, subcmd)];
+	if (result == NULL)
+		result = "INVALID_COMMAND";
+	return result;
 }
 
 
-- 
1.9.2.459.g68773ac
