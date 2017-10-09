From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: Fix traffic triggered IPsec connections.
Date: Mon, 09 Oct 2017 09:41:16 -0700 (PDT)
Message-ID: <20171009.094116.582301692542201477.davem@davemloft.net>
References: <20171009064355.GI3149@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tobias@strongswan.org, weiwan@google.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51596 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754079AbdJIQlR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 12:41:17 -0400
In-Reply-To: <20171009064355.GI3149@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 9 Oct 2017 08:43:55 +0200

> A recent patch removed the dst_free() on the allocated
> dst_entry in ipv4_blackhole_route(). The dst_free() marked the
> dst_entry as dead and added it to the gc list. I.e. it was setup
> for a one time usage. As a result we may now have a blackhole
> route cached at a socket on some IPsec scenarios. This makes the
> connection unusable.
> 
> Fix this by marking the dst_entry directly at allocation time
> as 'dead', so it is used only once.
> 
> Fixes: b838d5e1c5b6 ("ipv4: mark DST_NOGC and remove the operation of dst_free()")
> Reported-by: Tobias Brunner <tobias@strongswan.org>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied and queued up for -stable.
