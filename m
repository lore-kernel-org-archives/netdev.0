From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [PATCH] [2.4] forcedeth network driver
Date: Tue, 27 Jan 2004 14:30:14 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040127143011.A1314@sygehus.dk>
References: <4012BF44.9@colorfullife.com> <4012D3C6.1050805@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <4012D3C6.1050805@pobox.com>; from jgarzik@pobox.com on Sat, Jan 24, 2004 at 03:21:26PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jan 24, 2004 at 03:21:26PM -0500, Jeff Garzik wrote:
> Manfred Spraul wrote:
> > Jeff wrote:
> 
> >>> +        /*
> >>> +         * the packet is for us - immediately tear down the pci 
> >>> mapping, and
> >>> +         * prefetch the first cacheline of the packet.
> >>> +         */
> >>> +        pci_unmap_single(np->pci_dev, np->rx_dma[i],
> >>> +                np->rx_skbuff[i]->len,
> >>> +                PCI_DMA_FROMDEVICE);
> >>> +        prefetch(np->rx_skbuff[i]->data);
> >>
> >>
> >> is this just guessing?  or has this actually shown some value?
> >>
> >> I would prefer not to put stuff like this in unless it shows a 
> >> measureable CPU usage or cache miss impact.
> >>  
> >>
> > Just guessing - it shouldn't hurt. CPU usage won't be important until 
> > nForce supports GigE. Should I remove it for now?
> 
> I would rather remove it.  "premature optimization" and all that. 
> Otherwise this guess will be cut-n-pasted into other drivers, I 
> guarantee, all without any verification of the guess... :)

There was a thread about using prefetch() on netdev or linux-net.
The idea is to have the Ethernet header prefetched by the time
eth_type_trans() needs it.

> >> bug #2:  need a minimum bound for the MTU as well
> >>  
> >>
> > What is the minimum MTU? I remember a flamewar lkml about 200 byte MTU 
> > for noisy radio links.
> 
> Usually the ethernet standard 60 is fine.

Minimum MTU != minimum frame length. An MTU of 0 should work fine. It is
just not very useful in most cases to send just the Ethernet header but
no payload.

-- 
Regards,
Rask Ingemann Lambertsen
