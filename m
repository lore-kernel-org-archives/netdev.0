From: akpm@linux-foundation.org
Subject: [patch 19/28] netconsole: Remove bogus check
Date: Fri, 10 Aug 2007 14:12:03 -0700
Message-ID: <200708102112.l7ALC3DC009436@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	satyam@infradead.org, k-keiichi@bx.jp.nec.com, mpm@selenic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49242 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942233AbXHJVM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>

Based upon initial work by Keiichi Kii <k-keiichi@bx.jp.nec.com>.

The (!np.dev) check in write_msg() is bogus (always false), because: np.dev is
set by netpoll_setup(), which is called by init_netconsole() before
register_console(), so write_msg() cannot be triggered unless netpoll_setup()
successfully set np.dev.  Also np.dev cannot go away from under us, because
netpoll_setup() grabs us reference on it.  So let's remove the bogus check.

Signed-off-by: Satyam Sharma <satyam@infradead.org>
Acked-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Acked-by: Matt Mackall <mpm@selenic.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/netconsole.c |    3 ---
 1 files changed, 3 deletions(-)

diff -puN drivers/net/netconsole.c~netconsole-remove-bogus-check drivers/net/netconsole.c
--- a/drivers/net/netconsole.c~netconsole-remove-bogus-check
+++ a/drivers/net/netconsole.c
@@ -67,9 +67,6 @@ static void write_msg(struct console *co
 	int frag, left;
 	unsigned long flags;
 
-	if (!np.dev)
-		return;
-
 	local_irq_save(flags);
 
 	for (left = len; left;) {
_
