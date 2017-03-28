From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 5/5] PCI: remove pci_enable_msix
Date: Tue, 28 Mar 2017 09:07:28 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFBE7F3@AcuExch.aculab.com>
References: <20170327082936.6830-1-hch@lst.de>
 <20170327082936.6830-6-hch@lst.de>
 <83f97789-0817-7549-bfa9-1f8dcb0c26d9@gmail.com>
 <20170327171148.GB28815@lst.de>
 <1eaa46ad-9890-c738-3a85-6468161284ba@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netanel@annapurnalabs.com" <netanel@annapurnalabs.com>,
        "jcliburn@gmail.com" <jcliburn@gmail.com>,
        "chris.snook@gmail.com" <chris.snook@gmail.com>,
        "sgoutham@cavium.com" <sgoutham@cavium.com>,
        "rric@kernel.org" <rric@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: 'David Daney' <ddaney.cavm@gmail.com>,
        Christoph Hellwig <hch@lst.de>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1eaa46ad-9890-c738-3a85-6468161284ba@gmail.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney
> Sent: 27 March 2017 18:31
> On 03/27/2017 10:11 AM, Christoph Hellwig wrote:
> > On Mon, Mar 27, 2017 at 09:59:35AM -0700, David Daney wrote:
> >> On 03/27/2017 01:29 AM, Christoph Hellwig wrote:
> >>> Unused now that all callers switched to pci_alloc_irq_vectors.
> >>>
> >>
> >> And you are aware that the ThunderX GPIO driver that I am attempting to
> >> merge uses this interface.
> >>
> >> If this patch gets merged, should I ask to revert it when the GPIO driver
> >> goes in?
> >
> > No.  You should not use pci_enable_msix in your new driver as I told
> > you before.
> >
> >> You offer no solution for drivers that would benefit from using a sparse
> >> sub set of the available MSI-X vectors.
> >
> > Use pci_enable_msix_{exact,range} for now, as I told you before.
> >
> 
> That still results in twice as many MSI-X being provisioned than are needed.
> 
> For drivers that use a contiguous range of MSI-X, your suggestion is
> usable, but for others you are forcing resources to be wasted.  For what
> end?

There are also drivers that only need some interrupts after a specific
device is opened, and could free them when closed.

This could even be network devices with lots of queues, or a driver
realising that the workload is high and per-cpu interrupts make sense.

So any real change to the interface should allow drivers to allocate
and free individual MSI-X vectors.

I remember a lot of discussions when pci_enable_msix_range() was added,
but almost nothing about this change.

	David
