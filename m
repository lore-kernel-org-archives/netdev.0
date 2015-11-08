From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 1/4] tty: rocket: Remove private close_wait
Date: Sun,  8 Nov 2015 17:02:50 -0500
Message-ID: <1447020173-32207-2-git-send-email-peter@hurleysoftware.com>
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
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38816 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbbKHWDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 17:03:11 -0500
Received: by igbxm8 with SMTP id xm8so40961514igb.1
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2015 14:03:09 -0800 (PST)
In-Reply-To: <1447020173-32207-1-git-send-email-peter@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver's private completion variable, close_wait, is no longer
used for wait since "tty: Remove ASYNC_CLOSING checks in open()/hangup";
remove.

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 drivers/tty/rocket.c     | 2 --
 drivers/tty/rocket_int.h | 1 -
 2 files changed, 3 deletions(-)

diff --git a/drivers/tty/rocket.c b/drivers/tty/rocket.c
index 802eac7..c5179f8 100644
--- a/drivers/tty/rocket.c
+++ b/drivers/tty/rocket.c
@@ -643,7 +643,6 @@ static void init_r_port(int board, int aiop, int chan, struct pci_dev *pci_dev)
 	info->chan = chan;
 	tty_port_init(&info->port);
 	info->port.ops = &rocket_port_ops;
-	init_completion(&info->close_wait);
 	info->flags &= ~ROCKET_MODE_MASK;
 	switch (pc104[board][line]) {
 	case 422:
@@ -1049,7 +1048,6 @@ static void rp_close(struct tty_struct *tty, struct file *filp)
 	mutex_unlock(&port->mutex);
 	tty_port_tty_set(port, NULL);
 
-	complete_all(&info->close_wait);
 	atomic_dec(&rp_num_ports_open);
 
 #ifdef ROCKET_DEBUG_OPEN
diff --git a/drivers/tty/rocket_int.h b/drivers/tty/rocket_int.h
index 67e0f1e..ef1e1be 100644
--- a/drivers/tty/rocket_int.h
+++ b/drivers/tty/rocket_int.h
@@ -1144,7 +1144,6 @@ struct r_port {
 	int read_status_mask;
 	int cps;
 
-	struct completion close_wait;	/* Not yet matching the core */
 	spinlock_t slock;
 	struct mutex write_mtx;
 };
-- 
2.6.3
