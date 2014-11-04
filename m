From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] neigh: remove dynamic neigh table
 registration support
Date: Tue, 04 Nov 2014 17:02:51 -0500 (EST)
Message-ID: <20141104.170251.950859328398615616.davem@davemloft.net>
References: <1415038454-8150-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbaKDWCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 17:02:53 -0500
In-Reply-To: <1415038454-8150-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon,  3 Nov 2014 10:14:14 -0800

> Currently there are only three neigh tables in the whole kernel:
> arp table, ndisc table and decnet neigh table. What's more,
> we don't support registering multiple tables per family.
> Therefore we can just make these tables statically built-in.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
> v2: remove useless #ifdef's
>     move the assignment to the end of neigh_table_init()

neigh_table_clear should definitely NULL out the slot, otherwise
we hold in there a pointer to module memory which is about to
be released.
