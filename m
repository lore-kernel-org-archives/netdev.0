From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: RE: [PATCH net-next 3/3] mlx4_en: Saving mem access on data path
Date: Fri, 24 Feb 2012 19:57:43 +0000
Message-ID: <953B660C027164448AE903364AC447D2618B8782@MTLDAG02.mtl.com>
References: <4F464074.9050901@mellanox.co.il>
 <20120223.144749.1718133820851859801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:40883 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755890Ab2BXT64 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 14:58:56 -0500
In-Reply-To: <20120223.144749.1718133820851859801.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >
> > Localized the pdev->dev, and using dma_map instead of pci_map
> > There are multiple map/unmap operations on data path,
> > optimizing those by saving redundant pointer access.
> >
> > Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> 
> I doubt you can measure any improvement from this at all, all of the
> real cost is going to be in programming the hardware (both the
> networking chip and potentially any IOMMU hardware to setup the DMA
> mappings).  A pointer deref in of your datastructures will be unnoticable.

We actually did measure improvements with this changes.
Those places were found as hot spots when we did kernel profiling on some benchmarks.
Making those changes actually helped us reduce cpu utilization in several %, and in some cases was the
difference between being CPU bounded or reaching wire speed.
One scenario that we had improvement in when making this change is measuring Packet Rate for
small (64 Byte) packets.

> 
> When you make changes like this I want you to justify them with real
> data and facts.

I agree, the explanation should have been part of the patch description.

> I think this entire patch set was in very poor taste and judgment.
 
Dave,
Thank you for the comprehensive review, please allow me to kindly disagree with the last statement.

The patch set is a result of performance work we did, and those changes helped us to achieve
better results without hurting us in other areas.
I do understand you concern regarding patch 2/3, although we did test it in various scenarios without
running into the issues you described, and there are other vendors doing the same.

I still think that patches 1 and 3 are good for our device,
I'll be happy to make changes in them if you find it necessary, and resubmit.

Thanks,
Yevgeny 
