From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Tue, 18 Aug 2009 12:53:13 +0300
Message-ID: <20090818095313.GC13878@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Gregory Haskins <ghaskins@novell.com>,
	kvm@vger.kernel.org, Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758074AbZHRJy5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A89B08A.4010103@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 17, 2009 at 03:33:30PM -0400, Gregory Haskins wrote:
> There is a secondary question of venet (a vbus native device) verses
> virtio-net (a virtio native device that works with PCI or VBUS).  If
> this contention is really around venet vs virtio-net, I may possibly
> conceed and retract its submission to mainline.

For me yes, venet+ioq competing with virtio+virtqueue.

> I've been pushing it to date because people are using it and I don't
> see any reason that the driver couldn't be upstream.

If virtio is just as fast, they can just use it without knowing it.
Clearly, that's better since we support virtio anyway ...

> -- Issues --
> 
> Out of all this, I think the biggest contention point is the design of
> the vbus-connector that I use in AlacrityVM (Avi, correct me if I am
> wrong and you object to other aspects as well).  I suspect that if I had
> designed the vbus-connector to surface vbus devices as PCI devices via
> QEMU, the patches would potentially have been pulled in a while ago.
> 
> There are, of course, reasons why vbus does *not* render as PCI, so this
> is the meat of of your question, I believe.
> 
> At a high level, PCI was designed for software-to-hardware interaction,
> so it makes assumptions about that relationship that do not necessarily
> apply to virtualization.

I'm not hung up on PCI, myself.  An idea that might help you get Avi
on-board: do setup in userspace, over PCI.  Negotiate hypercall support
(e.g.  with a PCI capability) and then switch to that for fastpath. Hmm?

> As another example, the connector design coalesces *all* shm-signals
> into a single interrupt (by prio) that uses the same context-switch
> mitigation techniques that help boost things like networking.  This
> effectively means we can detect and optimize out ack/eoi cycles from the
> APIC as the IO load increases (which is when you need it most).  PCI has
> no such concept.

Could you elaborate on this one for me? How does context-switch
mitigation work?

> In addition, the signals and interrupts are priority aware, which is
> useful for things like 802.1p networking where you may establish 8-tx
> and 8-rx queues for your virtio-net device.  x86 APIC really has no
> usable equivalent, so PCI is stuck here.

By the way, multiqueue support in virtio would be very nice to have,
and seems mostly unrelated to vbus.


-- 
MST
