From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vrf: fix bug_on triggered by rx when destroying a
 vrf
Date: Thu, 06 Jul 2017 16:47:00 +0100 (WEST)
Message-ID: <20170706.164700.338372660566786964.davem@davemloft.net>
References: <1499343880-30421-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chriscormier@cumulusnetworks.com,
        dsahern@gmail.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34750 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751887AbdGFPrO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 11:47:14 -0400
In-Reply-To: <1499343880-30421-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu,  6 Jul 2017 15:24:40 +0300

> When destroying a VRF device we cleanup the slaves in its ndo_uninit()
> function, but that causes packets to be switched (skb->dev == vrf being
> destroyed) even though we're pass the point where the VRF should be
> receiving any packets while it is being dismantled. This causes a BUG_ON
> to trigger if we have raw sockets (trace below).
> The reason is that the inetdev of the VRF has been destroyed but we're
> still sending packets up the stack with it, so let's free the slaves in
> the dellink callback as David Ahern suggested.
> 
> Note that this fix doesn't prevent packets from going up when the VRF
> device is admin down.
 ...
> Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
> Reported-by: Chris Cormier <chriscormier@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied and queued up for -stable, thanks!
