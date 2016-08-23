From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ipv6: Remove addresses for failures with
 strict DAD
Date: Mon, 22 Aug 2016 17:00:00 -0700 (PDT)
Message-ID: <20160822.170000.2150110843821976226.davem@davemloft.net>
References: <1471527581-9125-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46919 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757232AbcHWAAB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 20:00:01 -0400
In-Reply-To: <1471527581-9125-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Thu, 18 Aug 2016 14:39:40 +0100

> If DAD fails with accept_dad set to 2, global addresses and host routes
> are incorrectly left in place. Even though disable_ipv6 is set,
> contrary to documentation, the addresses are not dynamically deleted
> from the interface. It is only on a subsequent link down/up that these
> are removed. The fix is not only to set the disable_ipv6 flag, but
> also to call addrconf_ifdown(), which is the action to carry out when
> disabling IPv6. This results in the addresses and routes being deleted
> immediately. The DAD failure for the LL addr is determined as before
> via netlink, or by the absence of the LL addr (which also previously
> would have had to be checked for in case of an intervening link down
> and up). As the call to addrconf_ifdown() requires an rtnl lock, the
> logic to disable IPv6 when DAD fails is moved to addrconf_dad_work().
 ...
> Signed-off-by: Mike Manning <mmanning@brocade.com>

Applied, thanks.
