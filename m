From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx: further fix for periodic work errors
Date: Sat, 23 Sep 2006 15:05:52 -0500
Message-ID: <451593A0.8030104@lwfinger.net>
References: <4514B322.mail1K91A36N8@lwfinger.net> <200609230956.05475.mb@bu3sch.de> <451585D1.3080102@lwfinger.net> <200609232141.20720.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	Stefano Brivio <st3@riseup.net>,
	John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:56292 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751530AbWIWUGG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 16:06:06 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609232141.20720.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> 
> Well, even _if_ mac_suspend takes a few milliseconds (which it
> does not), it would not trigger the watchdog.
> I measured the time it takes to execute the various works
> and based the badness selection on the results.
> 
> If the 15 or 30 second work is really able to trigger a watchdog
> timeout, it's a _bug_ that needs to be fixed and not to be
> papered over.
> It won't trigger the watchdog, because it is running too long
> uninterruptible (it won't run 5sec...). If it triggers, it's
> triggered by something else (like the synchronize_net thingie
> in the past).

Even the synchronize_net problem wasn't taking 5 seconds to complete, it was messing up the transmit 
process.

I went back to check my logs again, and the actual error was "BCM43xx_IRQ_XMIT_ERROR", which is 
always preceded by a MAC suspend failed. These never happened all the time I was running with 
MAXIMUM_BADNESS of 0.

I think the _bug_ is letting the transmit process run while doing the periodic work, which is why 
I'm testing with the tx_disable before all periodic work. I'll let you know in 2 or 3 days if it 
fixes the problem. It takes that long to trigger.

Larry


Larry


