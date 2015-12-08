From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/3] ser_gigaset: fix up NULL checks
Date: Tue,  8 Dec 2015 12:00:33 +0100 (CET)
Message-ID: <ed83fae92c8c56e659f59c9a3709c86bd3a7d0c4.1449570042.git.tilman@imap.cc>
References: <cover.1449570042.git.tilman@imap.cc>
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	<syzkaller@googlegroups.com>, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	<gigaset307x-common@lists.sourceforge.net>,
	<linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1449570042.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit f34d7a5b changed tty->driver to tty->ops but left NULL checks
for tty->driver untouched. Fix.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Fixes: f34d7a5b7010 ("tty: The big operations rework")
---
 drivers/isdn/gigaset/ser-gigaset.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index 375be50..d8771b5 100644
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
1.9.2.459.g68773ac
