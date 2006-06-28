From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 28 Jun 2006 11:04:02 -0500
Message-ID: <44A2A872.3050905@lwfinger.net>
References: <20060626212547.GE30706@tuxdriver.com> <200606272223.19928.mb@bu3sch.de> <44A19712.40702@lwfinger.net> <200606281634.24160.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:35030 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751254AbWF1QEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 12:04:14 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606281634.24160.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> 
> It appears to be an older card. There are quite some
> special codepaths for this, I think.

Yes, I bought this card before the G specifications were finalized.

> Well, we did not want to have the card, because at this point
> it did not make sense. We all have 4306 cards.
> But now it appears that this card seems to have some special
> things (because it is older than ours).
> 
> Well, how to debug.
> We are waiting for the IRQ Reason register there.
> Actually, we are waiting for the "no IRQ pending, but READY signal"
> state. Your card does not completely (?) clear the bits after MAC
> shutdown. So very helpful would be to print out in the loop the
> value. We know, that the card generates silly IRQs, that we did
> not ask for. That may happen here, too. So it _may_ help to
> mask out unwanted IRQs before the if-check. But I would first
> like to see a log of the reason-value on each iteration until it succeeds.

First of all, I have a udelay(1) in the wait loop. I have also moved the udelay to the top of the 
loop. For the past 12 hours, I have been printing the delay time for the cases where it took more 
than 2 passes through the loop. There have been single instances of 3 and 4 usec; otherwise the 
delay is much longer, with the largest delay at 750 usec. The long delays are always found during 
scanning, associating, and authenticating. I use WPA with wpa_supplicant.

Since adding the dump of IRQ reason, every case that took more than 1 pass through the loop has had 
an IRQ reason of 0x0580 for every pass in the loop. Your idea about the silly IRQ's seems to be 
right. I'll let you know if I get any results that are different.

One other little problem. If I do an ifdown/ifup sequence without unloading the bcm43xx module, I 
get a failure of the assert(bcm->mac_suspended >= 0) at the beginning of bcm43xx_mac_suspend.

Larry



