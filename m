From: Andi Kleen <ak@muc.de>
Subject: Re: Mystery packet killing tg3
Date: 5 May 2005 20:56:35 +0200
Message-ID: <20050505185635.GE24386@muc.de>
References: <20050502162405.65dfb4a9@localhost.localdomain> <20050502200251.38271b61.davem@davemloft.net> <m14qdiyhcn.fsf@muc.de> <42791825.2080204@pantasys.com> <20050505114327.GA51761@muc.de> <427A5363.2080703@pantasys.com> <20050505180609.GB24386@muc.de> <427A6426.40104@pantasys.com> <20050505183144.GD24386@muc.de> <427A6898.4070804@pantasys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 5 May 2005 20:56:35 +0200
To: Peter Buckingham <peter@pantasys.com>
Content-Disposition: inline
In-Reply-To: <427A6898.4070804@pantasys.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2005 at 11:40:24AM -0700, Peter Buckingham wrote:
> Andi Kleen wrote:
> >That should be impossible. Or it sounds like a serious
> >hardware problem. DAC should normally always work with all e1000 AFAIK.
> 
> okay.
> 
> I basically just force it to take a 32bit dma mask. I admit i'm a little 
> clueless as to what this truely means. I had assumed that it would 
> result in only dma'ing to an area below 4GB, but I hadn't really 
> validated that assumption :-(

If you dont use iommu=force it will only cause IOMMU remapping
when the memory buffer is beyond 4GB. It is basically random
if that happens or not, depending on how fully your memory is.

With iommu=force or CONFIG_IOMMU_DEBUG all IO is foced 
through the IOMMU.

> 
> >Most likely you have some hardware problem and it is somehow magically
> >worked around by IOMMU remapping. One difference is that
> >the remapping makes all IO slower, perhaps the changed timing
> >works around some bug.
> 
> this is always a possibility, can you suggest some ways of isolating 
> this problem?

Hmm - if you want to hack the kernel you could add udelay()s
to the no IOMMU paths in arch/x86_64/kernel/pci-gart.c 
and see if that cures the problem too.  If yes then the timing
theory would be proved.
Actually the IOMMU code does more than just delaying, it also
does config space accesses which might flush or synchronize
things in the PCI bridges. Perhaps adding some dummy access
for that would be good too.

The dmesg looks similar to the previous one from the IOMMU
code perspective.

-Andi
