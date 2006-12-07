From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: network devices don't handle pci_dma_mapping_error()'s
Date: Thu, 7 Dec 2006 12:07:52 -0800
Message-ID: <20061207120752.35f56c15@localhost>
References: <20061206.165418.54722201.davem@davemloft.net>
	<20061206165835.5391b75d@dxpl.pdx.osdl.net>
	<200612071155.23412.amitkale@linsyssoft.com>
	<20061206.232459.31658283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: amitkale@linsyssoft.com, muli@il.ibm.com, jeff@garzik.org,
	amitkale@netxen.com, netdev@vger.kernel.org, brazilnut@us.ibm.com,
	netxenproj@linsyssoft.com, rob@netxen.com, romieu@fr.zoreil.com,
	sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:34633 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1163254AbWLGUJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 15:09:28 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061206.232459.31658283.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 06 Dec 2006 23:24:59 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: "Amit S. Kale" <amitkale@linsyssoft.com>
> Date: Thu, 7 Dec 2006 11:55:22 +0530
> 
> > We can let a driver handle dma mapping errors using these->
> > 
> > 1.Reduce the size of a receive ring. This will free some possibly remapped 
> > memory, reducing pressure on iommu. We also need to printk a message so that 
> > a user knows the reason why receive ring was shrunk. Growing it when iommu 
> > pressure goes down will result in a ping-pong.
> > 2. Force processing of receive and transmit ring. This will ensure that the 
> > buffers processed by hardware are freed, reducing iommu pressure.
> > 
> > 3. If we need to do (1) and (2) a predefined number of times (say 20), stop 
> > the queue. Stopping the queue in general will cause a ping-pong, so it should 
> > be avoided as far as possible.
> 
> This scheme assumes the networking card is the culprit.  In many
> workloads it will not be and these efforts will be in vain and perhaps
> even make the situation worse.  There's not reason to run the RX and
> TX queues, and even shrink them, when the FC controller has most of
> the IOMMU entires tied up.
> 
> That's why users needs to queue up and get feedback when IOMMU space
> is made available.

Looking at other subsystems, the disk code seems to return I/O errors
if dma mapping fails. Perhaps this discussion needs to move off to lkml
or the platform lists.
