From: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
Subject: Re: [PATCH] obsolete config in kernel source (HSO_AUTOPM)
Date: Fri, 5 Feb 2010 16:14:02 +0100
Message-ID: <20100205151402.GB7299@faui49.informatik.uni-erlangen.de>
References: <20100205133918.GA7077__48535.5327524759$1265377184$gmane$org@faui49.informatik.uni-erlangen.de>
 <4B6C2D78.20603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:62975 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932309Ab0BEPNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 10:13:48 -0500
Content-Disposition: inline
In-Reply-To: <4B6C2D78.20603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 05, 2010 at 04:38:48PM +0200, Paulius Zaleckas wrote:
> On 02/05/2010 03:39 PM, Christoph Egger wrote:
> >Hi all!
> >
> >	As part of the VAMOS[0] research project at the University of
> >Erlangen we're checking referential integrity between kernel KConfig
> >options and in-code Conditional blocks.
> >
> >	This is just a one-liner commented out unconditionally (due to
> >the config not existing) and being like this for virtually ever so I'm
> >suggesting to remove it from the kernel tree.
> >
> >	Please keep me informed of this patch getting confirmed /
> >merged so we can keep track of it.
> >
> >diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> >index 6895f15..be0cc99 100644
> >--- a/drivers/net/usb/hso.c
> >+++ b/drivers/net/usb/hso.c
> >@@ -1155,9 +1155,6 @@ static void _hso_serial_set_termios(struct tty_struct *tty,
> >  static void hso_resubmit_rx_bulk_urb(struct hso_serial *serial, struct urb *urb)
> >  {
> >  	int result;
> >-#ifdef CONFIG_HSO_AUTOPM
> >-	usb_mark_last_busy(urb->dev);
> >-#endif
> 
> Acctually this is bug. usb_mark_last_busy() should be called here.
> Can you resend this patch by just removing #ifdef and #endif and
> leaving usb_mark_last_busy()?

OK here comes the updated patch

-----
>From f9797bb502566cd9e4db8b1bb7bb213f7f1d64ed Mon Sep 17 00:00:00 2001
From: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
Date: Fri, 5 Feb 2010 16:10:29 +0100
Subject: [PATCH] Remove unreferenced HSO_AUTOPM

CONFIG_HSO_AUTOPM is not set by KConfig / set in the Kernel source,
makefiles and won't be ever set this way. However the unreachable code
is actually needed as reported by Paulius Zaleckas so just removing
the checks.

Signed-off-by: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
---
 drivers/net/usb/hso.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 6895f15..de466ee 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1155,9 +1155,7 @@ static void _hso_serial_set_termios(struct tty_struct *tty,
 static void hso_resubmit_rx_bulk_urb(struct hso_serial *serial, struct urb *urb)
 {
 	int result;
-#ifdef CONFIG_HSO_AUTOPM
 	usb_mark_last_busy(urb->dev);
-#endif
 	/* We are done with this URB, resubmit it. Prep the USB to wait for
 	 * another frame */
 	usb_fill_bulk_urb(urb, serial->parent->usb,
-- 
1.6.3.3


