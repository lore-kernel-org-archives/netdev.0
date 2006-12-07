From: "Amit S. Kale" <amitkale@linsyssoft.com>
Subject: Re: network devices don't handle pci_dma_mapping_error()'s
Date: Thu, 7 Dec 2006 12:25:37 +0530
Message-ID: <200612071225.38485.amitkale@linsyssoft.com>
References: <20061204103949.3d05b1ff@freekitty> <200612071155.23412.amitkale@linsyssoft.com> <4577B8C8.5070608@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, muli@il.ibm.com,
	jeff@garzik.org, amitkale@netxen.com, netdev@vger.kernel.org,
	brazilnut@us.ibm.com, netxenproj@linsyssoft.com, rob@netxen.com,
	romieu@fr.zoreil.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:46795 "EHLO
	svr68.ehostpros.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031744AbWLGGzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 01:55:24 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <4577B8C8.5070608@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 07 December 2006 12:16, Stephen Hemminger wrote:
> Amit S. Kale wrote:
> > We can let a driver handle dma mapping errors using these->
> >
> > 1.Reduce the size of a receive ring. This will free some possibly
> > remapped memory, reducing pressure on iommu. We also need to printk a
> > message so that a user knows the reason why receive ring was shrunk.
> > Growing it when iommu pressure goes down will result in a ping-pong.
> > 2. Force processing of receive and transmit ring. This will ensure that
> > the buffers processed by hardware are freed, reducing iommu pressure.
> >
> > 3. If we need to do (1) and (2) a predefined number of times (say 20),
> > stop the queue. Stopping the queue in general will cause a ping-pong, so
> > it should be avoided as far as possible.
>
> But what if it isn't the network device that is using all the IOMMU
> resources.
> Linux is already crap at handling out of memory, lets not add another
> starvation
> path.
>
> In this case, the device does have some idea about "worst case" i/o's in
> flight,
> couldn't we have some sort of reservation/management system to avoid
> overcommitting?
> Worst case map usage for a network device can be fairly high because of
> the possiblity
> of on transmit with a high number of pages when using TSO. Perhaps the
> transmit
> ring needs to be accounted for in maps used rather than packets pending.

I am afraid I don't have a good answer for that. Any kind of reservation may 
result in underutilization and transparently shared resources may result in 
starvation.

Designing heuristics for handling these cases may be the only possible wayout, 
though these heuristics need to be validated frequently to ensure that they 
aren't out of date.
-Amit
