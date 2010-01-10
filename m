From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 1/1] NET: irda, remove unnecessary checks
Date: Sun, 10 Jan 2010 12:17:34 +0100
Message-ID: <1263122254-18781-1-git-send-email-jslaby@suse.cz>
References: <1263114674-10433-1-git-send-email-jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	"David S. Miller" <davem@davemloft.net>,
	Alan Cox <alan@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org
To: samuel@sortiz.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754005Ab0AJLRl@vger.kernel.org>
In-Reply-To: <1263114674-10433-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stanse found a potential null dereference in ircomm_tty_close
and ircomm_tty_hangup. There is a check for tty being NULL,
but it is dereferenced earlier. But it is bogus, the tty cannot
be NULL, so remove the !tty checks.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alan Cox <alan@linux.intel.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: netdev@vger.kernel.org
---
 net/irda/ircomm/ircomm_tty.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 811984d..8b85d77 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -496,9 +496,6 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 
 	IRDA_DEBUG(0, "%s()\n", __func__ );
 
-	if (!tty)
-		return;
-
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
@@ -1007,9 +1004,6 @@ static void ircomm_tty_hangup(struct tty_struct *tty)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
-	if (!tty)
-		return;
-
 	/* ircomm_tty_flush_buffer(tty); */
 	ircomm_tty_shutdown(self);
 
-- 
1.6.5.7
