From: Darren Salt <linux@youmustbejoking.demon.co.uk>
Subject: Re: [patch 1/1] r8169 driver: corega support
Date: Sat, 21 Oct 2006 14:52:54 +0100
Message-ID: <4E79505750%linux@youmustbejoking.demon.co.uk>
References: <20061020224438.GA1794@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="1655959972--1994357302--1190768128"
Cc: hchacha@users.sourceforge.net, jeff@garzik.org, syed.azam@hp.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-32.mail.demon.net ([194.217.242.90]:20743 "EHLO
	anchor-post-32.mail.demon.net") by vger.kernel.org with ESMTP
	id S2993016AbWJUOZE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Oct 2006 10:25:04 -0400
To: akpm@osdl.org, romieu@fr.zoreil.com
In-Reply-To: <20061020224438.GA1794@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message is in MIME format which your mailer apparently does not support.
You either require a newer version of your software which supports MIME, or
a separate MIME decoding utility.  Alternatively, ask the sender of this
message to resend it in a different format.

--1655959972--1994357302--1190768128
Content-Type: text/plain; charset=us-ascii

I demand that Francois Romieu may or may not have written...

> akpm@osdl.org <akpm@osdl.org> :
> [Corega adapter support]

> It's queued in the r8169 branch at:

> git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git r8169

> I have sent Jeff a pull request for it (and I'll probably send one
> more for the patch below).

> Darren, can you check if the patch below fixes you link detection
> issue ?

It does, but the patch causes the module to report that the reset failed even
after reporting that it's done. A fix for this is attached.

-- 
| Darren Salt    | linux or ds at              | nr. Ashington, | Toon
| RISC OS, Linux | youmustbejoking,demon,co,uk | Northumberland | Army
| + Generate power using sun, wind, water, nuclear.      FORGET COAL AND OIL.

Life is what happens when you're busy making other plans.

--1655959972--1994357302--1190768128
Content-Type: text/plain; charset=iso-8859-1; name="r8169-PHY-reset-report-fix.patch"
Content-Disposition: attachment; filename="r8169-PHY-reset-report-fix.patch"
Content-Transfer-Encoding: quoted-printable

Avoid reporting that the PHY reset has failed when it's just succeeded.

Signed-off-by: Darren Salt <linux@youmustbejoking.demon.co.uk>

diff a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1452,7 +1452,7 @@ static void rtl8169_release_board(struct
 	for (i =3D 0; i < 100; i++) {
 		if (!tp->phy_reset_pending(ioaddr)) {
 			printk(KERN_INFO "%s: PHY reset done.\n", dev->name);
-			break;
+			return;
 		}
 		msleep(1);
 	}

--1655959972--1994357302--1190768128--
