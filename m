From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
	model for vbus_driver objects
Date: Wed, 19 Aug 2009 09:29:02 -0700
Message-ID: <20090819162902.GB22294@ovro.caltech.edu>
References: <20090818172752.GC17631@ovro.caltech.edu> <4A8AE918.5000109@redhat.com> <20090818182735.GD17631@ovro.caltech.edu> <4A8AF880.6080704@redhat.com> <20090818205919.GA1168@ovro.caltech.edu> <4A8B1C7F.4060008@redhat.com> <20090819003812.GA11168@ovro.caltech.edu> <4A8B9051.3020505@redhat.com> <20090819152811.GA22294@ovro.caltech.edu> <4A8C1C22.3010101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:36475 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532AbZHSQ3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 12:29:03 -0400
Content-Disposition: inline
In-Reply-To: <4A8C1C22.3010101@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2009 at 06:37:06PM +0300, Avi Kivity wrote:
> On 08/19/2009 06:28 PM, Ira W. Snyder wrote:
>>
>>> Well, if you can't do that, you can't use virtio-pci on the host.
>>> You'll need another virtio transport (equivalent to "fake pci" you
>>> mentioned above).
>>>
>>>      
>> Ok.
>>
>> Is there something similar that I can study as an example? Should I look
>> at virtio-pci?
>>
>>    
>
> There's virtio-lguest, virtio-s390, and virtio-vbus.
>
>>> I think you tried to take two virtio-nets and make them talk together?
>>> That won't work.  You need the code from qemu to talk to virtio-net
>>> config space, and vhost-net to pump the rings.
>>>
>>>      
>> It *is* possible to make two unmodified virtio-net's talk together. I've
>> done it, and it is exactly what the virtio-over-PCI patch does. Study it
>> and you'll see how I connected the rx/tx queues together.
>>    
>
> Right, crossing the cables works, but feature negotiation is screwed up,  
> and both sides think the data is in their RAM.
>
> vhost-net doesn't do negotiation and doesn't assume the data lives in  
> its address space.
>

Yes, that is exactly what I did: crossed the cables (in software).

I'll take a closer look at vhost-net now, and make sure I understand how
it works.

>>> Please find a name other than virtio-over-PCI since it conflicts with
>>> virtio-pci.  You're tunnelling virtio config cycles (which are usually
>>> done on pci config cycles) on a new protocol which is itself tunnelled
>>> over PCI shared memory.
>>>
>>>      
>> Sorry about that. Do you have suggestions for a better name?
>>
>>    
>
> virtio-$yourhardware or maybe virtio-dma
>

How about virtio-phys?

Arnd and BenH are both looking at PPC systems (similar to mine). Grant
Likely is looking at talking to an processor core running on an FPGA,
IIRC. Most of the code can be shared, very little should need to be
board-specific, I hope.

>> I called it virtio-over-PCI in my previous postings to LKML, so until a
>> new patch is written and posted, I'll keep referring to it by the name
>> used in the past, so people can search for it.
>>
>> When I post virtio patches, should I CC another mailing list in addition
>> to LKML?
>>    
>
> virtualization@lists.linux-foundation.org is virtio's home.
>
>> That said, I'm not sure how qemu-system-ppc running on x86 could
>> possibly communicate using virtio-net. This would mean the guest is an
>> emulated big-endian PPC, while the host is a little-endian x86. I
>> haven't actually tested this situation, so perhaps I am wrong.
>>    
>
> I'm confused now.  You don't actually have any guest, do you, so why  
> would you run qemu at all?
>

I do not run qemu. I am just stating a problem with virtio-net that I
noticed. This is just so someone more knowledgeable can be aware of the
problem.

>>> The x86 side only needs to run virtio-net, which is present in RHEL 5.3.
>>> You'd only need to run virtio-tunnel or however it's called.  All the
>>> eventfd magic takes place on the PCI agents.
>>>
>>>      
>> I can upgrade the kernel to anything I want on both the x86 and ppc's.
>> I'd like to avoid changing the x86 (RHEL5) userspace, though. On the
>> ppc's, I have full control over the userspace environment.
>>    
>
> You don't need any userspace on virtio-net's side.
>
> Your ppc boards emulate a virtio-net device, so all you need is the  
> virtio-net module (and virtio bindings).  If you chose to emulate, say,  
> an e1000 card all you'd need is the e1000 driver.
>

Thanks for the replies.
Ira
