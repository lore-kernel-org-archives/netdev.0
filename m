From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] neigh: set nud_state to NUD_INCOMPLETE when probing
 router reachability
Date: Tue, 13 May 2014 12:43:54 -0400 (EDT)
Message-ID: <20140513.124354.854952996973060630.davem@davemloft.net>
References: <536C64C0.5050204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com,
	hannes@stressinduktion.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbaEMQn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 12:43:56 -0400
In-Reply-To: <536C64C0.5050204@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Fri, 9 May 2014 13:16:48 +0800

> Since commit 7e98056964("ipv6: router reachability probing"), a router falls
> into NUD_FAILED will be probed.
> 
> Now if function rt6_select() selects a router which neighbour state is NUD_FAILED,
> and at the same time function rt6_probe() changes the neighbour state to NUD_PROBE,
> then function dst_neigh_output() can directly send packets, but actually the
> neighbour still is unreachable. If we set nud_state to NUD_INCOMPLETE instead
> NUD_PROBE, packets will not be sent out until the neihbour is reachable.
> 
> In addition, because the route should be probes with a single NS, so we must
> set neigh->probes to neigh_max_probes(), then the neigh timer timeout and function
> neigh_timer_handler() will not send other NS Messages.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied and queued up for -stable, thanks.
