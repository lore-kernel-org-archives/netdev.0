From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Sat, 8 Jul 2006 12:48:12 +0200
Message-ID: <20060708104811.GB31751@lst.de>
References: <20060707090956.GA2543@lst.de> <20060707155255.10f2e10f@dxpl.pdx.osdl.net> <20060707.165527.77037268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, hch@lst.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:32478 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1751284AbWGHKsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2006 06:48:30 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060707.165527.77037268.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 07, 2006 at 04:55:27PM -0700, David Miller wrote:
> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Fri, 7 Jul 2006 15:52:55 -0700
> 
> > What is the point of dev_alloc_skb anyway? all it does is add header space.
> 
> In stone-age times it actually had specific semantics, but yes today
> it is just a synonym.
> 
> It's going to be hard to get rid of it, every single network driver
> out there references it.

On powerpc64 it actually makes a difference because it now allocates the
right headerspace as pad to ge the higher layer protocol headers aligned
for best dma performance.

Now what lead me up to this patch is something else.  On the Cell
hardware we badly need to allocate rx buffers on the local node, because
the access to memory on a different node is horrible slow (thank rambus!)

My plan is to give dev_alloc_skb a struct netdevice * argument and
introduce a alloc_netdev_node so the driver can tell what node the
device is on.  This gives a significant speedup for cell.  I already
have this implemented in fact but only converted a handfull of drivers.

Does this approach sound okay?
