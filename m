From: David Miller <davem@davemloft.net>
Subject: Re: IOAT stuff
Date: Mon, 26 Jun 2006 15:49:32 -0700 (PDT)
Message-ID: <20060626.154932.55726803.davem@davemloft.net>
References: <20060626152939.962b56e6.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christopher.leech@intel.com, andrew.grover@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1948
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933314AbWFZWtk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 18:49:40 -0400
To: rdunlap@xenotime.net
In-Reply-To: <20060626152939.962b56e6.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Randy.Dunlap" <rdunlap@xenotime.net>
Date: Mon, 26 Jun 2006 15:29:39 -0700

> drivers/dma/ioatdma.c:830: warning: no return statement in function returning non-void
> drivers/dma/ioatdma.c:830: warning: control reaches end of non-void function
> 
> Maybe insert "return" in front of:
> 
> 	pci_module_init(&ioat_pci_drv);
> 
> or is there some reason not to do that?
> 
> BTW, pci_module_init() is obsolete.  Drivers should be using
> pci_register_driver() instead.
> 
> PS:  IOAT/DMA (whatever) needs a MAINTAINERS entry.

It also still has the cpu hotplug locking bug, which none of the
I/O AT developers have even mentioned that they'd try to fix.

To reiterate, it tries to lock hotplug while holding spinlocks
which is illegal because locking hotplug takes a semaphore which
can sleep.
