From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [patch 4/6] [TULIP]  Quiet down tulip_stop_rxtx
Date: Sat, 17 Mar 2007 13:05:56 -0600
Message-ID: <20070317190556.GA19296@colo.lackof.org>
References: <20070312093128.577087000@linux.intel.com> <20070312184218.317747000@linux.intel.com> <45F96556.10205@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Valerie Henson <val_henson@linux.intel.com>, akpm@osdl.org,
	netdev@vger.kernel.org, Grant Grundler <grundler@parisc-linux.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:49659 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753738AbXCQTGF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2007 15:06:05 -0400
Content-Disposition: inline
In-Reply-To: <45F96556.10205@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 15, 2007 at 11:25:10AM -0400, Jeff Garzik wrote:
...
> Here's the problem with this:  this printk is signalling that the DMA 
> engines have not yet stopped, which is an event of which we should be wary.
> 
> While it makes sense to do this patch, since the complaining cards 
> appear to work anyway, we also need to take into account the times when 
> this is not a spurious warning.

It's certainly not spurious warning when in the "unload driver module" path.
This is when the driver unmaps the control data and the particular packet
it's doing DMA to. 

> Thus, I would consider maybe adding a warning somewhere in the 
> DMA-engine-start region of code, that complains if the DMA engines are 
> already active, or somesuch.

Sure. But also in the shutdown path where we unmap any DMA mappings.

thanks,
grant
