From: Andi Kleen <ak@suse.de>
Subject: Re: FW: Submission for S2io 10GbE driver
Date: Thu, 5 Feb 2004 02:32:09 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040205023209.4abf2342.ak@suse.de>
References: <20040123232209.2739e6aa.ak@suse.de>
	<004201c3eb5f$ac4e9f00$740efea9@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, raghava.vatsavayi@s2io.com, iod00d@hp.com,
        anton@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Leonid Grossman" <leonid.grossman@s2io.com>
In-Reply-To: <004201c3eb5f$ac4e9f00$740efea9@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 4 Feb 2004 12:44:21 -0800
"Leonid Grossman" <leonid.grossman@s2io.com> wrote:

> 
> 
> > All the ARCH_PPC64 ifdefs shouldn't be needed. Can you remove 
> > that? If there are problems in ppc64 code they should be 
> > fixed there, not worked around. Same with the ifdefs for 
> > kernel 2.6 features. An driver integrated into the kernel 
> > should not contain such ifdefs.
> 
> 
> Hi Andi,
> You are right some of the ifdefs are not needed and we are removing
> these; it is not clear if we can get rid of all of them for the
> following reasons:
> 
> 1) We did't find quad word memory operations(writeq and readq) on PCI
> bus for PPC64 architecture.

That's a bug in ppc64 then. Can you complain to them?

I would go ahead and just use them in the driver unconditionally and wait for 
the ppc64 to fix it. Or just add them there, it's probably simple.

> 2) We did't had a chance to test the driver on other big endian systems
> apart from PPC64. In PPC64 architecture though,
> I write/read a value to/from ioremaped address it swaps the value and
> behaves like a little endian m/c:  
> 
> For ex: if I  do writel(0x12345678, addr) then in it writes 
> addr: 78, (addr+1):56, (addr+2):34, (addr+3):12

Hmm, weird. Don't know, ask the ppc64 people.

> On a little endian m/c like IA32 also writel writes same values in a
> similar manner as shown above. 
> So the question is -
> Do all big endian machines with linux OS swap the values and write in
> little endian format?? 

I hope not.

> 3)In PPC64 architecture dma_addr_t is u32, unlike remaining 64 bit
> architectures where it is defined as u64. Because
> of this we have to deal separately for PP64. 
> So any suggestions will be useful, .i.e. generally how PPC64 developers
> deal with this?

You could just use u64 in your structure definitions for now.

-Andi
