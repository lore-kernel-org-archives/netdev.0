From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: 82557/8/9 Ethernet Pro 100 interrupt mitigation support
Date: Tue, 4 Sep 2007 13:32:34 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F520344487A@orsmsx418.amr.corp.intel.com>
References: <46DD8AC5.1070508@free.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	<netdev@vger.kernel.org>, <linux-net@vger.kernel.org>
To: "John Sigler" <linux.kernel@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32712 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753474AbXIDUch convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 16:32:37 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46DD8AC5.1070508@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Sigler wrote:
> Jesse Brandeburg wrote:
> 
>> Auke Kok wrote:
>> 
>>> Marc Sigler wrote:
>>> 
>>>> I have several systems with three integrated Intel 82559 (I
>>>> *think*). 
>>>> 
>>>> Does someone know if these boards support hardware interrupt
>>>> mitigation? I.e. is it possible to configure them to raise an IRQ
>>>> only if their hardware buffer is full OR if some given time (say 1
>>>> ms) has passed and packets are available in their hardware buffer.
>>>> 
>>>> I've been using the eepro100 driver up to now, but I'm about to try
>>>> the e100 driver. Would I have to use NAPI? Or is this an orthogonal
>>>> feature?
>>> 
>>> e100 hardware (as far as I can see from the specs) doesn't support
>>> any irq mitigation, so you'll need to run in NAPI mode if you want
>>> to throttle irq's. the in-kernel e100 already runs in NAPI mode, so
>>> that's already covered.
>>> 
>>> beware that the eepro100 driver is scheduled for removal (2.6.25 or
>>> so). 
>> 
>> We support mitigation of interrupts in a downloadable microcode on
>> only a few pieces of hardware (revision id specific) in e100.c (see
>> e100_setup_ucode)
> 
> http://lxr.linux.no/source/drivers/net/e100.c#L1176
> 
> OK.
> 
> How do I tell which revision id I have?
> 
> 00:08.0 0200: 8086:1229 (rev 08)
> 00:09.0 0200: 8086:1229 (rev 08)
> 00:0a.0 0200: 8086:1229 (rev 08)
                           ^^^^^^ 
rev 8

> How much memory is available on the board to bundle packets? 3000
> bytes? 

yes, well, 3kB.  I don't remember if the chip actually bundles
interrupts after the dma complets or pends the dma while delaying the
interrupt (I would guess it is the former)

>> If you really really wanted mitigation you could probably backport
>> the microcode from the e100 driver in the 2.4.35 kernel for your
>> specific hardware.  This driver is versioned 2.X.
> 
> I forgot to mention I'm running 2.6.22.1-rt9.
> I'm not sure why you mention 2.4.35?

because 2.4.35 has the "old" e100 driver from Intel, which has all sorts
of support (and all sorts of complexity) for offloading and interrupt
bundling, etc.

> The problem with e100 is that it fails to properly set up all three
> interfaces, which is why I'm stuck with eepro100.

I remember working with you on this, but we left the issue with no
solution because it appears your hardware has some specific issue with
strange eeprom timings that we cannot reproduce.

you can try loading the ucode (that matches your revision id) using
eepro100.

Jesse
