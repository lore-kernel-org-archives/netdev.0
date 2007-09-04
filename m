From: John Sigler <linux.kernel@free.fr>
Subject: Re: 82557/8/9 Ethernet Pro 100 interrupt mitigation support
Date: Tue, 04 Sep 2007 18:41:41 +0200
Message-ID: <46DD8AC5.1070508@free.fr>
References: <36D9DB17C6DE9E40B059440DB8D95F520344439B@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F520344439B@orsmsx418.amr.corp.intel.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:

> Auke Kok wrote:
> 
>> Marc Sigler wrote:
>> 
>>> I have several systems with three integrated Intel 82559 (I *think*).
>>> 
>>> Does someone know if these boards support hardware interrupt
>>> mitigation? I.e. is it possible to configure them to raise an IRQ
>>> only if their hardware buffer is full OR if some given time (say 1
>>> ms) has passed and packets are available in their hardware buffer.
>>> 
>>> I've been using the eepro100 driver up to now, but I'm about to try
>>> the e100 driver. Would I have to use NAPI? Or is this an orthogonal
>>> feature? 
>> 
>> e100 hardware (as far as I can see from the specs) doesn't support
>> any irq mitigation, so you'll need to run in NAPI mode if you want to
>> throttle irq's. the in-kernel e100 already runs in NAPI mode, so
>> that's already covered. 
>> 
>> beware that the eepro100 driver is scheduled for removal (2.6.25 or so).
> 
> We support mitigation of interrupts in a downloadable microcode on only
> a few pieces of hardware (revision id specific) in e100.c (see
> e100_setup_ucode)

http://lxr.linux.no/source/drivers/net/e100.c#L1176

OK.

How do I tell which revision id I have?

00:08.0 0200: 8086:1229 (rev 08)
00:09.0 0200: 8086:1229 (rev 08)
00:0a.0 0200: 8086:1229 (rev 08)

How much memory is available on the board to bundle packets? 3000 bytes?

> If you really really wanted mitigation you could probably backport the
> microcode from the e100 driver in the 2.4.35 kernel for your specific
> hardware.  This driver is versioned 2.X.

I forgot to mention I'm running 2.6.22.1-rt9.
I'm not sure why you mention 2.4.35?
The problem with e100 is that it fails to properly set up all three 
interfaces, which is why I'm stuck with eepro100.

Regards.
