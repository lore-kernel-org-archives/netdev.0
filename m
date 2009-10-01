From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] net/ppp: fix comments - ppp_{sync,asynctty}_receive() may sleep
Date: Thu,  1 Oct 2009 16:28:44 +0200 (CEST)
Message-ID: <20091001142844.C50E511186D@xenon.ts.pxnet.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jarek Poplawski <jarkao2@gmail.com>,
	linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Alan Cox <alan@linux.intel.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932697AbZJAO3Y@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The receive_buf methods of the N_PPP and N_SYNC_PPP line disciplines,
ppp_asynctty_receive() and ppp_sync_receive(), call tty_unthrottle()
which may sleep. Fix the comments claiming otherwise.

Impact: documentation
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/net/ppp_async.c   |    5 +----
 drivers/net/ppp_synctty.c |    5 +----
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ppp_async.c b/drivers/net/ppp_async.c
index 6de8399..30b1b33 100644
--- a/drivers/net/ppp_async.c
+++ b/drivers/net/ppp_async.c
@@ -337,10 +337,7 @@ ppp_asynctty_poll(struct tty_struct *tty, struct file *file, poll_table *wait)
 	return 0;
 }
 
-/*
- * This can now be called from hard interrupt level as well
- * as soft interrupt level or mainline.
- */
+/* May sleep, don't call from interrupt level or with interrupts disabled */
 static void
 ppp_asynctty_receive(struct tty_struct *tty, const unsigned char *buf,
 		  char *cflags, int count)
diff --git a/drivers/net/ppp_synctty.c b/drivers/net/ppp_synctty.c
index d2fa2db..c908b08 100644
--- a/drivers/net/ppp_synctty.c
+++ b/drivers/net/ppp_synctty.c
@@ -378,10 +378,7 @@ ppp_sync_poll(struct tty_struct *tty, struct file *file, poll_table *wait)
 	return 0;
 }
 
-/*
- * This can now be called from hard interrupt level as well
- * as soft interrupt level or mainline.
- */
+/* May sleep, don't call from interrupt level or with interrupts disabled */
 static void
 ppp_sync_receive(struct tty_struct *tty, const unsigned char *buf,
 		  char *cflags, int count)
-- 
1.6.2.1.214.ge986c
