From: Andi Kleen <ak@muc.de>
Subject: Re: Intel and TOE in the news
Date: 21 Feb 2005 12:37:56 +0100
Message-ID: <20050221113756.GA87576@muc.de>
References: <20050220230713.GA62354@muc.de> <200502210158.j1L1wcDD004318@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Leonid Grossman'" <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com
Date: Mon, 21 Feb 2005 12:37:56 +0100
To: Alex Aizman <alex@neterion.com>
Content-Disposition: inline
In-Reply-To: <200502210158.j1L1wcDD004318@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Feb 20, 2005 at 05:57:56PM -0800, Alex Aizman wrote:
> 
> That's what we do, simply because interrupts are coalesced. 
> 
> > The function doesn't do the full packet 
> > processing,  but just stuffs the packet into a CPU queue that 
> > is processed at a lower priority interrupt (softirq). 
> 
> There's the netif_rx's own per-packet overhead (including the call itself)
> that arguably could be optimized..

netif_rx should be pretty cheap. It could be probably optimized more
(e.g. no local_irq_save if you know you're comming from
a interrupt or somehow avoiding the atomic reference count
increase on the device), but I suspect there are other
areas that could be improved first.

> > Most interesting would be to use per CPU TX completion 
> > interrupts using MSI-X and avoid bouncing packets around between CPUs.
> 
> Our experimental Linux driver already supports MSI and MSI-X (the latter not
> tested). Once/if multi-MSI support in Linux becomes available it'd be
> practically possible to scale TCP connections with a number of CPUs.

It's already available, although the API is still a bit clumpsy.

> Alternative: wait until Xframe II adapter w/MSI-X.. 

How does that help with MSI?

-Andi
