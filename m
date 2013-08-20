From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: remove max_addresses check from
 ipv6_create_tempaddr
Date: Tue, 20 Aug 2013 00:12:10 -0700 (PDT)
Message-ID: <20130820.001210.545160050042572433.davem@davemloft.net>
References: <20130816110226.GB2112@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dingtianhong@huawei.com, kargig@void.gr,
	ppandit@redhat.com, yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36615 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab3HTHML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 03:12:11 -0400
In-Reply-To: <20130816110226.GB2112@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 16 Aug 2013 13:02:27 +0200

> Because of the max_addresses check attackers were able to disable privacy
> extensions on an interface by creating enough autoconfigured addresses:
> 
> <http://seclists.org/oss-sec/2012/q4/292>
> 
> But the check is not actually needed: max_addresses protects the
> kernel to install too many ipv6 addresses on an interface and guards
> addrconf_prefix_rcv to install further addresses as soon as this limit
> is reached. We only generate temporary addresses in direct response of
> a new address showing up. As soon as we filled up the maximum number of
> addresses of an interface, we stop installing more addresses and thus
> also stop generating more temp addresses.
> 
> Even if the attacker tries to generate a lot of temporary addresses
> by announcing a prefix and removing it again (lifetime == 0) we won't
> install more temp addresses, because the temporary addresses do count
> to the maximum number of addresses, thus we would stop installing new
> autoconfigured addresses when the limit is reached.
> 
> This patch fixes CVE-2013-0343 (but other layer-2 attacks are still
> possible).
> 
> Thanks to Ding Tianhong to bring this topic up again.
> 
> Cc: Ding Tianhong <dingtianhong@huawei.com>
> Cc: George Kargiotakis <kargig@void.gr>
> Cc: P J P <ppandit@redhat.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
