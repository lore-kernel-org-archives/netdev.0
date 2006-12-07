From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: network devices don't handle pci_dma_mapping_error()'s
Date: Wed, 06 Dec 2006 22:46:32 -0800
Message-ID: <4577B8C8.5070608@osdl.org>
References: <20061204103949.3d05b1ff@freekitty> <20061206.165418.54722201.davem@davemloft.net> <20061206165835.5391b75d@dxpl.pdx.osdl.net> <200612071155.23412.amitkale@linsyssoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, muli@il.ibm.com,
	jeff@garzik.org, amitkale@netxen.com, netdev@vger.kernel.org,
	brazilnut@us.ibm.com, netxenproj@linsyssoft.com, rob@netxen.com,
	romieu@fr.zoreil.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:54737 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031736AbWLGGxd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 01:53:33 -0500
To: "Amit S. Kale" <amitkale@linsyssoft.com>
In-Reply-To: <200612071155.23412.amitkale@linsyssoft.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amit S. Kale wrote:
> We can let a driver handle dma mapping errors using these->
>
> 1.Reduce the size of a receive ring. This will free some possibly remapped 
> memory, reducing pressure on iommu. We also need to printk a message so that 
> a user knows the reason why receive ring was shrunk. Growing it when iommu 
> pressure goes down will result in a ping-pong.
> 2. Force processing of receive and transmit ring. This will ensure that the 
> buffers processed by hardware are freed, reducing iommu pressure.
>
> 3. If we need to do (1) and (2) a predefined number of times (say 20), stop 
> the queue. Stopping the queue in general will cause a ping-pong, so it should 
> be avoided as far as possible.
>
>   
But what if it isn't the network device that is using all the IOMMU 
resources.
Linux is already crap at handling out of memory, lets not add another 
starvation
path.

In this case, the device does have some idea about "worst case" i/o's in 
flight,
couldn't we have some sort of reservation/management system to avoid 
overcommitting?
Worst case map usage for a network device can be fairly high because of 
the possiblity
of on transmit with a high number of pages when using TSO. Perhaps the 
transmit
ring needs to be accounted for in maps used rather than packets pending.
