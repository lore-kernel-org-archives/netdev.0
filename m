From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Thu, 6 Aug 2009 15:24:49 +0300
Message-ID: <20090806122449.GC11038@redhat.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <20090806081955.GA9752@redhat.com> <4A7A8F7B0200005A00051B84@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alacrityvm-devel@lists.sourceforge.net, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755354AbZHFM0A@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A7A8F7B0200005A00051B84@sinclair.provo.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 06, 2009 at 06:08:27AM -0600, Gregory Haskins wrote:
> Hi Michael,
> 
> >>> On 8/6/2009 at  4:19 AM, in message <20090806081955.GA9752@redhat.com>,
> "Michael S. Tsirkin" <mst@redhat.com> wrote: 
> > On Mon, Aug 03, 2009 at 01:17:30PM -0400, Gregory Haskins wrote:
> >> (Applies to v2.6.31-rc5, proposed for linux-next after review is complete)
> > 
> > These are guest drivers, right?
> 
> Yep.
> 
> > Merging the guest first means relying on
> > kernel interface from an out of tree driver, which well might change
> > before it goes in.
> 
> ABI compatibility is already addressed/handled, so even if that is true its not a problem.

It is? With versioning? Presumably this:

+       params.devid   = vdev->id;
+       params.version = version;
+
+       ret = vbus_pci_hypercall(VBUS_PCI_HC_DEVOPEN,
+                                &params, sizeof(params));
+       if (ret < 0)
+               return ret;

Even assuming host even knows how to decode this structure (e.g.  some
other host module doesn't use VBUS_PCI_HC_DEVOPEN), checks the version
and denies older guests, this might help guest not to crash, but guest
still won't work.

> > Would it make more sense to start merging with the host side of the project?
> 
> Not necessarily, no.  These are drivers for a "device", so its no
> different than merging any other driver really.  This is especially
> true since the hypervisor is also already published and freely
> available today, so anyone can start using it.

The difference is clear to me: devices do not get to set kernel/userspace
interfaces. This "device" depends on a specific interface between
kernel and (guest) userspace.

-- 
MST
