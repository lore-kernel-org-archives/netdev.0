From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sctp: Fix data chunk fragmentation for MTU values
 which are not multiple of 4
Date: Wed, 04 Sep 2013 13:20:58 -0400 (EDT)
Message-ID: <20130904.132058.515642898688349547.davem@davemloft.net>
References: <52249981.8040006@nsn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	matija.glavinic-pecotic.ext@nsn.com, netdev@vger.kernel.org
To: alexander.sverdlin@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922Ab3IDRVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 13:21:00 -0400
In-Reply-To: <52249981.8040006@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Sverdlin <alexander.sverdlin@nsn.com>
Date: Mon, 02 Sep 2013 15:58:25 +0200

> From: Alexander Sverdlin <alexander.sverdlin@nsn.com>
> 
> net: sctp: Fix data chunk fragmentation for MTU values which are not multiple of 4
> 
> Initially the problem was observed with ipsec, but later it became clear that
> SCTP data chunk fragmentation algorithm has problems with MTU values which are
> not multiple of 4. Test program was used which just transmits 2000 bytes long
> packets to other host. tcpdump was used to observe re-fragmentation in IP layer
> after SCTP already fragmented data chunks.
 ...
> Here problem in data portion limit calculation leads to re-fragmentation in IP,
> which is sub-optimal. The problem is max_data initial value, which doesn't take
> into account the fact, that data chunk must be padded to 4-bytes boundary.
> It's enough to correct max_data, because all later adjustments are correctly
> aligned to 4-bytes boundary.
> 
> After the fix is applied, everything is fragmented correctly for uneven MTUs:
 ...
> The bug was there for years already, but
>  - is a performance issue, the packets are still transmitted
>  - doesn't show up with default MTU 1500, but possibly with ipsec (MTU 1438)
> 
> Signed-off-by: Alexander Sverdlin <alexander.sverdlin@nsn.com>

Applied, thanks.
