From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix possible use after free of dev stats
Date: Mon, 08 Jun 2015 12:15:34 -0700 (PDT)
Message-ID: <20150608.121534.1373441017651672686.davem@davemloft.net>
References: <1433526714-18770-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbbFHTPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 15:15:43 -0400
In-Reply-To: <1433526714-18770-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Fri, 5 Jun 2015 18:51:54 +0100

> The memory pointed to by idev->stats.icmpv6msgdev,
> idev->stats.icmpv6dev and idev->stats.ipv6 can each be used in an RCU
> read context without taking a reference on idev. For example, through
> IP6_*_STATS_* calls in ip6_rcv. These memory blocks are freed without
> waiting for an RCU grace period to elapse. This could lead to the
> memory being written to after it has been freed.
> 
> Fix this by using call_rcu to free the memory used for stats, as well
> as idev after an RCU grace period has elapsed.
> 
> Signed-off-by: Robert Shearman <rshearma@brocade.com>

Applied.
