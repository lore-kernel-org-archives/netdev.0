From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix bogus cast in skb_pagelen() and use unsigned
 variables
Date: Sat, 19 Nov 2016 22:12:15 -0500 (EST)
Message-ID: <20161119.221215.1839854526883011435.davem@davemloft.net>
References: <20161119010808.GF1200@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45912 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753126AbcKTDMQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 22:12:16 -0500
In-Reply-To: <20161119010808.GF1200@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sat, 19 Nov 2016 04:08:08 +0300

> 1) cast to "int" is unnecessary:
>    u8 will be promoted to int before decrementing,
>    small positive numbers fit into "int", so their values won't be changed
>    during promotion.
> 
>    Once everything is int including loop counters, signedness doesn't
>    matter: 32-bit operations will stay 32-bit operations.
> 
>    But! Someone tried to make this loop smart by making everything of
>    the same type apparently in an attempt to optimise it.
>    Do the optimization, just differently.
>    Do the cast where it matters. :^)
> 
> 2) frag size is unsigned entity and sum of fragments sizes is also
>    unsigned.
> 
> Make everything unsigned, leave no MOVSX instruction behind.
 ...
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next.
