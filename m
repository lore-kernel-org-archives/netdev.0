From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 13:14:30 -0700
Message-ID: <1115756070.8570.76.camel@rh4>
References: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11>
 <1115743966.8570.26.camel@rh4>
 <20050510.121214.39158393.davem@davemloft.net>
 <20050510.132642.85686818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mperaya@alcazaba.unex.es, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050510.132642.85686818.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-05-10 at 13:26 -0700, David S.Miller wrote:
> From: "David S. Miller" <davem@davemloft.net>
> Subject: Re: tg3 support broken on PPC, a workaround
> Date: Tue, 10 May 2005 12:12:14 -0700 (PDT)
> 
> > Anyways, it is clear this code needs to change. :-)
> 
> I propose something like the patch below.  I unfortunately
> discovered that the PCI-X boundary controls are limited, and
> even worse PCI-E only allows controlling the write side and
> not the read site at all. :-(
> 
> I think this should really be considered to be fixed
> in future chip revisions, as performance will suffer
> unnecessarily without proper boundary controls.  Even
> just a single bit in the DMA RW control register which
> says "do not cross PCI_CACHELINE_SIZE boundary" would
> work just fine as that is essentially what the code below
> is trying to convince the Tigon3 chip to do. :)
> 
> I am running this patch now on my sparc64 SunBlade1500
> workstation's onboard 5703.
> 
> Comments?

DMA boundary control bits are only valid on 5700 and 5701. On all other
PCI/PCIX chips, these bits are no longer defined.

On PCI Express systems, the cache line size register is not used and is
set to zero on most systems.

> 
> [TG3]: Do not burst across cache line boundary on non-X86
> 
> PCI controllers on these systems will disconnect the tg3
> when it crosses a cache line boundary anyways, wasting
> precious PCI bandwidth.

I don't think target-initiated disconnects will waste PCI bandwidth
compared to master-initiated terminations. In both cases, you see the
same DMA bursts across the bus, only the termination of each burst is
different.
