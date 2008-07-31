From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [patch 3/4] Configure out ethtool support
Date: Thu, 31 Jul 2008 12:29:30 +0100
Message-ID: <1217503770.3454.162.camel@pmac.infradead.org>
References: <20080731092703.661994657@free-electrons.com>
	 <20080731093221.236840420@free-electrons.com>
	 <1217500967.3454.140.camel@pmac.infradead.org>
	 <20080731.035121.177567346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, linux-kernel@vger.kernel.org,
	linux-embedded@vger.kernel.org, michael@free-electrons.com,
	mpm@selenic.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:42568 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbYGaL3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 07:29:35 -0400
In-Reply-To: <20080731.035121.177567346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-07-31 at 03:51 -0700, David Miller wrote:
> CONFIG_INET needs it too.
> 
> dev_disable_lro() calls the ethtool ops directly.

Ah, right. That's why it didn't show up in my grep.

There are solutions to that, as I said. Either we could 'select ETHTOOL'
in those drivers which enable LRO by default, or we could just make sure
they _don't_ enable LRO by default when CONFIG_ETHTOOL isn't set.

And if we end up doing LRO generically in software where the hardware
doesn't handle it, presumably we can do that without having to use
ethtool to change the hardware behaviour?

> But it still needs to be conditional, because as I said what I see
> happening next is this CONFIG_ETHTOOL thing getting jammed into each
> and every network driver.  (in fact, ethtool support code in a single
> driver probably drarfs the 6K savings this initial patch is giving
> us).

I think we can avoid that. If the actual functions and the struct
ethtool_ops are static, and if we have something like...

#ifdef CONFIG_ETHTOOL
#define dev_set_ethtool_ops(dev, ops) dev->ethtool_ops = ops
#else
#define dev_set_ethtool_ops(dev, ops) (void)ops
#endif

... then it should all fall out silently. (Yeah, those definitions would
need 'hardening' but they're a proof of concept).

> And at which point you'll have a broken system for drivers that
> enable LRO and the user enables forwarding.

Obviously that needs avoiding. Thanks for the technical feedback.

After an offline discussion, I understand that if we can sort out the
actual technical issues, you'll carry this in the net tree. Thanks.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



