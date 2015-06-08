From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: fix possible use after free of dev stats
Date: Mon, 08 Jun 2015 17:46:17 +0200
Message-ID: <1433778377.13489.18.camel@stressinduktion.org>
References: <1433526714-18770-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:36724 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751896AbbFHPqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 11:46:19 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 3F72A208C6
	for <netdev@vger.kernel.org>; Mon,  8 Jun 2015 11:46:19 -0400 (EDT)
In-Reply-To: <1433526714-18770-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2015-06-05 at 18:51 +0100, Robert Shearman wrote:
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

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
