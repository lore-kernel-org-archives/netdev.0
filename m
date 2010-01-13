From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: ixgbe NULLL pointer dereference on OOM condition, 2.6.31.7
Date: Tue, 12 Jan 2010 18:13:10 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1001121757040.3168@jbrandeb-desk1.amr.corp.intel.com>
References: <4B424825.2070608@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NetDev <netdev@vger.kernel.org>, jesse.brandeburg@intel.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1521 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752607Ab0AMCNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2010 21:13:11 -0500
In-Reply-To: <4B424825.2070608@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Jan 2010, Ben Greear wrote:

> This is on a hacked 2.6.31.7 kernel.  I'm testing an application that creates
> 30,000+ TCP connections (to self).  The system is 64-bit with 12GB of RAM, but
> it can still run out of usable RAM (say, when I start another 10k connections
> to bring it up to 40k).
> 
> It looks like something in ixgbe isn't properly checking for inability
> to allocate (or to have previously allocated) an skb, or perhaps some other
> chunk of memory:
> 
> [root@ct503-10G-09 ~]# BUG: unable to handle kernel NULL pointer dereference at 00000000000000e8
> IP: [<ffffffffa0054ca0>] ixgbe_clean_rx_irq+0xe4/0x522 [ixgbe]

Hi Ben, thanks for the report, is there a chance you can run gdb on your 
kernel (was it compiled with debug info?) and check the
gdb> l *(ixgbe_clean_rx_irq+0xe4)

Sorry I'm so slow to respond.

it seems there are some unwind problems after the recent round of patches 
to remove skb_dma_map/unmap, but those were only introduced in 2.6.33-rc1.  
Before that we weren't aware of any failure path issues.

I'm building a kernel now to see if I can figure out the offset where 
you're showing the problem.

Jesse
