From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 5 May 2010 13:39:51 -0400
Message-ID: <20100505173951.GA8388@infradead.org>
References: <20100504230225.GP8323@vmware.com> <201005051029.42052.dtor@vmware.com> <20100505173120.GA1752@infradead.org> <201005051035.29831.dtor@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Pankaj Thakkar <pthakkar@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Dmitry Torokhov <dtor@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201005051035.29831.dtor@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 05, 2010 at 10:35:28AM -0700, Dmitry Torokhov wrote:
> Yes, with the exception that the only body of code that will be
> accepted by the shell should be GPL-licensed and thus open and available
> for examining. This is not different from having a standard kernel
> module that is loaded normally and plugs into a certain subsystem.
> The difference is that the binary resides not on guest filesystem
> but elsewhere.

Forget about the licensing.  Loading binary blobs written to a shim
layer is a complete pain in the ass and totally unsupportable, and
also uninteresting because of the overhead.

If you have any interesting in developing this further, do:

 (1) move the limited VF drivers directly into the kernel tree,
     talk to them through a normal ops vector
 (2) get rid of the whole shim crap and instead integrate the limited
     VF driver with the full VF driver we already have, instead of
     duplicating the code
 (3) don't make the PV to VF integration VMware-specific but also
     provide an open reference implementation like virtio.  We're not
     going to add massive amount of infrastructure that is not actually
     useable in a free software stack.
