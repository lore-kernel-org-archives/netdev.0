From: Dan Carpenter <error27@gmail.com>
Subject: [patch] isdn: cleanup: make buffer smaller
Date: Sat, 4 Sep 2010 20:33:03 +0200
Message-ID: <20100904183303.GN5437@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47294 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787Ab0IDSeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 14:34:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This showed up in my audit because we use strcpy() to copy "ds" into a
32 character buffer inside the isdn_tty_dial() function.  But it turns
out that we only ever use the first 32 characters so it's OK.  I have
changed the declaration to make the static checkers happy.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index 51dc60d..f013ee1 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -3515,7 +3515,7 @@ isdn_tty_parse_at(modem_info * info)
 {
 	atemu *m = &info->emu;
 	char *p;
-	char ds[40];
+	char ds[ISDN_MSNLEN];
 
 #ifdef ISDN_DEBUG_AT
 	printk(KERN_DEBUG "AT: '%s'\n", m->mdmcmd);
@@ -3594,7 +3594,7 @@ isdn_tty_parse_at(modem_info * info)
 						break;
 					case '3':
                                                 p++;
-                                                sprintf(ds, "\r\n%d", info->emu.charge);
+                                                snprintf(ds, sizeof(ds), "\r\n%d", info->emu.charge);
                                                 isdn_tty_at_cout(ds, info);
                                                 break;
 					default:;
