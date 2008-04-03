From: Sebastian Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 0/5] fixup locking on m68knommu fec
Date: Thu, 3 Apr 2008 09:52:12 +0200
Message-ID: <20080403075212.GC778@Chamillionaire.breakpoint.cc>
References: <20080402204417.597098190@linutronix.de> <47F47F0E.9030803@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	uclinux-dev@uclinux.org
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:50788 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756429AbYDCHw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 03:52:27 -0400
Content-Disposition: inline
In-Reply-To: <47F47F0E.9030803@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Greg Ungerer | 2008-04-03 16:54:06 [+1000]:

> Hi Sebastian,
Hi Greg,

> Sebastian Siewior wrote:
>> This series basically fixes my locking problem. We have here:
>> #1 the old one which removes some undefined vars.
>> #2 cleans the file with lident. I had trouble reading the code...
>> #3 type def a function pointer so we don't have the long defines
>>    and move the callback after releasing the lock.
>> #4 This one fixes the locking I guess. My mcf5235 did not race anymore
>>    after that one. I saw 0a504779d while forming the patch so I guess
>>    we could revert that one, Greg?
>
> Yes, certainly we can.
> I'd like to do some testing on this as well :-)
No problem. I did ping -f from one box and a single ping from another
box for like an hour.
The only thing I don't really like is that do { } while (int flags) in
the ISR. Is the interrupt level or edge? /proc/interrupts wasn't clear on
this if I remember correctly.

>> #5 removes the registration of interrupt handlers & enabling interrupt
>>    sources that are not handled. I stepped into this after I thought that
>>    it is over :) Greg, Should we also remove that part where we enable
>>    the irq controller (I though request_irq() is doing that).
>
> Currently it doesn't. The main sticking point is what to do
> with the hardware based priority setting logic. We don't really
> rely on it, but they need to be set to sane values.
>
> Need to expand the interrupt controller setup code some more
> before we can take that out.
Okey.

> Regards
> Greg

Sebastian
