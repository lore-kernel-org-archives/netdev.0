From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 1/2] drivers: isdn: icn: icn.c: clean up all checkpatch errors
Date: Sat,  7 Feb 2015 17:12:42 +0100
Message-ID: <1423325563-11412-2-git-send-email-baspeters93@gmail.com>
References: <1423325563-11412-1-git-send-email-baspeters93@gmail.com>
Cc: dan.carpenter@oracle.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423325563-11412-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch cleans up various trivial checkpatch errors such as variable
declarations in if statements, return values in parenthesis and a
wrongly placed brace.

Signed-off-by: Bas Peters <baspeters93@gmail.com>
---
 drivers/isdn/icn/icn.c | 52 ++++++++++++++++++++++++++++++--------------------
 1 file changed, 31 insertions(+), 21 deletions(-)

diff --git a/drivers/isdn/icn/icn.c b/drivers/isdn/icn/icn.c
index 6a7447c..f499d5a 100644
--- a/drivers/isdn/icn/icn.c
+++ b/drivers/isdn/icn/icn.c
@@ -62,7 +62,8 @@ icn_free_queue(icn_card *card, int channel)
 	skb_queue_purge(queue);
 	card->xlen[channel] = 0;
 	card->sndcount[channel] = 0;
-	if ((skb = card->xskb[channel])) {
+	skb = card->xskb[channel];
+	if (skb) {
 		card->xskb[channel] = NULL;
 		dev_kfree_skb(skb);
 	}
@@ -272,8 +273,10 @@ icn_pollbchan_receive(int channel, icn_card *card)
 			rbnext;
 			icn_maprelease_channel(card, mch & 2);
 			if (!eflag) {
-				if ((cnt = card->rcvidx[channel])) {
-					if (!(skb = dev_alloc_skb(cnt))) {
+				cnt = card->rcvidx[channel];
+				if (cnt) {
+					skb = dev_alloc_skb(cnt);
+					if (!skb) {
 						printk(KERN_WARNING "icn: receive out of memory\n");
 						break;
 					}
@@ -409,8 +412,7 @@ typedef struct icn_stat {
 	int action;
 } icn_stat;
 /* *INDENT-OFF* */
-static icn_stat icn_stat_table[] =
-{
+static icn_stat icn_stat_table[] = {
 	{"BCON_",          ISDN_STAT_BCONN, 1},	/* B-Channel connected        */
 	{"BDIS_",          ISDN_STAT_BHUP,  2},	/* B-Channel disconnected     */
 	/*
@@ -807,7 +809,8 @@ icn_loadboot(u_char __user *buffer, icn_card *card)
 #ifdef BOOT_DEBUG
 	printk(KERN_DEBUG "icn_loadboot called, buffaddr=%08lx\n", (ulong) buffer);
 #endif
-	if (!(codebuf = kmalloc(ICN_CODE_STAGE1, GFP_KERNEL))) {
+	codebuf = kmalloc(ICN_CODE_STAGE1, GFP_KERNEL);
+	if (!codebuf) {
 		printk(KERN_WARNING "icn: Could not allocate code buffer\n");
 		ret = -ENOMEM;
 		goto out;
@@ -878,7 +881,8 @@ icn_loadboot(u_char __user *buffer, icn_card *card)
 	}
 	SLEEP(1);
 	OUTB_P(0xff, ICN_RUN);  /* Start Boot-Code */
-	if ((ret = icn_check_loader(card->doubleS0 ? 2 : 1))) {
+	ret = icn_check_loader(card->doubleS0 ? 2 : 1);
+	if (ret) {
 		goto out_kfree;
 	}
 	if (!card->doubleS0) {
@@ -1246,10 +1250,11 @@ icn_command(isdn_ctrl *c, icn_card *card)
 				dev.firstload = 0;
 			}
 			icn_stopcard(card);
-			return (icn_loadboot(arg, card));
+			return icn_loadboot(arg, card);
 		case ICN_IOCTL_LOADPROTO:
 			icn_stopcard(card);
-			if ((i = (icn_loadproto(arg, card))))
+			i = icn_loadproto(arg, card);
+			if (i)
 				return i;
 			if (card->doubleS0)
 				i = icn_loadproto(arg + ICN_CODE_STAGE2, card->other);
@@ -1262,7 +1267,7 @@ icn_command(isdn_ctrl *c, icn_card *card)
 					   arg,
 					   sizeof(cdef)))
 				return -EFAULT;
-			return (icn_addcard(cdef.port, cdef.id1, cdef.id2));
+			return icn_addcard(cdef.port, cdef.id1, cdef.id2);
 			break;
 		case ICN_IOCTL_LEASEDCFG:
 			if (a) {
@@ -1458,7 +1463,7 @@ if_command(isdn_ctrl *c)
 	icn_card *card = icn_findcard(c->driver);
 
 	if (card)
-		return (icn_command(c, card));
+		return icn_command(c, card);
 	printk(KERN_ERR
 	       "icn: if_command %d called with invalid driverId %d!\n",
 	       c->command, c->driver);
@@ -1473,7 +1478,7 @@ if_writecmd(const u_char __user *buf, int len, int id, int channel)
 	if (card) {
 		if (!(card->flags & ICN_FLAGS_RUNNING))
 			return -ENODEV;
-		return (icn_writecmd(buf, len, 1, card));
+		return icn_writecmd(buf, len, 1, card);
 	}
 	printk(KERN_ERR
 	       "icn: if_writecmd called with invalid driverId!\n");
@@ -1488,7 +1493,7 @@ if_readstatus(u_char __user *buf, int len, int id, int channel)
 	if (card) {
 		if (!(card->flags & ICN_FLAGS_RUNNING))
 			return -ENODEV;
-		return (icn_readstatus(buf, len, card));
+		return icn_readstatus(buf, len, card);
 	}
 	printk(KERN_ERR
 	       "icn: if_readstatus called with invalid driverId!\n");
@@ -1503,7 +1508,7 @@ if_sendbuf(int id, int channel, int ack, struct sk_buff *skb)
 	if (card) {
 		if (!(card->flags & ICN_FLAGS_RUNNING))
 			return -ENODEV;
-		return (icn_sendbuf(channel, ack, skb, card));
+		return icn_sendbuf(channel, ack, skb, card);
 	}
 	printk(KERN_ERR
 	       "icn: if_sendbuf called with invalid driverId!\n");
@@ -1520,7 +1525,8 @@ icn_initcard(int port, char *id)
 	icn_card *card;
 	int i;
 
-	if (!(card = kzalloc(sizeof(icn_card), GFP_KERNEL))) {
+	card = kzalloc(sizeof(icn_card), GFP_KERNEL);
+	if (!card) {
 		printk(KERN_WARNING
 		       "icn: (%s) Could not allocate card-struct.\n", id);
 		return (icn_card *) 0;
@@ -1568,7 +1574,8 @@ icn_addcard(int port, char *id1, char *id2)
 	icn_card *card;
 	icn_card *card2;
 
-	if (!(card = icn_initcard(port, id1))) {
+	card = icn_initcard(port, id1);
+	if (!card) {
 		return -EIO;
 	}
 	if (!strlen(id2)) {
@@ -1577,7 +1584,8 @@ icn_addcard(int port, char *id1, char *id2)
 		       card->interface.id, port);
 		return 0;
 	}
-	if (!(card2 = icn_initcard(port, id2))) {
+	card2 = icn_initcard(port, id2);
+	if (!card2) {
 		printk(KERN_INFO
 		       "icn: (%s) half ICN-4B, port 0x%x added\n", id2, port);
 		return 0;
@@ -1611,13 +1619,14 @@ icn_setup(char *line)
 	if (str && *str) {
 		strcpy(sid, str);
 		icn_id = sid;
-		if ((p = strchr(sid, ','))) {
+		p = strchr(sid, ',');
+		if (p) {
 			*p++ = 0;
 			strcpy(sid2, p);
 			icn_id2 = sid2;
 		}
 	}
-	return (1);
+	return 1;
 }
 __setup("icn=", icn_setup);
 #endif /* MODULE */
@@ -1634,7 +1643,8 @@ static int __init icn_init(void)
 	dev.firstload = 1;
 	spin_lock_init(&dev.devlock);
 
-	if ((p = strchr(revision, ':'))) {
+	p = strchr(revision, ':');
+	if (p) {
 		strncpy(rev, p + 1, 20);
 		rev[20] = '\0';
 		p = strchr(rev, '$');
@@ -1644,7 +1654,7 @@ static int __init icn_init(void)
 		strcpy(rev, " ??? ");
 	printk(KERN_NOTICE "ICN-ISDN-driver Rev%smem=0x%08lx\n", rev,
 	       dev.memaddr);
-	return (icn_addcard(portbase, icn_id, icn_id2));
+	return icn_addcard(portbase, icn_id, icn_id2);
 }
 
 static void __exit icn_exit(void)
-- 
2.1.0
