From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qede: Correctly map aggregation replacement pages
Date: Thu, 03 Nov 2016 15:34:48 -0400 (EDT)
Message-ID: <20161103.153448.1648752999199676420.davem@davemloft.net>
References: <1478097406-9794-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41592 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752054AbcKCTeu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 15:34:50 -0400
In-Reply-To: <1478097406-9794-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Wed, 2 Nov 2016 16:36:46 +0200

> Driver allocates replacement buffers before-hand to make
> sure whenever an aggregation begins there would be a replacement
> for the Rx buffers, as we can't release the buffer until
> aggregation is terminated and driver logic assumes the Rx rings
> are always full.
> 
> For every other Rx page that's being allocated [I.e., regular]
> the page is being completely mapped while for the replacement
> buffers only the first portion of the page is being mapped.
> This means that:
>   a. Once replacement buffer replenishes the regular Rx ring,
> assuming there's more than a single packet on page we'd post unmapped
> memory toward HW [assuming mapping is actually done in granularity
> smaller than page].
>   b. Unmaps are being done for the entire page, which is incorrect.
> 
> Fixes: 55482edc25f06 ("qede: Add slowpath/fastpath support and enable hardware GRO")
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied.
