From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: network devices don't handle pci_dma_mapping_error()'s
Date: Wed, 6 Dec 2006 10:16:44 -0800
Message-ID: <20061206101644.27eeaf14@freekitty>
References: <200612011340.kB1DeEhR014690@dut39.unminc.com>
	<45711007.5030704@garzik.org>
	<20061204103949.3d05b1ff@freekitty>
	<20061205070045.GE3619@rhun.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	"Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	brazilnut@us.ibm.com, netxenproj@linsyssoft.com, rob@netxen.com,
	romieu@fr.zoreil.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:54584 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937055AbWLFSag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 13:30:36 -0500
To: Muli Ben-Yehuda <muli@il.ibm.com>
In-Reply-To: <20061205070045.GE3619@rhun.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 5 Dec 2006 09:00:45 +0200
Muli Ben-Yehuda <muli@il.ibm.com> wrote:

> On Mon, Dec 04, 2006 at 10:39:49AM -0800, Stephen Hemminger wrote:
> 
> > I notice that no current network driver handles dma mapping errors.
> > Might that be part of the problem.  On i386, this never happens, and
> > it would be rare on most others.
> 
> IOMMUs are already available on x86-64 and are going to get widespread
> with the the introduction of IOMMUs from Intel and AMD. Might as well
> fix it now...
> 
> How about CONFIG_DEBUG_DMA_API that does book-keeping and yells if a
> driver is mis-using the DMA API?
> 
> Cheers,
> Muli

I think it is really only an issue for drivers that turn on HIGH_DMA
and have limited mask values. The majority of drivers either only handle
32 bit (!HIGH_DMA) or do full 64 bit mapping. I don't know the details
of how we manage IOMMU, but doesn't mapping always work for those drivers.

That just leaves devices with odd size mask values that need to be
handle mapping errors.

-- 
Stephen Hemminger <shemminger@osdl.org>
