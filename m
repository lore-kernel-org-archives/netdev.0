From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_gre: update mtu properly in ip6gre_err
Date: Thu, 07 Sep 2017 20:00:23 -0700 (PDT)
Message-ID: <20170907.200023.2239628642365916828.davem@davemloft.net>
References: <bcd5956b4342a889e686a475e2ec4fcb36db3e57.1504603593.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753132AbdIHDA0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 23:00:26 -0400
In-Reply-To: <bcd5956b4342a889e686a475e2ec4fcb36db3e57.1504603593.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue,  5 Sep 2017 17:26:33 +0800

> Now when probessing ICMPV6_PKT_TOOBIG, ip6gre_err only subtracts the
> offset of gre header from mtu info. The expected mtu of gre device
> should also subtract gre header. Otherwise, the next packets still
> can't be sent out.
> 
> Jianlin found this issue when using the topo:
>   client(ip6gre)<---->(nic1)route(nic2)<----->(ip6gre)server
> 
> and reducing nic2's mtu, then both tcp and sctp's performance with
> big size data became 0.
> 
> This patch is to fix it by also subtracting grehdr (tun->tun_hlen)
> from mtu info when updating gre device's mtu in ip6gre_err(). It
> also needs to subtract ETH_HLEN if gre dev'type is ARPHRD_ETHER.
> 
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thanks.
