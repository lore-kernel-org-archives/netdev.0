From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH 1/5] r8169: auto detect 32-bit slot
Date: 10 Mar 2005 00:20:24 +0100
Message-ID: <20050309232024.GC63395@muc.de>
References: <20050309112925.7f7900ab@dxpl.pdx.osdl.net> <m17jkgwp6i.fsf@muc.de> <20050309214023.GA9502@electric-eye.fr.zoreil.com> <20050309135530.5c5c80b6@dxpl.pdx.osdl.net> <20050309230809.GC9502@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Date: Thu, 10 Mar 2005 00:20:24 +0100
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20050309230809.GC9502@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2005 at 12:08:09AM +0100, Francois Romieu wrote:
> Stephen Hemminger <shemminger@osdl.org> :
> [...]
> > I tested on old Celeron with Netgear card.  I could try Amd and/or Xeon
> > if you want.
> 
> If the systems are 64 bit, one would need to know how the driver behaves
> when DAC is forced and:

The concept of "64bit systems" is useless here anyways. Even on a 32bit
system with highmem like i386 you can get >32bit addresses to deal
with. One usecase for that would be sendfile() out of user space.
This is widely used these days.

> 1) the Netgear card is in a 32 bit slot, dma to highmem is enabled and used
> 2) the Netgear card is in a 32 bit slot, dma to highmem is enabled and unused
> 3) the Netgear card is in a 32 bit slot, dma to highmem is disabled
> 4) the Netgear card is in a 64 bit slot, dma to highmem is enabled and used
> 5) the Netgear card is in a 64 bit slot, dma to highmem is enabled and unused
> 6) the Netgear card is in a 64 bit slot, dma to highmem is disabled

Again are you sure it depends on 64bit slots? Normally 64bit slots
only offer more bandwidth, but the address protocol is the same
as 32bit and both support DAC in the same way.

> 
> + the content of the Config2 register for 1-6.
> 
> If the amd64 hosts a built-in 8169, add the behavior with highmem disabled or
> enabled + variable amount of memory.

You really should forget about amd64 or not, all that counts is
sizeof(dma_addr_t) 

-Andi
