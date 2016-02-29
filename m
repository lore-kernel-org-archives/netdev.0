From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 09/10] net/mlx5: Fix global UAR mapping
Date: Sun, 28 Feb 2016 23:28:04 -0500 (EST)
Message-ID: <20160228.232804.1263072658789063316.davem@davemloft.net>
References: <1456672151-11749-1-git-send-email-saeedm@mellanox.com>
	<1456672151-11749-10-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, eranbe@mellanox.com,
	talal@mellanox.com, majd@mellanox.com, moshel@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755335AbcB2E2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 23:28:10 -0500
In-Reply-To: <1456672151-11749-10-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Sun, 28 Feb 2016 17:09:10 +0200

> We use ARCH_HAS_IOREMAP_WC to know if the current arch supports WC
> (Write combining) IO memory mapping, if it is not supported
> "uar->bf_map" will be NULL, thus we will use NC (Non Cached) mapping
> "uar->map".

This description sucks.

You're just saying what will happen if the CPP is defined or not
(uar->bf_map ends up being NULL).

Well anyone can see that from the code.

You have to explain why.

And BTW, ARCH_HAS_IOREMAP_WC doesn't even tell you if the platform
will actually give you a write-combining mapping.

So if it's the driver operates properly if a non-WC mapping is used
for uar->bf_map, then get rid of this CPP test altogether PLEASE!

Otherwise your driver is buggy, because ARCH_HAS_IOREMAP_WC only says
whether the default implementation of ioremap_wc() needs to be
provided by include/asm-generic/iomap.h It does not guarantee that a
write-combining mapping will be provided.

I really can't think of any reason why you absolutely require a
WC mapping, and the CPP test just makes your driver look more
ugly than it needs to me.

So can you please explain what the hell is happening here and why you
are doing things this way rather than just reading the code to me?

Thanks.
