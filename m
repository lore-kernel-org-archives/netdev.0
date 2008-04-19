From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [patch 2/3] hci_usb: remove code obfuscation
Date: Sat, 19 Apr 2008 18:14:56 +0200
Message-ID: <20080419161456.GB1577@elf.ucw.cz>
References: <200804182046.m3IKks86014628@imap1.linux-foundation.org> <9BEB490E-DE8A-4018-9696-E5074CC638AC@holtmann.org> <20080418223430.GA13847@elf.ucw.cz> <6A7ADC8A-E229-4EC6-9C75-00359946037F@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, hidave.darkstar@gmail.com,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.31.123]:34745 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281AbYDSQOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 12:14:20 -0400
Content-Disposition: inline
In-Reply-To: <6A7ADC8A-E229-4EC6-9C75-00359946037F@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

>>>> _urb_free is an alias for kfree... making code longer & harder to
>>>> read. Remove it.
>>>
>>> our own URB handling here is broken anyway. It was a bad idea when we did
>>> it, but at that time the USB susbsystem was not in that good shape that 
>>> it
>>> is today. So I would say leave this code as it is and concentrate on the
>>> new btusb driver, but if it helps anybody I am happy to ACK this one.
>>
>> It currently corrupts memory (use after free) during suspend, and I'm
>> trying to get that fixed. It is 90% reproducible.
>
> that is good, because I can't reproduce it with any of my system. Don't ask 
> me why. I really simply works. So if you figure it out, it would be great.

There needs to be some load on the usb. I use
rsync-over-bt-over-gprs/umts.

>> It could be easily fixed by just not freeing the urbs during
>> disconnect (introducing very very slow memory leak). Would that be
>> acceptable?
>
> I don't think so.
>
> Have you ever tried btusb driver? That code is a lot cleaner and it uses 
> USB anchors for the queued URBs (no home grown broken URB queues).

I wish I knew about  this one earlier. Yes, it seems to work for me.

								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
