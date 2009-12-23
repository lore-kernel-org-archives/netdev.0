From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [Alacrityvm-devel] [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 16:58:37 -0600
Message-ID: <4B32A09D.30400@codemonkey.ws>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu> <4B3103B4.4070708@gmail.com> <f73f7ab80912222215i39ba865dv95764f95fd57bd96@mail.gmail.com> <4B3232A1.8050505@codemonkey.ws> <20091223195413.GB30700@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kyle Moffett <kyle@moffetthome.net>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>,
	Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	torvalds@linux-foundation.org,
	Andrew Morton <akpm@linux-foundation.org>
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756043AbZLWW64@vger.kernel.org>
In-Reply-To: <20091223195413.GB30700@ovro.caltech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/23/2009 01:54 PM, Ira W. Snyder wrote:
> On Wed, Dec 23, 2009 at 09:09:21AM -0600, Anthony Liguori wrote:

> I didn't know you were interested in this as well. See my later reply to
> Kyle for a lot of code that I've written with this in mind.


BTW, in the future, please CC me or CC 
virtualization@lists.linux-foundation.org.  Or certainly kvm@vger.  I 
never looked at the virtio-over-pci patchset although I've heard it 
referenced before.

>> But both virtio-lguest and virtio-s390 use in-band enumeration and
>> discovery since they do not have support for PCI on either platform.
>>
>
> I'm interested in the same thing, just over PCI. The only PCI agent
> systems I've used are not capable of manipulating the PCI configuration
> space in such a way that virtio-pci is usable on them.

virtio-pci is the wrong place to start if you want to use a PCI *device* 
as the virtio bus. virtio-pci is meant to use the PCI bus as the virtio 
bus.  That's a very important requirement for us because it maintains 
the relationship of each device looking like a normal PCI device.

> This means
> creating your own enumeration mechanism. Which sucks.

I don't think it sucks.  The idea is that we don't want to unnecessarily 
reinvent things.

Of course, the key feature of virtio is that it makes it possible for 
you to create your own enumeration mechanism if you're so inclined.

> See my virtio-phys
> code (http://www.mmarray.org/~iws/virtio-phys/) for an example of how I
> did it. It was modeled on lguest. Help is appreciated.

If it were me, I'd take a much different approach.  I would use a very 
simple device with a single transmit and receive queue.  I'd create a 
standard header, and the implement a command protocol on top of it. 
You'll be able to support zero copy I/O (although you'll have a fixed 
number of outstanding requests).  You would need a single large ring.

But then again, I have no idea what your requirements are.  You could 
probably get far treating the thing as a network device and just doing 
ATAoE or something like that.

Regards,

Anthony Liguori

> Ira
