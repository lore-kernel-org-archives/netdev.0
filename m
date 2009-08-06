From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Thu, 06 Aug 2009 06:08:27 -0600
Message-ID: <4A7A8F7B0200005A00051B84@sinclair.provo.novell.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
 <20090806081955.GA9752@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <alacrityvm-devel@lists.sourceforge.net>, <kvm@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090806081955.GA9752@redhat.com>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael,

>>> On 8/6/2009 at  4:19 AM, in message <20090806081955.GA9752@redhat.com>,
"Michael S. Tsirkin" <mst@redhat.com> wrote: 
> On Mon, Aug 03, 2009 at 01:17:30PM -0400, Gregory Haskins wrote:
>> (Applies to v2.6.31-rc5, proposed for linux-next after review is complete)
> 
> These are guest drivers, right?

Yep.

> Merging the guest first means relying on
> kernel interface from an out of tree driver, which well might change
> before it goes in.

ABI compatibility is already addressed/handled, so even if that is true its not a problem.

> Would it make more sense to start merging with the host side of the project?

Not necessarily, no.  These are drivers for a "device", so its no different than merging any other driver really.  This is especially true since the hypervisor is also already published and freely available today, so anyone can start using it.

> 
>> This series implements the guest-side drivers for accelerated IO
>> when running on top of the AlacrityVM hypervisor, the details of
>> which you can find here:
>> 
>> http://developer.novell.com/wiki/index.php/AlacrityVM
> 
> Since AlacrityVM is kvm based, Cc kvm@vger.kernel.org.

I *can* do that, but there is nothing in these drivers that is KVM specific (its all pure PCI and VBUS).  I've already made the general announcement about the project/ml cross posted to KVM for anyone that might be interested, but I figure I will spare the general KVM list the details unless something specifically pertains to, or affects, KVM.  For instance, when I get to pushing the hypervisor side, I still need to work on getting that 'xinterface' patch to you guys.  I would certainly be CC'ing kvm@vger when that happens since it modifies the KVM code.

So instead, I would just encourage anyone interested (such as yourself) to join the alacrity list so I don't bother the KVM community unless absolutely necessary.

> 
>> This series includes the basic plumbing, as well as the driver for
>> accelerated 802.x (ethernet) networking.
> 
> The graphs comparing virtio with vbus look interesting.
> However, they do not compare apples to apples, do they?

Yes, I believe they do.  They represent the best that KVM has to offer (to my knowledge) vs the best that alacrityvm has to offer.

> These compare userspace virtio with kernel vbus,

vbus is a device model (akin to QEMU's device model).  Technically, it was a comparison of userspace virtio-net (via QEMU), to kernel venet (via vbus),
which I again stress is the state of the art for both to my knowledge.

As I have explained before in earlier threads on kvm@vger, virtio is not mutually exclusive here.  You can run the virtio protocol over the vbus model if someone were so inclined.  In fact, I proposed this very idea to you a month or two ago but I believe you decided to go your own way and reinvent some other in-kernel model instead for your own reasons.

>where for apples to apples comparison one would need to compare
> kernel virtio with kernel vbus. Right?

Again, it already *is* apples to apples as far as I am concerned.  

At the time I ran those numbers, there was certainly no in-kernel virtio model to play with.  And to my knowledge, there isn't one now (I was never CC'd on the patches, and a cursory search of the KVM list isn't revealing one that was posted recently).

To reiterate: kernel virtio-net (using ??) to kernel venet (vbus based) to kernel virtio-net (vbus, but doesnt exist yet) would be a fun bakeoff.  If you have something for the kernel virtio-net, point me at it and I will try to include it in the comparison next time.

Kind Regards,
-Greg
