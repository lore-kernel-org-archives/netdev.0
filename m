From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_cubic: fix the range of delayed_ack
Date: Wed, 30 Apr 2014 16:16:33 -0400 (EDT)
Message-ID: <20140430.161633.2228202513815917029.davem@davemloft.net>
References: <5360C391.2040202@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ncardwell@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: allanliuyu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422770AbaD3UQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 16:16:34 -0400
In-Reply-To: <5360C391.2040202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liu Yu <allanliuyu@gmail.com>
Date: Wed, 30 Apr 2014 17:34:09 +0800

> 
> From: Liu Yu <allanyuliu@tencent.com>
> 
> commit b9f47a3aaeab (tcp_cubic: limit delayed_ack ratio to prevent
> divide error) try to prevent divide error, but there is still a little
> chance that delayed_ack can reach zero. In case the param cnt get
> negative value, then ratio+cnt would overflow and may happen to be zero.
> As a result, min(ratio, ACK_RATIO_LIMIT) will calculate to be zero.
> 
> In some old kernels, such as 2.6.32, there is a bug that would
> pass negative param, which then ultimately leads to this divide error.
> 
> commit 5b35e1e6e9c (tcp: fix tcp_trim_head() to adjust segment count
> with skb MSS) fixed the negative param issue. However, 
> it's safe that we fix the range of delayed_ack as well,
> to make sure we do not hit a divide by zero.
> 
> CC: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Liu Yu <allanyuliu@tencent.com>

Applied and queued up for -stable, thanks.
