From: Andi Kleen <ak@muc.de>
Subject: Re: Mystery packet killing tg3
Date: 5 May 2005 20:06:09 +0200
Message-ID: <20050505180609.GB24386@muc.de>
References: <20050502162405.65dfb4a9@localhost.localdomain> <20050502200251.38271b61.davem@davemloft.net> <m14qdiyhcn.fsf@muc.de> <42791825.2080204@pantasys.com> <20050505114327.GA51761@muc.de> <427A5363.2080703@pantasys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 5 May 2005 20:06:09 +0200
To: Peter Buckingham <peter@pantasys.com>
Content-Disposition: inline
In-Reply-To: <427A5363.2080703@pantasys.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2005 at 10:09:55AM -0700, Peter Buckingham wrote:
> Andi Kleen wrote:
> >"32bit e1000"? How did you get such a beast? AFAIK all e1000s are 64bit
> >address capable. Please supply a full boot log without iommu=force 
> >and describe what happens exactly.
> 
> that was my initial impression too :-(
> 
> basically what happens is when there is more that 4GB of RAM in this 
> system packets will start disappearing. ie ping will drop packets. 
> Initially our bios was not configuring the IOMMU correctly, that has 
> changed now.

The kernel should detect incorrect IOMMU setups and work around
it. So even if your BIOS screws it up completely it should
work (at the cost of some lost memory). That  is the theory
at least, but perhaps you discovered some new way to screw
it up that is not handled yet ,-)

> 
> I can make it work without the iommu=force by forcing the DMA to be 
> 32bit in the initialisation, but this seems to be a bit of a hack..

In what initialization exactly? YOu mean changing the pci_set_dma_mask()
in the e1000 driver?

> Checking aperture...
> CPU 0: aperture @ 16e0000000 size 64 MB
> Aperture from northbridge cpu 0 beyond 4GB. Ignoring.
> No AGP bridge found
> Your BIOS doesn't leave a aperture memory hole
> Please enable the IOMMU option in the BIOS setup
> This costs you 64 MB of RAM
> Mapping aperture over 65536 KB of RAM @ 4000000
We try to fix up the IOMMU. Normally it should work now.

> PCI-DMA: Disabling AGP.
> PCI-DMA: aperture base @ 4000000 size 65536 KB
> 
> Kernel panic - not syncing: Cannot allocate iommu bitmap

Hmm, that must be a different problem in the IOMMU code
not related to the e1000. Probably it got confused somehow.
Why did you get the idea the ethernet driver has anything to do with
it?


-Andi
