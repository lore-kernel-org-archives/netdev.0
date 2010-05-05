From: Pankaj Thakkar <pthakkar@vmware.com>
Subject: RE: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 5 May 2010 10:47:10 -0700
Message-ID: <F1354E79A137A24CBA60059AA65CB1B802A235C535@EXCH-MBX-2.vmware.com>
References: <20100504230225.GP8323@vmware.com>
 <201005051029.42052.dtor@vmware.com> <20100505173120.GA1752@infradead.org>
 <201005051035.29831.dtor@vmware.com> <20100505173951.GA8388@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Christoph Hellwig <hch@infradead.org>,
	Dmitry Torokhov <dtor@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:43834 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751670Ab0EERrL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 13:47:11 -0400
In-Reply-To: <20100505173951.GA8388@infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Christoph Hellwig [mailto:hch@infradead.org]
> Sent: Wednesday, May 05, 2010 10:40 AM
> To: Dmitry Torokhov
> Cc: Christoph Hellwig; pv-drivers@vmware.com; Pankaj Thakkar;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> virtualization@lists.linux-foundation.org
> Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for
> vmxnet3
> 
> On Wed, May 05, 2010 at 10:35:28AM -0700, Dmitry Torokhov wrote:
> > Yes, with the exception that the only body of code that will be
> > accepted by the shell should be GPL-licensed and thus open and
> available
> > for examining. This is not different from having a standard kernel
> > module that is loaded normally and plugs into a certain subsystem.
> > The difference is that the binary resides not on guest filesystem
> > but elsewhere.
> 
> Forget about the licensing.  Loading binary blobs written to a shim
> layer is a complete pain in the ass and totally unsupportable, and
> also uninteresting because of the overhead.

[PT] Why do you think it is unsupportable? How different is it from any module written against a well maintained interface? What overhead are you talking about?

> 
> If you have any interesting in developing this further, do:
> 
>  (1) move the limited VF drivers directly into the kernel tree,
>      talk to them through a normal ops vector
[PT] This assumes that all the VF drivers would always be available. Also we have to support windows and our current design supports it nicely in an OS agnostic manner.

>  (2) get rid of the whole shim crap and instead integrate the limited
>      VF driver with the full VF driver we already have, instead of
>      duplicating the code
[PT] Having a full VF driver adds a lot of dependency on the guest VM and this is what NPA tries to avoid.

>  (3) don't make the PV to VF integration VMware-specific but also
>      provide an open reference implementation like virtio.  We're not
>      going to add massive amount of infrastructure that is not actually
>      useable in a free software stack.
[PT] Today this is tied to vmxnet3 device and is intended to work on ESX hypervisor only (vmxnet3 works on VMware hypervisor only). All the loading support is inside the ESX hypervisor. I am going to post the interface between the shell and the plugin soon and you can see that there is not a whole lot of dependency or infrastructure requirements from the Linux kernel. Please keep in mind that we don't use Linux as a hypervisor but as a guest VM.

