From: akpm@linux-foundation.org
Subject: [patch 2/4] drivers/net/hamradio/6pack.c: move a dereference below a NULL test
Date: Fri, 09 Jan 2009 12:23:09 -0800
Message-ID: <200901092023.n09KN91a020170@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50309 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754846AbZAIUXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 15:23:45 -0500
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
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/hamradio/6pack.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/net/hamradio/6pack.c~drivers-net-hamradio-6packc-move-a-dereference-below-a-null-test drivers/net/hamradio/6pack.c
--- a/drivers/net/hamradio/6pack.c~drivers-net-hamradio-6packc-move-a-dereference-below-a-null-test
+++ a/drivers/net/hamradio/6pack.c
@@ -717,11 +717,12 @@ static int sixpack_ioctl(struct tty_stru
 	unsigned int cmd, unsigned long arg)
 {
 	struct sixpack *sp = sp_get(tty);
-	struct net_device *dev = sp->dev;
+	struct net_device *dev;
 	unsigned int tmp, err;
 
 	if (!sp)
 		return -ENXIO;
+	dev = sp->dev;
 
 	switch(cmd) {
 	case SIOCGIFNAME:
_
