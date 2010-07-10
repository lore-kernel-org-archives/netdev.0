From: Dan Carpenter <error27@gmail.com>
Subject: [patch] isdn: fix strlen() usage
Date: Sat, 10 Jul 2010 16:31:11 +0200
Message-ID: <20100710143111.GA19184@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Dirk Hohndel <hohndel@infradead.org>,
	Jiri Kosina <jkosina@suse.cz>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38548 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab0GJOco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 10:32:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was a missing "else" statement so the original code overflowed if
->master->name was too long.  Also the ->slave and ->master buffers can
hold names with 9 characters and a NULL so I cleaned it up to allow
another character.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 8c85d1e..26d44c3 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -2924,16 +2924,17 @@ isdn_net_getcfg(isdn_net_ioctl_cfg * cfg)
 		cfg->dialtimeout = lp->dialtimeout >= 0 ? lp->dialtimeout / HZ : -1;
 		cfg->dialwait = lp->dialwait / HZ;
 		if (lp->slave) {
-			if (strlen(lp->slave->name) > 8)
+			if (strlen(lp->slave->name) >= 10)
 				strcpy(cfg->slave, "too-long");
 			else
 				strcpy(cfg->slave, lp->slave->name);
 		} else
 			cfg->slave[0] = '\0';
 		if (lp->master) {
-			if (strlen(lp->master->name) > 8)
+			if (strlen(lp->master->name) >= 10)
 				strcpy(cfg->master, "too-long");
-			strcpy(cfg->master, lp->master->name);
+			else
+				strcpy(cfg->master, lp->master->name);
 		} else
 			cfg->master[0] = '\0';
 		return 0;
