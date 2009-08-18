From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver objects
Date: Tue, 18 Aug 2009 20:20:10 +0200
Message-ID: <200908182020.11126.arnd@arndb.de>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	kvm@vger.kernel.org, alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8ABEC9.6090006@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 18 August 2009, Gregory Haskins wrote:
> Avi Kivity wrote:
> > On 08/17/2009 10:33 PM, Gregory Haskins wrote:
> > 
> > One point of contention is that this is all managementy stuff and should
> > be kept out of the host kernel.  Exposing shared memory, interrupts, and
> > guest hypercalls can all be easily done from userspace (as virtio
> > demonstrates).  True, some devices need kernel acceleration, but that's
> > no reason to put everything into the host kernel.
> 
> See my last reply to Anthony.  My two points here are that:
> 
> a) having it in-kernel makes it a complete subsystem, which perhaps has
> diminished value in kvm, but adds value in most other places that we are
> looking to use vbus.
> 
> b) the in-kernel code is being overstated as "complex".  We are not
> talking about your typical virt thing, like an emulated ICH/PCI chipset.
>  Its really a simple list of devices with a handful of attributes.  They
> are managed using established linux interfaces, like sysfs/configfs.

IMHO the complexity of the code is not so much of a problem. What I
see as a problem is the complexity a kernel/user space interface that
manages a the devices with global state.

One of the greatest features of Michaels vhost driver is that all
the state is associated with open file descriptors that either exist
already or belong to the vhost_net misc device. When a process dies,
all the file descriptors get closed and the whole state is cleaned
up implicitly.

AFAICT, you can't do that with the vbus host model.

> > What performance oriented items have been left unaddressed?
> 
> Well, the interrupt model to name one.

The performance aspects of your interrupt model are independent
of the vbus proxy, or at least they should be. Let's assume for
now that your event notification mechanism gives significant
performance improvements (which we can't measure independently
right now). I don't see a reason why we could not get the
same performance out of a paravirtual interrupt controller
that uses the same method, and it would be straightforward
to implement one and use that together with all the existing
emulated PCI devices and virtio devices including vhost_net.

	Arnd <><
