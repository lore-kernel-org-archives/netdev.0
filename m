From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net v2] net: check dev->addr_len for
 dev_set_mac_address()
Date: Sat, 29 Jul 2017 11:25:52 -0700 (PDT)
Message-ID: <20170729.112552.37407845739598905.davem@davemloft.net>
References: <20170726222207.5922-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com, jiri@resnulli.us
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40112 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752948AbdG2SZx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 14:25:53 -0400
In-Reply-To: <20170726222207.5922-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 26 Jul 2017 15:22:06 -0700

> Historically, dev_ifsioc() uses struct sockaddr as mac
> address definition, this is why dev_set_mac_address()
> accepts a struct sockaddr pointer as input but now we
> have various types of mac addresse whose lengths
> are up to MAX_ADDR_LEN, longer than struct sockaddr,
> and saved in dev->addr_len.
> 
> It is too late to fix dev_ifsioc() due to API
> compatibility, so just reject those larger than
> sizeof(struct sockaddr), otherwise we would read
> and use some random bytes from kernel stack.
> 
> Fortunately, only a few IPv6 tunnel devices have addr_len
> larger than sizeof(struct sockaddr) and they don't support
> ndo_set_mac_addr(). But with team driver, in lb mode, they
> can still be enslaved to a team master and make its mac addr
> length as the same.
> 
> Cc: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
