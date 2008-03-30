From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: [PATCH] sb1000.c: make const arrays static
Date: Mon, 31 Mar 2008 01:13:00 +0200
Message-ID: <200803310113.00843.vda.linux@googlemail.com>
References: <200803310102.43277.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_85B8HPUs6wb9g7b"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:47127 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758964AbYC3XOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2008 19:14:45 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1557186fgb.17
        for <netdev@vger.kernel.org>; Sun, 30 Mar 2008 16:14:42 -0700 (PDT)
In-Reply-To: <200803310102.43277.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_85B8HPUs6wb9g7b
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Monday 31 March 2008 01:02, Denys Vlasenko wrote:
> Size difference for 32bit x86:
> 
>    text    data     bss     dec     hex filename
>    6299     129       0    6428    191c linux-2.6-ALLYES/drivers/net/sb1000.o
>    5418     129       0    5547    15ab linux-2.6.inline-ALLYES/drivers/net/sb1000.o
> 
> (I also see some other optimization opportunities,
> will test and send a patch separately).

Here it is. It replaces automatic constant arrays a-la

    const unsigned char Command0[6] = {0x80, 0x16, 0x00, 0x00, 0x00, 0x00};

with static ones. Size difference for 32bit x86:

   text    data     bss     dec     hex filename
   5418     129       0    5547    15ab linux-2.6.inline-ALLYES/drivers/net/sb1000.o
   5396     129       0    5525    1595 linux-2.6.followup-ALLYES/drivers/net/sb1000.o

Signed-off-by: Denys Vlasenko <vda.linux@googlemail.com>
--
vda


--Boundary-00=_85B8HPUs6wb9g7b
Content-Type: text/x-diff;
  charset="koi8-r";
  name="sb1000_make_const_arrays_static.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sb1000_make_const_arrays_static.diff"

diff -urp linux-2.6.inline/drivers/net/sb1000.c linux-2.6.followup/drivers/net/sb1000.c
--- linux-2.6.inline/drivers/net/sb1000.c	2008-03-31 00:46:20.000000000 +0200
+++ linux-2.6.followup/drivers/net/sb1000.c	2008-03-31 01:04:57.000000000 +0200
@@ -437,7 +437,7 @@ sb1000_read_status(const int ioaddr[], u
 static void
 sb1000_issue_read_command(const int ioaddr[], const char* name)
 {
-	const unsigned char Command0[6] = {0x20, 0x00, 0x00, 0x01, 0x00, 0x00};
+	static const unsigned char Command0[6] = {0x20, 0x00, 0x00, 0x01, 0x00, 0x00};
 
 	sb1000_wait_for_ready_clear(ioaddr, name);
 	outb(0xa0, ioaddr[0] + 6);
@@ -453,9 +453,10 @@ sb1000_issue_read_command(const int ioad
 static int
 sb1000_reset(const int ioaddr[], const char* name)
 {
+	static const unsigned char Command0[6] = {0x80, 0x16, 0x00, 0x00, 0x00, 0x00};
+
 	unsigned char st[7];
 	int port, status;
-	const unsigned char Command0[6] = {0x80, 0x16, 0x00, 0x00, 0x00, 0x00};
 
 	port = ioaddr[1] + 6;
 	outb(0x4, port);
@@ -482,9 +483,10 @@ sb1000_reset(const int ioaddr[], const c
 static int
 sb1000_check_CRC(const int ioaddr[], const char* name)
 {
+	static const unsigned char Command0[6] = {0x80, 0x1f, 0x00, 0x00, 0x00, 0x00};
+
 	unsigned char st[7];
 	int crc, status;
-	const unsigned char Command0[6] = {0x80, 0x1f, 0x00, 0x00, 0x00, 0x00};
 
 	/* check CRC */
 	if ((status = card_send_command(ioaddr, name, Command0, st)))
@@ -498,8 +500,9 @@ sb1000_check_CRC(const int ioaddr[], con
 static inline int
 sb1000_start_get_set_command(const int ioaddr[], const char* name)
 {
+	static const unsigned char Command0[6] = {0x80, 0x1b, 0x00, 0x00, 0x00, 0x00};
+
 	unsigned char st[7];
-	const unsigned char Command0[6] = {0x80, 0x1b, 0x00, 0x00, 0x00, 0x00};
 
 	return card_send_command(ioaddr, name, Command0, st);
 }
@@ -507,10 +510,11 @@ sb1000_start_get_set_command(const int i
 static int
 sb1000_end_get_set_command(const int ioaddr[], const char* name)
 {
+	static const unsigned char Command0[6] = {0x80, 0x1b, 0x02, 0x00, 0x00, 0x00};
+	static const unsigned char Command1[6] = {0x20, 0x00, 0x00, 0x00, 0x00, 0x00};
+
 	unsigned char st[7];
 	int status;
-	const unsigned char Command0[6] = {0x80, 0x1b, 0x02, 0x00, 0x00, 0x00};
-	const unsigned char Command1[6] = {0x20, 0x00, 0x00, 0x00, 0x00, 0x00};
 
 	if ((status = card_send_command(ioaddr, name, Command0, st)))
 		return status;
@@ -520,10 +524,11 @@ sb1000_end_get_set_command(const int ioa
 static int
 sb1000_activate(const int ioaddr[], const char* name)
 {
+	static const unsigned char Command0[6] = {0x80, 0x11, 0x00, 0x00, 0x00, 0x00};
+	static const unsigned char Command1[6] = {0x80, 0x16, 0x00, 0x00, 0x00, 0x00};
+
 	unsigned char st[7];
 	int status;
-	const unsigned char Command0[6] = {0x80, 0x11, 0x00, 0x00, 0x00, 0x00};
-	const unsigned char Command1[6] = {0x80, 0x16, 0x00, 0x00, 0x00, 0x00};
 
 	ssleep(1);
 	if ((status = card_send_command(ioaddr, name, Command0, st)))
@@ -544,9 +549,10 @@ static int
 sb1000_get_firmware_version(const int ioaddr[], const char* name,
 	unsigned char version[], int do_end)
 {
+	static const unsigned char Command0[6] = {0x80, 0x23, 0x00, 0x00, 0x00, 0x00};
+
 	unsigned char st[7];
 	int status;
-	const unsigned char Command0[6] = {0x80, 0x23, 0x00, 0x00, 0x00, 0x00};
 
 	if ((status = sb1000_start_get_set_command(ioaddr, name)))
 		return status;
@@ -566,9 +572,10 @@ sb1000_get_firmware_version(const int io
 static int
 sb1000_get_frequency(const int ioaddr[], const char* name, int* frequency)
 {
+	static const unsigned char Command0[6] = {0x80, 0x44, 0x00, 0x00, 0x00, 0x00};
+
 	unsigned char st[7];
 	int status;
-	const unsigned char Command0[6] = {0x80, 0x44, 0x00, 0x00, 0x00, 0x00};
 
 	udelay(1000);
 	if ((status = sb1000_start_get_set_command(ioaddr, name)))
@@ -613,12 +620,13 @@ sb1000_set_frequency(const int ioaddr[],
 static int
 sb1000_get_PIDs(const int ioaddr[], const char* name, short PID[])
 {
+	static const unsigned char Command0[6] = {0x80, 0x40, 0x00, 0x00, 0x00, 0x00};
+	static const unsigned char Command1[6] = {0x80, 0x41, 0x00, 0x00, 0x00, 0x00};
+	static const unsigned char Command2[6] = {0x80, 0x42, 0x00, 0x00, 0x00, 0x00};
+	static const unsigned char Command3[6] = {0x80, 0x43, 0x00, 0x00, 0x00, 0x00};
+
 	unsigned char st[7];
 	int status;
-	const unsigned char Command0[6] = {0x80, 0x40, 0x00, 0x00, 0x00, 0x00};
-	const unsigned char Command1[6] = {0x80, 0x41, 0x00, 0x00, 0x00, 0x00};
-	const unsigned char Command2[6] = {0x80, 0x42, 0x00, 0x00, 0x00, 0x00};
-	const unsigned char Command3[6] = {0x80, 0x43, 0x00, 0x00, 0x00, 0x00};
 
 	udelay(1000);
 	if ((status = sb1000_start_get_set_command(ioaddr, name)))
@@ -647,6 +655,8 @@ sb1000_get_PIDs(const int ioaddr[], cons
 static int
 sb1000_set_PIDs(const int ioaddr[], const char* name, const short PID[])
 {
+	static const unsigned char Command4[6] = {0x80, 0x2e, 0x00, 0x00, 0x00, 0x00};
+
 	unsigned char st[7];
 	short p;
 	int status;
@@ -654,7 +664,6 @@ sb1000_set_PIDs(const int ioaddr[], cons
 	unsigned char Command1[6] = {0x80, 0x32, 0x00, 0x00, 0x00, 0x00};
 	unsigned char Command2[6] = {0x80, 0x33, 0x00, 0x00, 0x00, 0x00};
 	unsigned char Command3[6] = {0x80, 0x34, 0x00, 0x00, 0x00, 0x00};
-	const unsigned char Command4[6] = {0x80, 0x2e, 0x00, 0x00, 0x00, 0x00};
 
 	udelay(1000);
 	if ((status = sb1000_start_get_set_command(ioaddr, name)))
@@ -891,11 +900,12 @@ dropped_frame:
 static void
 sb1000_error_dpc(struct net_device *dev)
 {
+	static const unsigned char Command0[6] = {0x80, 0x26, 0x00, 0x00, 0x00, 0x00};
+
 	char *name;
 	unsigned char st[5];
 	int ioaddr[2];
 	struct sb1000_private *lp = netdev_priv(dev);
-	const unsigned char Command0[6] = {0x80, 0x26, 0x00, 0x00, 0x00, 0x00};
 	const int ErrorDpcCounterInitialize = 200;
 
 	ioaddr[0] = dev->base_addr;
@@ -1077,14 +1087,15 @@ sb1000_start_xmit(struct sk_buff *skb, s
 /* SB1000 interrupt handler. */
 static irqreturn_t sb1000_interrupt(int irq, void *dev_id)
 {
+	static const unsigned char Command0[6] = {0x80, 0x2c, 0x00, 0x00, 0x00, 0x00};
+	static const unsigned char Command1[6] = {0x80, 0x2e, 0x00, 0x00, 0x00, 0x00};
+
 	char *name;
 	unsigned char st;
 	int ioaddr[2];
 	struct net_device *dev = dev_id;
 	struct sb1000_private *lp = netdev_priv(dev);
 
-	const unsigned char Command0[6] = {0x80, 0x2c, 0x00, 0x00, 0x00, 0x00};
-	const unsigned char Command1[6] = {0x80, 0x2e, 0x00, 0x00, 0x00, 0x00};
 	const int MaxRxErrorCount = 6;
 
 	ioaddr[0] = dev->base_addr;

--Boundary-00=_85B8HPUs6wb9g7b--
