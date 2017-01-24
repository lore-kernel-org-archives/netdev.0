From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] mlx5: Fix page rfcnt issue
Date: Mon, 23 Jan 2017 19:16:53 -0500 (EST)
Message-ID: <20170123.191653.947869807938526572.davem@davemloft.net>
References: <20170123235658.3872770-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, saeedm@mellanox.com,
        kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38562 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdAXAQ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:16:57 -0500
In-Reply-To: <20170123235658.3872770-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 23 Jan 2017 15:56:58 -0800

> One other potential problem in the driver is the use of put_page in
> release pages.  Comparing how the allocation is done in other drivers
> (for instance comparing to ixgbe) some seem to use __free_pages instead.
> I don't know which is correct to use, but somehow it doesn't seem like
> they can both be right.

The only difference I can see is that put_page() does a
__page_cache_release() which shouldn't be necessary for driver RX
pages, so it could be unnecessary overhead.
