From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH v2 -mm 2/9] netconsole: Remove bogus check
Date: Tue, 10 Jul 2007 14:49:30 +0530
Message-ID: <20070710091930.23907.24600.sendpatchset@cselinux1.cse.iitk.ac.in>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Matt Mackall <mpm@selenic.com>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:42589 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757412AbXGJI5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 04:57:16 -0400
In-Reply-To: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[2/9] netconsole: Remove bogus check

The (!np.dev) check in write_msg() is bogus (always false), because:
np.dev is set by netpoll_setup(), which is called by the target init
code in init_netconsole() _before_ register_console() => write_msg() cannot
be triggered unless netpoll_setup() returns with success. And that will not
happen if netpoll_setup() failed to set np.dev. Also np.dev cannot go from
under us while netconsole is loaded. This is because netpoll_setup() grabs
a reference for us on that dev. So let's remove the pointless check.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>

---

 drivers/net/netconsole.c |    3 ---
 1 file changed, 3 deletions(-)

---

diff -ruNp a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c	2007-07-10 05:53:42.000000000 +0530
+++ b/drivers/net/netconsole.c	2007-07-10 05:55:00.000000000 +0530
@@ -67,9 +67,6 @@ static void write_msg(struct console *co
 	int frag, left;
 	unsigned long flags;
 
-	if (!np.dev)
-		return;
-
 	local_irq_save(flags);
 
 	for (left = len; left;) {
