From: Anton Blanchard <anton@samba.org>
Subject: Re: FW: Submission for S2io 10GbE driver
Date: Thu, 5 Feb 2004 12:51:49 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040205015149.GN19011@krispykreme>
References: <20040123232209.2739e6aa.ak@suse.de> <004201c3eb5f$ac4e9f00$740efea9@S2IOtech.com> <20040205023209.4abf2342.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Leonid Grossman <leonid.grossman@s2io.com>, netdev@oss.sgi.com,
        raghava.vatsavayi@s2io.com, iod00d@hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040205023209.4abf2342.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> > 1) We did't find quad word memory operations(writeq and readq) on PCI
> > bus for PPC64 architecture.
> 
> That's a bug in ppc64 then. Can you complain to them?  I would go
> ahead and just use them in the driver unconditionally and wait for the
> ppc64 to fix it. Or just add them there, it's probably simple.

Yep ppc64 should define them. If you are submitting a driver for
inclusion in 2.6 leave these bits out, its my fault they arent defined
and I'll get them added in.

Turns out lots of architectures are missing these, I'll fire an email
off to linux-arch about it.

> > On a little endian m/c like IA32 also writel writes same values in a
> > similar manner as shown above. 
> > So the question is -
> > Do all big endian machines with linux OS swap the values and write in
> > little endian format?? 
> 
> I hope not.

Thats how all big endian platforms work. in* and out*, read* and write*
byteswap. 

> > 3)In PPC64 architecture dma_addr_t is u32, unlike remaining 64 bit
> > architectures where it is defined as u64. Because
> > of this we have to deal separately for PP64. 
> > So any suggestions will be useful, .i.e. generally how PPC64 developers
> > deal with this?
> 
> You could just use u64 in your structure definitions for now.

Its up to the architecture as to what a dma_addr_t looks like. On our
current machines we only support operating through the IOMMU, so all
PCI bus address are in fact 32bit. Most drivers dont care how big a
dma_addr_t is, is there something you are doing that does?

Anton
