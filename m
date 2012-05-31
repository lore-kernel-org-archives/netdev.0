From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] bql: Avoid unneeded limit decrement.
Date: Thu, 31 May 2012 18:20:01 -0400 (EDT)
Message-ID: <20120531.182001.608787450402251601.davem@davemloft.net>
References: <20120531072519.16464513.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, denys@visp.net.lb,
	netdev@vger.kernel.org
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52314 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757251Ab2EaWUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 18:20:05 -0400
In-Reply-To: <20120531072519.16464513.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Thu, 31 May 2012 07:25:19 +0900

> When below pattern is observed,
> 
>                                                TIME
>        dql_queued()         dql_completed()     |
>       a) initial state                          |
>                                                 |
>       b) X bytes queued                         V
> 
>       c) Y bytes queued
>                            d) X bytes completed
>       e) Z bytes queued
>                            f) Y bytes completed
> 
> a) dql->limit has already some value and there is no in-flight packet.
> b) X bytes queued.
> c) Y bytes queued and excess limit.
> d) X bytes completed and dql->prev_ovlimit is set and also
>    dql->prev_num_queued is set Y.
> e) Z bytes queued.
> f) Y bytes completed. inprogress and prev_inprogress are true.
> 
> At f), according to the comment, all_prev_completed becomes
> true and limit should be increased. But POSDIFF() ignores
> (completed == dql->prev_num_queued) case, so limit is decreased.
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Applied and queued up for -stable.
