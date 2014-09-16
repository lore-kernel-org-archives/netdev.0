From: Meelis Roos <mroos@linux.ee>
Subject: Re: bisected regression: 3c59x corrupts packets in 3.17-rc5
Date: Tue, 16 Sep 2014 13:32:31 +0300 (EEST)
Message-ID: <alpine.LRH.2.11.1409161327110.24403@adalberg.ut.ee>
References: <alpine.LRH.2.11.1409160209280.21050@adalberg.ut.ee> <20140916101704.GA3792@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steffen Klassert <steffen@klassert.de>, netdev@vger.kernel.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140916101704.GA3792@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ Fixed Steffen Klasserts bouncing email address as per the bounce message ]

> > Somewhere between 3.17.0-rc3 and 3.17.0-rc5 I started seeing dropped ssh 
> > connections to a couple of test servers with dual AthlonMP (32-bit) and 
> > 3C90x family of NICs (3Com Corporation 3c980-C 10/100baseTX NIC 
> > [Python-T] (rev 78) in one server and 3Com Corporation 3c905C-TX/TX-M 
> > [Tornado] (rev 78) in the other server). Bisect leads to the following 
> > commit:
> > 
> > 98ea232cf63961fad734cc8c5e07e8915ec73073 is the first bad commit
> > commit 98ea232cf63961fad734cc8c5e07e8915ec73073
> > Author: Neil Horman <nhorman@tuxdriver.com>
> > Date:   Thu Sep 4 06:13:38 2014 -0400
> > 
> >     3c59x: avoid panic in boomerang_start_xmit when finding page address:
> >     ...
> > 
> I'm guessing the above change has uncovered another bug, mostly likely an
> exhaustion of dma space on your system.  Nothing in the transmit path there does
> any error checking for successful dma mapping, which it really should.  I'd be
> willing to be that any dma mapping error leads to a leak in the mapping table.
> Does your system have an iommu, or does it use swiotlb?  If its the latter, can
> you increase the swiotlb table space and see if that relieves the problem?  In
> the interim, I'll start adding some error checking to the transmit path.

# CONFIG_IOMMU_SUPPORT is not set

nothing matching iommu or iotlb in dmesg. I thought the system does not 
have any - K7 CPUs and AMD 760MP chipset with normal AGP gart.

[    3.763519] agpgart-amdk7 0000:00:00.0: AMD 760MP chipset
[    3.782995] agpgart-amdk7 0000:00:00.0: AGP aperture is 64M @ 0xf8000000

-- 
Meelis Roos (mroos@linux.ee)
