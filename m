From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Wed, 11 Aug 2010 18:08:43 +0200
Message-ID: <AANLkTimmJDKbh3_pRY_ASKvjsf4YuuUMh3edh5LvDv-p@mail.gmail.com>
References: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com>
	<20100811095454.GA22543@n2100.arm.linux.org.uk>
	<AANLkTimX46QKAGhiyo8AodaXVjuzoxr5-5z2V4gRr1Vu@mail.gmail.com>
	<20100811150443.GB8867@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	linux-usb <linux-usb@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:35398 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581Ab0HKQIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 12:08:44 -0400
In-Reply-To: <20100811150443.GB8867@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 11, 2010 at 5:04 PM, Greg KH <greg@kroah.com> wrote:
>> Here is a pointer to the thread where it was stated that HCD's don't
>> have to handle this.
>>
>> http://kerneltrap.org/mailarchive/linux-usb/2009/4/20/5528164
>
> No, that thread is about stack vs. heap allocations, not about alignment
> issues.
>

Well although the issue discussed in that thread was caused by a stack
allocation isn't the issue here the same?

My understanding is that a heap allocation as returned by kmalloc() will be:
1) correctly aligned for DMA
and
2) in a memory zone accessible to DMA

whereas a stack allocation is not guaranteed to have either of these properties.

The problem I described in that thread was due to case 1
(misalignment) rather than the stack memory zone not being accessible
at all to DMA.
To which was the reply was basically "use a heap allocation".

So the question is are hcds expected to accept arbitarilly aligned but
heap allocated pointers (such as the result of kmalloc() + 1)?

regards,

Martin









> thanks,
>
> greg k-h
>
