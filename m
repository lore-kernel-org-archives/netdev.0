From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] ipv4: Fix inetpeer expiration handling
Date: Tue, 08 Nov 2011 14:38:39 -0500 (EST)
Message-ID: <20111108.143839.968963366023220963.davem@davemloft.net>
References: <20111011110842.GC1830@secunet.com>
	<20111011111122.GF1830@secunet.com>
	<4E9FBEA1.2050407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933209Ab1KHTix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 14:38:53 -0500
In-Reply-To: <4E9FBEA1.2050407@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Thu, 20 Oct 2011 14:24:33 +0800

> there are serval problem.
> 1:rt->peer maybe null,we should call rt_bind_peer just like the code below.
> 2:rt->peer_pmtu_orig is null. if we hasn't send packet before,the func check_peer_pmtu hasn't be called.
>   so the peer->pmtu_orig is null.
> 3:when rt->rt_peer_genid != rt_peer_genid(), we has no need to do dst_metric_set(dst, RTAX_MTU, rt->peer->pmtu_orig),
>   because check_peer_pmtu will do this.
> 
> what about this patch?

In the case where no peer was created and we use default metrics and
other settings (can be common for UDP) I don't think it's wise to make
an inetpeer lookup every time we check the dst.
