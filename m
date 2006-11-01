From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] 2.6.19-rc4 - netlink messages created with bad flags in soft_irq context
Date: Wed, 1 Nov 2006 08:10:25 -0500
Message-ID: <20061101131024.GA11316@gospo.rdu.redhat.com>
References: <20061031220559.GA10119@gospo.rdu.redhat.com> <20061031.220047.08324824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andy@greyhouse.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56005 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1752140AbWKANKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 08:10:32 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061031.220047.08324824.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 31, 2006 at 10:00:47PM -0800, David Miller wrote:
> From: Andy Gospodarek <andy@greyhouse.net>
> Date: Tue, 31 Oct 2006 17:06:00 -0500
> 
> > I've got a kernel built where 
> > 
> > CONFIG_DEBUG_SPINLOCK_SLEEP=y
> > 
> > is in the config and I've noticed some interesting behavior when
> > bringing up bonds in balance-alb mode.  When I start to enslave devices
> > to a bond I get the following in the ring buffer:
> > 
> > BUG: sleeping function called from invalid context at mm/slab.c:3007
> > in_atomic():1, irqs_disabled():0
> 
> As Herbert mentioned, the bonding layer calls into the networking
> in atomic contexts when that is illegal.
> -

Thanks for the feedback.  If it seems the bonding driver is one of the
only culprits, I'll investigate a solution that is specific to bonding
(maybe a workqueue for such calls...) rather that one that effects the
entire stack.

