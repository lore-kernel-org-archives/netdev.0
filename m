From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 2/4] n_tty: Ignore all read data when closing
Date: Sun,  8 Nov 2015 17:02:51 -0500
Message-ID: <1447020173-32207-3-git-send-email-peter@hurleysoftware.com>
References: <1447020173-32207-1-git-send-email-peter@hurleysoftware.com>
Cc: Jiri Slaby <jslaby@suse.cz>, linux-kernel@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Jesper Nilsson <jesper.nilsson@axis.com>,
	Mikael Starvik <starvik@axis.com>,
	Jiri Kosina <jikos@kernel.org>,
	David Sterba <dsterba@suse.com>,
	Mark Hounschell <markh@compro.net>,
	Peter Hurley <peter@hurleysoftware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:33386 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627AbbKHWDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 17:03:11 -0500
Received: by igvi2 with SMTP id i2so64156856igv.0
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2015 14:03:10 -0800 (PST)
In-Reply-To: <1447020173-32207-1-git-send-email-peter@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On final port close (and thus final tty close), only output flow
control requests in the input data should be processed. Ignore all
other input data, including parity errors, overruns and breaks.

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 drivers/tty/n_tty.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/tty/n_tty.c b/drivers/tty/n_tty.c
index bc613b8..2de0283 100644
--- a/drivers/tty/n_tty.c
+++ b/drivers/tty/n_tty.c
@@ -1564,8 +1564,6 @@ n_tty_receive_buf_closing(struct tty_struct *tty, const unsigned char *cp,
 			flag = *fp++;
 		if (likely(flag == TTY_NORMAL))
 			n_tty_receive_char_closing(tty, *cp++);
-		else
-			n_tty_receive_char_flagged(tty, *cp++, flag);
 	}
 }
 
-- 
2.6.3
