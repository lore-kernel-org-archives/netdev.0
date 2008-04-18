From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Fri, 18 Apr 2008 19:19:17 +0200
Message-ID: <200804181919.17456.mb@bu3sch.de>
References: <bug-10473-10286@http.bugzilla.kernel.org/> <200804181732.48546.mb@bu3sch.de> <9bfa9ae0804181012l451687d8o7e6ce1f5213ff716@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Nelson A. de Oliveira" <naoliv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:45884 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758037AbYDRRTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 13:19:53 -0400
In-Reply-To: <9bfa9ae0804181012l451687d8o7e6ce1f5213ff716@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 18 April 2008 19:12:34 Nelson A. de Oliveira wrote:
> Anything else that I can do to help, please?

Please apply this patch and send me the messages.

Index: wireless-testing/drivers/net/b44.c
===================================================================
--- wireless-testing.orig/drivers/net/b44.c	2008-04-15 12:40:17.000000000 +0200
+++ wireless-testing/drivers/net/b44.c	2008-04-18 19:18:02.000000000 +0200
@@ -866,6 +866,7 @@ static int b44_poll(struct napi_struct *
 	if (bp->istat & ISTAT_ERRORS) {
 		unsigned long flags;
 
+printk(KERN_ERR "b44_poll: istat = 0x%08X\n", bp->istat);
 		spin_lock_irqsave(&bp->lock, flags);
 		b44_halt(bp);
 		b44_init_rings(bp);


-- 
Greetings Michael.
