From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3 2/2] enic: use netdev_dma_alloc
Date: Wed, 11 Mar 2015 17:34:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAFB899@AcuExch.aculab.com>
References: <1426009384-11544-1-git-send-email-_govind@gmx.com>
 <1426009384-11544-3-git-send-email-_govind@gmx.com>
 <54FF50B0.3080900@redhat.com> <alpine.LNX.2.03.1503111428210.3394@ws.cisco>
 <55004A73.3040904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ssujith@cisco.com" <ssujith@cisco.com>,
	"benve@cisco.com" <benve@cisco.com>
To: 'Alexander Duyck' <alexander.duyck@gmail.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.184]:55771 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbbCKRfT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:35:19 -0400
In-Reply-To: <55004A73.3040904@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck
...
> > Is this behaviour platform dependent? I tested this patch for more
> > than a month
> > and I did not face any issue. I ran normal traffic like ssh, nfs and
> > iperf/netperf.
> > Is there a special scenario when this could occur?
> 
> Yes it depends on the platform and IOMMU used.  For an example take a
> loot at the SWIOTLB implementation.  I always assumed if I can work with
> that when it is doing bounce buffers I can work with any IOMMU or platform.
> 
> >
> > Will using DMA_BIDIRECTIONAL and sync_to_cpu & sync_to_device solve this?
> > Each desc should have different dma address to write to. Can you
> > explain me how
> > this can happen?
> 
> No that won't help.  The issue is that when the page is mapped you
> should not be updating any fields in the page until it is unmapped.
> Since you have multiple buffers mapped to a single page you should be
> waiting until the entire page is unmapped.

Isn't the 'unit of memory for dma sync' a cache line, not a page?

You certainly need to test on systems without cache coherent io.

	David
