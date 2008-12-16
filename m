From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 6/11] drivers/net/hamradio: Move a dereference below a NULL
 test
Date: Tue, 16 Dec 2008 16:13:50 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0812161613320.20444@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:59739 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756088AbYLPPNx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 10:13:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

In each case, if the NULL test is necessary, then the dereference should be
moved below the NULL test.

The semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
type T;
expression E;
identifier i,fld;
statement S;
@@

- T i = E->fld;
+ T i;
  ... when != E
      when != i
  if (E == NULL) S
+ i = E->fld;
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/hamradio/mkiss.c        |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index b8e25c4..e5770d1 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -847,12 +847,13 @@ static int mkiss_ioctl(struct tty_struct *tty, struct file *file,
 	unsigned int cmd, unsigned long arg)
 {
 	struct mkiss *ax = mkiss_get(tty);
-	struct net_device *dev = ax->dev;
+	struct net_device *dev;
 	unsigned int tmp, err;
 
 	/* First make sure we're connected. */
 	if (ax == NULL)
 		return -ENXIO;
+	dev = ax->dev;
 
 	switch (cmd) {
  	case SIOCGIFNAME:
