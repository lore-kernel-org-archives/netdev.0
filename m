From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 1/5] try parent numa_node at first before using default
Date: Thu, 12 Jul 2007 17:23:10 +0200
Message-ID: <20070712172310.4d662e1f@gondolin.boeblingen.de.ibm.com>
References: <200707101641.17672.yinghai.lu@sun.com>
	<200707101652.31378.yinghai.lu@sun.com>
	<4694B702.2050507@s5r6.in-berlin.de>
	<20070711210833.GA22745@kroah.com>
	<46954B92.8000407@sun.com>
	<46959651.1050400@s5r6.in-berlin.de>
	<4695998C.8090100@sun.com>
	<4695C088.7000606@s5r6.in-berlin.de>
	<20070712091529.2b914ece@gondolin.boeblingen.de.ibm.com>
	<469610D4.70009@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yinghai.Lu@Sun.COM, Greg KH <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <ak@suse.de>, rientjes@google.com,
	Christoph Lameter <clameter@sgi.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:44198 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756507AbXGLPXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 11:23:02 -0400
In-Reply-To: <469610D4.70009@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Jul 2007 13:30:28 +0200,
Stefan Richter <stefanr@s5r6.in-berlin.de> wrote:

> So, since figuring the correct DMA device out is done by drivers
> themselves, they usually can figure out the correct NUMA node as well.
> The only precondition is that each DMA device has the correct NUMA node
> set.  This is the job of subsystems like PCI, but it may be reasonable
> to have simple and broadly applicable helpers for this in the driver core.
> 
> So, _is_ the dev->numa_node = dev->parent.numa_node assumption, if
> implemented in device_add() and device_move(), as simple and as broadly
> applicable as we want driver core's API to be?  Perhaps yes.

If making the general assumption that the device will inherit the
numa_node through its parent(s) from the responsible DMA device is
reasonable, then device_move() should certainly update the numa_node
from the new parent. (For special cases, the caller could still call
set_dev_node() itself.)
