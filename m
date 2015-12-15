From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH 1/4] ser_gigaset: fix up NULL checks
Date: Tue, 15 Dec 2015 18:11:28 +0100
Message-ID: <1450199491-30471-2-git-send-email-pebolle@tiscali.nl>
References: <1450199491-30471-1-git-send-email-pebolle@tiscali.nl>
Cc: Tilman Schmidt <tilman@imap.cc>, Alan Cox <alan@linux.intel.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Peter Hurley <peter@hurleysoftware.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450199491-30471-1-git-send-email-pebolle@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>

Commit f34d7a5b7010 ("tty: The big operations rework") changed
tty->driver to tty->ops but left NULL checks for tty->driver untouched.
Fix.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
[pebolle: removed Fixes tag]
Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
 drivers/isdn/gigaset/ser-gigaset.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index 375be509e95f..d8771b5d6904 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -67,7 +67,7 @@ static int write_modem(struct cardstate *cs)
 	struct sk_buff *skb = bcs->tx_skb;
 	int sent = -EOPNOTSUPP;
 
-	if (!tty || !tty->driver || !skb)
+	if (!tty || !tty->ops || !skb)
 		return -EINVAL;
 
 	if (!skb->len) {
@@ -109,7 +109,7 @@ static int send_cb(struct cardstate *cs)
 	unsigned long flags;
 	int sent = 0;
 
-	if (!tty || !tty->driver)
+	if (!tty || !tty->ops)
 		return -EFAULT;
 
 	cb = cs->cmdbuf;
@@ -432,7 +432,7 @@ static int gigaset_set_modem_ctrl(struct cardstate *cs, unsigned old_state,
 	struct tty_struct *tty = cs->hw.ser->tty;
 	unsigned int set, clear;
 
-	if (!tty || !tty->driver || !tty->ops->tiocmset)
+	if (!tty || !tty->ops || !tty->ops->tiocmset)
 		return -EINVAL;
 	set = new_state & ~old_state;
 	clear = old_state & ~new_state;
-- 
2.4.3
