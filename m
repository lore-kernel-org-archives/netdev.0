From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading
 (-git7 is ok)
Date: Mon, 12 Jan 2009 08:13:59 +0000
Message-ID: <1231748039.25018.1277.camel@macbook.infradead.org>
References: <5a4c581d0901090930j5d4760b0x730b5609fa2b5614@mail.gmail.com>
	 <20090109.140422.60087297.davem@davemloft.net>
	 <43805.1231672258@turing-police.cc.vt.edu>
	 <20090111.040842.86784676.davem@davemloft.net>
	 <1231676698.25018.147.camel@macbook.infradead.org>
	 <1231678799.25018.195.camel@macbook.infradead.org>
	 <4407.1231719036@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alessandro.suardi@gmail.com,
	jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41125 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbZALIOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 03:14:05 -0500
In-Reply-To: <4407.1231719036@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-01-11 at 19:10 -0500, Valdis.Kletnieks@vt.edu wrote:
> So it looks like the patch is failing to finish initialization of the card.
> Damned if *I* can see what's breaking it, the conversion to use a helper
> function tg3_request_firmware seems sane enough....

Ahem...

--- drivers/net/tg3.c.stupiddwmw2	2009-01-12 08:13:05.000000000 +0000
+++ drivers/net/tg3.c	2009-01-12 08:13:09.000000000 +0000
@@ -13151,7 +13151,7 @@ static int __devinit tg3_init_one(struct
 		   try again in tg3_open(). So if you have the driver built
 		   into the kernel, you can still get the firmware loaded
 		   after userspace is running, when the device comes up. */
-		if (err != -ENOENT)
+		if (err && err != -ENOENT)
 			goto err_out_fw;
 	}
 

-- 
dwmw2

