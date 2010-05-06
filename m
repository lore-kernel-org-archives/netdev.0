From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Thu, 6 May 2010 16:17:09 -0400
Message-ID: <20100506201709.GA17922@infradead.org>
References: <20100504230225.GP8323@vmware.com> <201005051029.42052.dtor@vmware.com> <20100505173120.GA1752@infradead.org> <201005051035.29831.dtor@vmware.com> <20100505173951.GA8388@infradead.org> <F1354E79A137A24CBA60059AA65CB1B802A235C535@EXCH-MBX-2.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Dmitry Torokhov <dtor@vmware.com>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Pankaj Thakkar <pthakkar@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F1354E79A137A24CBA60059AA65CB1B802A235C535@EXCH-MBX-2.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 05, 2010 at 10:47:10AM -0700, Pankaj Thakkar wrote:
> > Forget about the licensing.  Loading binary blobs written to a shim
> > layer is a complete pain in the ass and totally unsupportable, and
> > also uninteresting because of the overhead.
> 
> [PT] Why do you think it is unsupportable? How different is it from any module written against a well maintained interface? What overhead are you talking about?

We only support in-kernel drivers, everything else is subject to changes
in the kernel API and ABI.  What you do is basically introducing another
wrapper layer not allowing full access to the normal Linux API.  People
have tried this before and we're not willing to add it.  Do a little
research on Project UDI if you're curious.

> >  (1) move the limited VF drivers directly into the kernel tree,
> >      talk to them through a normal ops vector
> [PT] This assumes that all the VF drivers would always be available.

Yes, absolutely.  Just as we assume that for every other driver.

> Also we have to support windows and our current design supports it nicely in an OS agnostic manner.

And that's not something we care about at all.  The Linux kernel has
traditionally a very hostile position against cross platform drivers for
reasons well explained before at many occasions.

> >  (2) get rid of the whole shim crap and instead integrate the limited
> >      VF driver with the full VF driver we already have, instead of
> >      duplicating the code
> [PT] Having a full VF driver adds a lot of dependency on the guest VM and this is what NPA tries to avoid.

Yes, of course it does.  It's a normal driver at the point which it
should have been from day one.

> >  (3) don't make the PV to VF integration VMware-specific but also
> >      provide an open reference implementation like virtio.  We're not
> >      going to add massive amount of infrastructure that is not actually
> >      useable in a free software stack.
> [PT] Today this is tied to vmxnet3 device and is intended to work on ESX hypervisor only (vmxnet3 works on VMware hypervisor only). All the loading support is inside the ESX hypervisor. I am going to post the interface between the shell and the plugin soon and you can see that there is not a whole lot of dependency or infrastructure requirements from the Linux kernel. Please keep in mind that we don't use Linux as a hypervisor but as a guest VM.

But we use Linux as the hypervisor, too.  So if you want to target a
major infrastructure you might better make it available for that case.
