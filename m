From: Avi Kivity <avi@redhat.com>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
 model for vbus_driver objects
Date: Wed, 19 Aug 2009 08:26:37 +0300
Message-ID: <4A8B8D0D.2020703@redhat.com>
References: <20090818084606.GA13878@redhat.com> <20090818155329.GD31060@ovro.caltech.edu> <4A8ADC09.3030205@redhat.com> <20090818172752.GC17631@ovro.caltech.edu> <4A8AE918.5000109@redhat.com> <20090818182735.GD17631@ovro.caltech.edu> <4A8AF880.6080704@redhat.com> <20090818205919.GA1168@ovro.caltech.edu> <4A8B1C7F.4060008@redhat.com> <4A8B25F5.7050806@redhat.com> <20090819004445.GB11168@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34822 "EHLO mx2.redhat.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750932AbZHSF0d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2009 01:26:33 -0400
In-Reply-To: <20090819004445.GB11168@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2009 03:44 AM, Ira W. Snyder wrote:
>> You don't need in fact a third mode.  You can mmap the x86 address space
>> into your ppc userspace and use the second mode.  All you need then is
>> the dma engine glue and byte swapping.
>>
>>      
> Hmm, I'll have to think about that.
>
> The ppc is a 32-bit processor, so it has 4GB of address space for
> everything, including PCI, SDRAM, flash memory, and all other
> peripherals.
>
> This is exactly like 32bit x86, where you cannot have a PCI card that
> exposes a 4GB PCI BAR. The system would have no address space left for
> its own SDRAM.
>    

(you actually can, since x86 has a 36-40 bit physical address space even 
with a 32-bit virtual address space, but that doesn't help you).

> On my x86 computers, I only have 1GB of physical RAM, and so the ppc's
> have plenty of room in their address spaces to map the entire x86 RAM
> into their own address space. That is exactly what I do now. Accesses to
> ppc physical address 0x80000000 "magically" hit x86 physical address
> 0x0.
>    

So if you mmap() that, you could work with virtual addresses.  It may be 
more efficient to work with physical addresses directly though.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

