From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH 2/2] tty: driverdata and discdata are void *
Date: Fri, 05 Dec 2008 17:10:46 +0000
Message-ID: <20081205171044.3528.20062.stgit@localhost.localdomain>
References: <20081205170846.3528.67581.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:46240 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751148AbYLERKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 12:10:35 -0500
In-Reply-To: <20081205170846.3528.67581.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@redhat.com>

Remove all the extra casting while we are cleaning up

Signed-off-by: Alan Cox <alan@redhat.com>
---

 drivers/net/wan/x25_asy.c    |   10 +++++-----
 drivers/net/wireless/strip.c |   10 +++++-----
 2 files changed, 10 insertions(+), 10 deletions(-)


diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index e188699..762fb13 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -258,7 +258,7 @@ static void x25_asy_encaps(struct x25_asy *sl, unsigned char *icp, int len)
 static void x25_asy_write_wakeup(struct tty_struct *tty)
 {
 	int actual;
-	struct x25_asy *sl = (struct x25_asy *) tty->disc_data;
+	struct x25_asy *sl = tty->disc_data;
 
 	/* First make sure we're connected. */
 	if (!sl || sl->magic != X25_ASY_MAGIC || !netif_running(sl->dev))
@@ -527,7 +527,7 @@ static int x25_asy_close(struct net_device *dev)
 static void x25_asy_receive_buf(struct tty_struct *tty,
 				const unsigned char *cp, char *fp, int count)
 {
-	struct x25_asy *sl = (struct x25_asy *) tty->disc_data;
+	struct x25_asy *sl = tty->disc_data;
 
 	if (!sl || sl->magic != X25_ASY_MAGIC || !netif_running(sl->dev))
 		return;
@@ -555,7 +555,7 @@ static void x25_asy_receive_buf(struct tty_struct *tty,
 
 static int x25_asy_open_tty(struct tty_struct *tty)
 {
-	struct x25_asy *sl = (struct x25_asy *) tty->disc_data;
+	struct x25_asy *sl = tty->disc_data;
 	int err;
 
 	if (tty->ops->write == NULL)
@@ -596,7 +596,7 @@ static int x25_asy_open_tty(struct tty_struct *tty)
  */
 static void x25_asy_close_tty(struct tty_struct *tty)
 {
-	struct x25_asy *sl = (struct x25_asy *) tty->disc_data;
+	struct x25_asy *sl = tty->disc_data;
 
 	/* First make sure we're connected. */
 	if (!sl || sl->magic != X25_ASY_MAGIC)
@@ -696,7 +696,7 @@ static void x25_asy_unesc(struct x25_asy *sl, unsigned char s)
 static int x25_asy_ioctl(struct tty_struct *tty, struct file *file,
 			 unsigned int cmd,  unsigned long arg)
 {
-	struct x25_asy *sl = (struct x25_asy *) tty->disc_data;
+	struct x25_asy *sl = tty->disc_data;
 
 	/* First make sure we're connected. */
 	if (!sl || sl->magic != X25_ASY_MAGIC)
diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index 35442b1..b141773 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -1234,7 +1234,7 @@ static void ResetRadio(struct strip *strip_info)
 
 static void strip_write_some_more(struct tty_struct *tty)
 {
-	struct strip *strip_info = (struct strip *) tty->disc_data;
+	struct strip *strip_info = tty->disc_data;
 
 	/* First make sure we're connected. */
 	if (!strip_info || strip_info->magic != STRIP_MAGIC ||
@@ -2260,7 +2260,7 @@ static void process_message(struct strip *strip_info)
 static void strip_receive_buf(struct tty_struct *tty, const unsigned char *cp,
 		  char *fp, int count)
 {
-	struct strip *strip_info = (struct strip *) tty->disc_data;
+	struct strip *strip_info = tty->disc_data;
 	const unsigned char *end = cp + count;
 
 	if (!strip_info || strip_info->magic != STRIP_MAGIC
@@ -2596,7 +2596,7 @@ static struct strip *strip_alloc(void)
 
 static int strip_open(struct tty_struct *tty)
 {
-	struct strip *strip_info = (struct strip *) tty->disc_data;
+	struct strip *strip_info = tty->disc_data;
 
 	/*
 	 * First make sure we're not already connected.
@@ -2667,7 +2667,7 @@ static int strip_open(struct tty_struct *tty)
 
 static void strip_close(struct tty_struct *tty)
 {
-	struct strip *strip_info = (struct strip *) tty->disc_data;
+	struct strip *strip_info = tty->disc_data;
 
 	/*
 	 * First make sure we're connected.
@@ -2693,7 +2693,7 @@ static void strip_close(struct tty_struct *tty)
 static int strip_ioctl(struct tty_struct *tty, struct file *file,
 		       unsigned int cmd, unsigned long arg)
 {
-	struct strip *strip_info = (struct strip *) tty->disc_data;
+	struct strip *strip_info = tty->disc_data;
 
 	/*
 	 * First make sure we're connected.

