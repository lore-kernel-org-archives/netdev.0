From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: dad: don't remove dynamic addresses if link
 is down
Date: Mon, 03 Jul 2017 01:54:38 -0700 (PDT)
Message-ID: <20170703.015438.1191171935015250152.davem@davemloft.net>
References: <cd87260f67fdd2a0b8feba4bed443d162d06254d.1498745606.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54370 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752034AbdGCIyr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 04:54:47 -0400
In-Reply-To: <cd87260f67fdd2a0b8feba4bed443d162d06254d.1498745606.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Thu, 29 Jun 2017 16:56:54 +0200

> Currently, when the link for $DEV is down, this command succeeds but the
> address is removed immediately by DAD (1):
> 
>     ip addr add 1111::12/64 dev $DEV valid_lft 3600 preferred_lft 1800
> 
> In the same situation, this will succeed and not remove the address (2):
> 
>     ip addr add 1111::12/64 dev $DEV
>     ip addr change 1111::12/64 dev $DEV valid_lft 3600 preferred_lft 1800
> 
> The comment in addrconf_dad_begin() when !IF_READY makes it look like
> this is the intended behavior, but doesn't explain why:
> 
>      * If the device is not ready:
>      * - keep it tentative if it is a permanent address.
>      * - otherwise, kill it.
> 
> We clearly cannot prevent userspace from doing (2), but we can make (1)
> work consistently with (2).
> 
> addrconf_dad_stop() is only called in two cases: if DAD failed, or to
> skip DAD when the link is down. In that second case, the fix is to avoid
> deleting the address, like we already do for permanent addresses.
> 
> Fixes: 3c21edbd1137 ("[IPV6]: Defer IPv6 device initialization until the link becomes ready.")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable, thanks.
