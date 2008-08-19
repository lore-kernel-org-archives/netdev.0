From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: 2.6.26/tg3 ping roundtrip times > 2000 ms on local network
Date: Tue, 19 Aug 2008 15:30:25 -0700
Message-ID: <20080819223025.GA11221@xw6200.broadcom.net>
References: <20080819172019.GA5823@torres.zugschlus.de>
 <20080819.132040.188336475.davem@davemloft.net>
 <1219166962.13090.12.camel@HP1>
 <20080819221439.GA19106@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary=3V7upXqbjpZ4EhLz
Cc: "Michael Chan" <mchan@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "Marc Haber" <mh+linux-kernel@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2012 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752747AbYHSWa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 18:30:26 -0400
In-Reply-To: <20080819221439.GA19106@torres.zugschlus.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3V7upXqbjpZ4EhLz
Content-Type: text/plain;
 charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Can you try the attached patch?  The patch reduces the delay back to
what it should have been.  If this helps, then it means you are being
bitten by the same bug the upstream patch fixed.

On Tue, Aug 19, 2008 at 03:14:39PM -0700, Marc Haber wrote:
> On Tue, Aug 19, 2008 at 10:29:22AM -0700, Michael Chan wrote:
> > It has been fixed a few days ago in the net-2.6 tree:
> >
> > tg3: Fix firmware event timeouts
> >
> > and it should be in Linus' tree very soon.  This reminds us to send the
> > same patch to -stable.
> 
> Not having much clue about git, can you send me the patch to try
> locally?
> 
> I am not even sure to have a network issue here.
> 
> Greetings
> Marc
> 
> --
> -----------------------------------------------------------------------------
> Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
> Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
> Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
> 

--3V7upXqbjpZ4EhLz
Content-Type: text/plain;
 charset=us-ascii
Content-Disposition: attachment;
 filename=timeout.patch
Content-Transfer-Encoding: 7bit

diff -Nrup a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	2008-08-06 09:19:01.000000000 -0700
+++ b/drivers/net/tg3.c	2008-08-19 15:26:50.000000000 -0700
@@ -1677,7 +1677,7 @@ static void tg3_wait_for_event_ack(struc
 	int i;
 
 	/* Wait for up to 2.5 milliseconds */
-	for (i = 0; i < 250000; i++) {
+	for (i = 0; i < 250; i++) {
 		if (!(tr32(GRC_RX_CPU_EVENT) & GRC_RX_CPU_DRIVER_EVENT))
 			break;
 		udelay(10);

--3V7upXqbjpZ4EhLz--

