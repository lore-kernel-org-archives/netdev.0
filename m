From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [PATCH] mlx4_core: module param to limit msix vec allocation
Date: Fri, 3 Sep 2010 13:30:44 -0700
Message-ID: <20100903203044.GN2464@sgi.com>
References: <20100826170646.GB27157@sgi.com> <20100826.122407.260097270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:37080 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754664Ab0ICUaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 16:30:46 -0400
Content-Disposition: inline
In-Reply-To: <20100826.122407.260097270.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 26, 2010 at 12:24:07PM -0700, David Miller wrote:
> ....
> And what the heck happens if every single device driver tries to
> handle this problem in the same way?  It makes no sense to make
> the user specify N special module parameters just to get a working
> system using MSI-X.
> 
> This must be fixed in a centralized way that allows coordination
> between devices which compete for MSI-X vector resources, rather than
> in a way that is specific to each and every device type.
> 

OK, how about this. Each time the kernel assigns a default 
affinity for an interrupt, it generates a netlink message, 
and a user-level interrupt balancer can decide whether and 
how to reassign the interrupt? 

I have that running on a (very small) system and it seems to 
work OK. Will send out the patch in just a minute.

-- 
Arthur
