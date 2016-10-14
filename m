From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: correctly add local routes when lo goes up
Date: Fri, 14 Oct 2016 10:06:34 -0400 (EDT)
Message-ID: <20161014.100634.1750361454408261153.davem@davemloft.net>
References: <1476259840-26261-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Balakumaran.Kannan@ap.sony.com,
        Maruthi.Thotad@ap.sony.com, sd@queasysnail.net,
        hannes@stressinduktion.org, chenweilong@huawei.com,
        gaofeng@cn.fujitsu.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47438 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754538AbcJNON3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 10:13:29 -0400
In-Reply-To: <1476259840-26261-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 12 Oct 2016 10:10:40 +0200

> The goal of the patch is to fix this scenario:
>  ip link add dummy1 type dummy
>  ip link set dummy1 up
>  ip link set lo down ; ip link set lo up
> 
> After that sequence, the local route to the link layer address of dummy1 is
> not there anymore.
> 
> When the loopback is set down, all local routes are deleted by
> addrconf_ifdown()/rt6_ifdown(). At this time, the rt6_info entry still
> exists, because the corresponding idev has a reference on it. After the rcu
> grace period, dst_rcu_free() is called, and thus ___dst_free(), which will
> set obsolete to DST_OBSOLETE_DEAD.
> 
> In this case, init_loopback() is called before dst_rcu_free(), thus
> obsolete is still sets to something <= 0. So, the function doesn't add the
> route again. To avoid that race, let's check the rt6 refcnt instead.
> 
> Fixes: 25fb6ca4ed9c ("net IPv6 : Fix broken IPv6 routing table after loopback down-up")
> Fixes: a881ae1f625c ("ipv6: don't call addrconf_dst_alloc again when enable lo")
> Fixes: 33d99113b110 ("ipv6: reallocate addrconf router for ipv6 address when lo device up")
> Reported-by: Francesco Santoro <francesco.santoro@6wind.com>
> Reported-by: Samuel Gauthier <samuel.gauthier@6wind.com>
 ...
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, thanks.
