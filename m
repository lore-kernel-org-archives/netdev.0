From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Wed, 12 Apr 2006 06:49:00 +1000
Message-ID: <1144788541.19353.41.camel@localhost.localdomain>
References: <200604100607.33362.mb@bu3sch.de>
	 <20060410042228.GN27596@ens-lyon.fr>
	 <1144719972.19353.24.camel@localhost.localdomain>
	 <20060410.224933.39567033.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benoit.boissinot@ens-lyon.org, mb@bu3sch.de,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	linux-kernel@vger.kernel.org, linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750902AbWDKUt4@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060410.224933.39567033.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I think allowing DMA mask range limiting in the IOMMU layer is going
> to set a very bad precedence, just don't do it.
> 
> It's 2006, we should be way past the era of not putting the full 32
> PCI DMA address bits in devices.  In this day and age it is simply
> inexscusable.
> 
> Maybe we could understand chips coming out 8 years ago when a lot of
> designs were transitioning from ISA to PCI, but that no longer applies
> in any way today.

I would tend to agree... except that the broadcom is _the_ wireless card
shipped by Apple with all of their machines for the last few years, and
thus, the problem will be hit by pretty much any G5 user trying to use
theirs...

I don't have another idea on how to fix that at hand... a dma mask limit
in the iommu layer is fairly easy to implement with our iommu
implementation (though it wouldn't work on pseries where ranges are
allocated per slot, but it would work fine on a g5). Still sounds better
than introducing a ZONE_DMA separate from ZONE_NORMAL ...

Ben.
