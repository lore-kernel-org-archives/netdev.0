From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] vlan: Fix tcp checksums offloads for Q-in-Q
 vlan.
Date: Mon, 22 May 2017 19:59:21 -0400 (EDT)
Message-ID: <20170522.195921.1033609103219347751.davem@davemloft.net>
References: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
        <1495114265-23368-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
        makita.toshiaki@lab.ntt.co.jp
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57340 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758818AbdEVX7X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 19:59:23 -0400
In-Reply-To: <1495114265-23368-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Thu, 18 May 2017 09:31:03 -0400

> It appears that since commit 8cb65d000, Q-in-Q vlans have been
> broken.  The series that commit is part of enabled TSO and checksum
> offloading on Q-in-Q vlans.  However, most HW we support can't handle
> it.  To work around the issue, the above commit added a function that
> turns off offloads on Q-in-Q devices, but it left the checksum offload.
> That will cause issues with most older devices that supprort very basic
> checksum offload capabilities as well as some newer devices (we've
> reproduced te problem with both be2net and bnx).
> 
> To solve this for everyone, turn off checksum offloading feature
> by default when sending Q-in-Q traffic.  Devices that are proven to
> work can provided a corrected ndo_features_check implemetation.
> 
> Fixes: 8cb65d000 ("net: Move check for multiple vlans to drivers")
> CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

This is a tough one.  I can certainly sympathize with your frustration
trying to track this down.

Clearing NETIF_F_HW_CSUM completely is the most conservative change.

However, for all the (perhaps many) cards upon which the checksumming
does work properly in Q-in-Q situations, this change could be
introducing non-trivial performance regressions.

So I think Toshiaki's suggestion to drop IP_CSUM and IPV6_CSUM is,
on balance, the best way forward.

Thanks.
