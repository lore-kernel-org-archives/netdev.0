From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [Alacrityvm-devel] [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Thu, 24 Dec 2009 10:57:09 -0600
Message-ID: <4B339D65.9060607@codemonkey.ws>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> 	<4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu> 	<4B3103B4.4070708@gmail.com> <f73f7ab80912222215i39ba865dv95764f95fd57bd96@mail.gmail.com> 	<4B3232A1.8050505@codemonkey.ws> <20091223195413.GB30700@ovro.caltech.edu> 	<4B32A09D.30400@codemonkey.ws> <f73f7ab80912232052u5248c652h8e6d0637897cd5af@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>,
	Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	torvalds@linux-foundation.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <gregkh@suse.de>
To: Kyle Moffett <kyle@moffetthome.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <f73f7ab80912232052u5248c652h8e6d0637897cd5af@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/23/2009 10:52 PM, Kyle Moffett wrote:
> On Wed, Dec 23, 2009 at 17:58, Anthony Liguori<anthony@codemonkey.ws>  wrote:
>> Of course, the key feature of virtio is that it makes it possible for you to
>> create your own enumeration mechanism if you're so inclined.
>
> See... the thing is... a lot of us random embedded board developers
> don't *want* to create our own enumeration mechanisms.  I see a huge
> amount of value in vbus as a common zero-copy DMA-capable
> virtual-device interface, especially over miscellaneous non-PCI-bus
> interconnects.  I mentioned my PCI-E boards earlier, but I would also
> personally be interested in using infiniband with RDMA as a virtual
> device bus.

I understand what you're saying, but is there really a practical 
argument here?  Infiniband already supports things like IPoIB and SCSI 
over IB.  Is it necessary to add another layer on top of it?

That said, it's easy enough to create a common enumeration mechanism for 
people to use with virtio.  I doubt it's really that interesting but 
it's certainly quite reasonable.  In fact, a lot of code could be reused 
from virtio-s390 or virtio-lguest.


> Basically, what it comes down to is vbus is practically useful as a
> generic way to provide a large number of hotpluggable virtual devices
> across an arbitrary interconnect.  I agree that virtio works fine if
> you have some out-of-band enumeration and hotplug transport (like
> emulated PCI), but if you *don't* have that, it's pretty much faster
> to write your own set of paired network drivers than it is to write a
> whole enumeration and transport stack for virtio.
>
> On top of *that*, with the virtio approach I would need to write a
> whole bunch of tools to manage the set of virtual devices on my custom
> hardware.  With vbus that management interface would be entirely
> common code across a potentially large number of virtualized physical
> transports.


This particular use case really has nothing to do with virtualization. 
You really want an infiniband replacement using the PCI-e bus.  There's 
so much on the horizon in this space that's being standardized in 
PCI-sig like MR-IOV.

>> If it were me, I'd take a much different approach.  I would use a very
>> simple device with a single transmit and receive queue.  I'd create a
>> standard header, and the implement a command protocol on top of it. You'll
>> be able to support zero copy I/O (although you'll have a fixed number of
>> outstanding requests).  You would need a single large ring.
>
> That's basically about as much work as writing entirely new network
> and serial drivers over PCI.  Not only that, but I   The beauty of
> vbus for me is that I could write a fairly simple logical-to-physical
> glue driver which lets vbus talk over my PCI-E or infiniband link and
> then I'm basically done.

Is this something you expect people to use or is this a one-off project?

> I personally would love to see vbus merged, into staging at the very
> least.  I would definitely spend some time trying to make it work
> across PCI-E on my *very* *real* embedded boards.  Look at vbus not as
> another virtualization ABI, but as a multiprotocol high-level device
> abstraction API that already has one well-implemented and
> high-performance user.

If someone wants to advocate vbus for non-virtualized purposes, I have 
no problem with that.

I just don't think it makes sense in for KVM.  virtio is not intended to 
be used for any possible purpose.

Regards,

Anthony Liguori
