From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] drivers/isdn: checkng length to be sure not memory overflow
Date: Wed, 27 Feb 2013 17:05:14 +0800
Message-ID: <512DCC4A.6060106@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: alan@linux.intel.com, netdev <netdev@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Jiri Slaby <jslaby@suse.cz>,
	Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:5003 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151Ab3B0JFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 04:05:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  the length of cmd.parm.cmsg.para is 50 (MAX_CAPI_PARA_LEN).
  the strlen(msg) may be more than 50 (Modem-Commandbuffer, less than 255).
    isdn_tty_send_msg is called by isdn_tty_parse_at
    the relative parameter is m->mdmcmd (atemu *m)
    the relative command may be "+M..."

  so need check the length to be sure not memory overflow.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 drivers/isdn/i4l/isdn_tty.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index d8a7d83..c3f0f99 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -902,7 +902,7 @@ isdn_tty_send_msg(modem_info *info, atemu *m, char *msg)
 	int j;
 	int l;
 
-	l = strlen(msg);
+	l = min(strlen(msg), sizeof(cmd.parm.cmsg.para) - 2);
 	if (!l) {
 		isdn_tty_modem_result(RESULT_ERROR, info);
 		return;
-- 
1.7.7.6
