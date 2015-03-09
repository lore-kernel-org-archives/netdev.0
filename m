From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: destroy proto tp when all filters
 are gone
Date: Sun, 08 Mar 2015 22:29:24 -0400 (EDT)
Message-ID: <20150308.222924.1569062248098813848.davem@davemloft.net>
References: <1425671279-25399-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cwang@twopensource.com, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbbCIC30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 22:29:26 -0400
In-Reply-To: <1425671279-25399-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri,  6 Mar 2015 11:47:59 -0800

> From: Cong Wang <cwang@twopensource.com>
> 
> Kernel automatically creates a tp for each
> (kind, protocol, priority) tuple, which has handle 0,
> when we add a new filter, but it still is left there
> after we remove our own, unless we don't specify the
> handle (literally means all the filters under
> the tuple). For example this one is left:
> 
>   # tc filter show dev eth0
>   filter parent 8001: protocol arp pref 49152 basic
> 
> The user-space is hard to clean up these for kernel
> because filters like u32 are organized in a complex way.
> So kernel is responsible to remove it after all filters
> are gone.  Each type of filter has its own way to
> store the filters, so each type has to provide its
> way to check if all filters are gone.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

This looks fine to me, Jamal please review.
