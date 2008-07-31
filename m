From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/4] Configure out ethtool support
Date: Thu, 31 Jul 2008 03:51:21 -0700 (PDT)
Message-ID: <20080731.035121.177567346.davem@davemloft.net>
References: <20080731092703.661994657@free-electrons.com>
	<20080731093221.236840420@free-electrons.com>
	<1217500967.3454.140.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, linux-kernel@vger.kernel.org,
	linux-embedded@vger.kernel.org, michael@free-electrons.com,
	mpm@selenic.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: dwmw2@infradead.org
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <1217500967.3454.140.camel@pmac.infradead.org>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 31 Jul 2008 11:42:47 +0100

> It's alleged that these functions are called from 'core' network code in
> some places, although I can't actually see any evidence of that anywhere
> in Linus' tree except for vlans and bridging.
> 
> If that's actually the case, perhaps it makes sense to add a
> WARN_ON_ONCE() to these empty functions, so that a developer who
> disables CONFIG_ETHTOOL when they shouldn't will see a nasty warning
> about it rather than a silent failure?
> 
> Btw, I see you've made bridging 'select ETHTOOL'; did you do the same
> for vlan support?

CONFIG_INET needs it too.

dev_disable_lro() calls the ethtool ops directly.

But it still needs to be conditional, because as I said what I see
happening next is this CONFIG_ETHTOOL thing getting jammed into each
and every network driver.  (in fact, ethtool support code in a single
driver probably drarfs the 6K savings this initial patch is giving
us).

And at which point you'll have a broken system for drivers that
enable LRO and the user enables forwarding.
