From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] netvsc: fix race on sub channel creation
Date: Sun, 06 Aug 2017 21:24:02 -0700 (PDT)
Message-ID: <20170806.212402.2131646989155240015.davem@davemloft.net>
References: <20170804001354.17067-1-sthemmin@microsoft.com>
        <20170804001354.17067-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        devel@linuxdriverproject.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50388 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751424AbdHGEYE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 00:24:04 -0400
In-Reply-To: <20170804001354.17067-2-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu,  3 Aug 2017 17:13:54 -0700

> The existing sub channel code did not wait for all the sub-channels
> to completely initialize. This could lead to race causing crash
> in napi_netif_del() from bad list. The existing code would send
> an init message, then wait only for the initial response that
> the init message was received. It thought it was waiting for
> sub channels but really the init response did the wakeup.
> 
> The new code keeps track of the number of open channels and
> waits until that many are open.
> 
> Other issues here were:
>   * host might return less sub-channels than was requested.
>   * the new init status is not valid until after init was completed.
> 
> Fixes: b3e6b82a0099 ("hv_netvsc: Wait for sub-channels to be processed during probe")
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied, thanks.
