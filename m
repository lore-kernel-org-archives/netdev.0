From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: fix changing MTU when using per-cpu
 processing
Date: Fri, 01 Apr 2016 15:18:20 -0400 (EDT)
Message-ID: <20160401.151820.127036849232206611.davem@davemloft.net>
References: <1459516878-2802-1-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, nadavh@marvell.com,
	alior@marvell.com, nitroshift@yahoo.com, jaz@semihalf.com
To: mw@semihalf.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459516878-2802-1-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcin Wojtas <mw@semihalf.com>
Date: Fri,  1 Apr 2016 15:21:18 +0200

> After enabling per-cpu processing it appeared that under heavy load
> changing MTU can result in blocking all port's interrupts and transmitting
> data is not possible after the change.
> 
> This commit fixes above issue by disabling percpu interrupts for the
> time, when TXQs and RXQs are reconfigured.
> 
> Signed-off-by: Marcin Wojtas <mw@semihalf.com>

Applied, thanks.

When I reviewed this I was worried that this was yet another case where
the ndo op could be invoked in a potentially atomic or similar context,
whereby on_each_cpu() would be illegal to use.

But that appears to not be the case, and thus this change is just fine.

Thanks.
