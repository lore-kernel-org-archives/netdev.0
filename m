From: Pavel Machek <pavel@suse.cz>
Subject: Re: [patch 2/3] hci_usb: remove code obfuscation
Date: Tue, 20 May 2008 17:24:06 +0200
Message-ID: <20080520152405.GC2067@elf.ucw.cz>
References: <200804182046.m3IKks86014628@imap1.linux-foundation.org> <9BEB490E-DE8A-4018-9696-E5074CC638AC@holtmann.org> <20080418223430.GA13847@elf.ucw.cz> <6A7ADC8A-E229-4EC6-9C75-00359946037F@holtmann.org> <20080419161456.GB1577@elf.ucw.cz> <15B7927A-D74F-450D-A6A4-0204FAD455F6@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, hidave.darkstar@gmail.com,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.31.123]:41826 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933252AbYETPXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 11:23:07 -0400
Content-Disposition: inline
In-Reply-To: <15B7927A-D74F-450D-A6A4-0204FAD455F6@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

>> There needs to be some load on the usb. I use
>> rsync-over-bt-over-gprs/umts.
>
> you told me before and I believe you. This driver is not in its best shape. 
> Weird thing is that I never got it re-produced. If you find the real cause. 
> That would be great.

The cause seems to be hci_usb_close() racing with the USB core and
completion handlers...

>>>> It could be easily fixed by just not freeing the urbs during
>>>> disconnect (introducing very very slow memory leak). Would that be
>>>> acceptable?
>>>
>>> I don't think so.
>>>
>>> Have you ever tried btusb driver? That code is a lot cleaner and it uses
>>> USB anchors for the queued URBs (no home grown broken URB queues).
>>
>> I wish I knew about  this one earlier. Yes, it seems to work for me.
>
> Does this mean you are not fixing hci_usb anymore ;)

I'm not sure what's next, as hci_usb is still in opensuse11...
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
