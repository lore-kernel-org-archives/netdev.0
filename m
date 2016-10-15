From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: Zero memory allocated for statistics
Date: Sat, 15 Oct 2016 11:18:14 -0400 (EDT)
Message-ID: <20161015.111814.1130714147077640809.davem@davemloft.net>
References: <1476439158-66060-1-git-send-email-vlad@tsyrklevich.net>
        <20161014.212128.1303887902157786593.davem@davemloft.net>
        <CAH0z3hMSTAWQK550gTpZ3jv1BnEpjHKoCC6wz182YYHLVcesQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vlad@tsyrklevich.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33516 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753665AbcJOP14 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 11:27:56 -0400
In-Reply-To: <CAH0z3hMSTAWQK550gTpZ3jv1BnEpjHKoCC6wz182YYHLVcesQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Tsyrklevich <vlad@tsyrklevich.net>
Date: Sat, 15 Oct 2016 15:11:08 +0000

> I agree that we should propagate those errors and I'll prepare a new change
> to do so for phy_driver.get_stats(), ethtool_ops.self_test(), and
> ethtool_ops.get_ethtool_stats(). However, I still think this change should
> be adopted. 3/5 of the cases here are reachable without any special
> capabilities and programming defensively at the ethtool interface can
> eliminate an entire class of potential driver bugs instead of fixing them
> one by one. For example, get_eeprom() propagates errors but with a brief
> grep I found that qlcnic_get_eeprom() will return 0 incorrectly even though
> it read nothing for some NICs. Deeper bugs are undoubtedly laying around.

I'm all for defensive program when practical.

But statistics gathering is highly performance sensitive for many
important use cases, so I'm not ready to add a whole bzero() here
unless absolutely, positively, necessary.

Thanks.
