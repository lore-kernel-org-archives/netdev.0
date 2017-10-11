From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 1/4] net: ipv6: Make inet6addr_validator a
 blocking notifier
Date: Wed, 11 Oct 2017 14:13:01 -0700 (PDT)
Message-ID: <20171011.141301.998956921662009292.davem@davemloft.net>
References: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
        <1507653665-20540-2-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        kjlx@templeofstupid.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36822 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751906AbdJKVND (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:13:03 -0400
In-Reply-To: <1507653665-20540-2-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Tue, 10 Oct 2017 09:41:02 -0700

> +	/* validator notifier needs to be blocking;
> +	 * do not call in softirq context
> +	 */
> +	if (!in_softirq()) {

I think we can test this better.

You should be able to audit the call sites and for each one set the
value of a new boolean argument properly, and this way you can also
give the boolean argument a descriptive name.

Furthermore, we can also then pull the inet6_addr allocation out of
the locking paths and thus use GFP_KERNEL when possible.
