From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: some ipv6 statistic counters failed to
 disable bh
Date: Mon, 31 Mar 2014 16:39:04 -0400 (EDT)
Message-ID: <20140331.163904.1733729527022532179.davem@davemloft.net>
References: <CAOMZO5DQ3dNB-R5rsd2X89XLbg_VYs7za8xQT2K-bWWmFS=YHA@mail.gmail.com>
	<20140331181410.GC24150@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: festevam@gmail.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbaCaUjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 16:39:07 -0400
In-Reply-To: <20140331181410.GC24150@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 31 Mar 2014 20:14:10 +0200

> After commit c15b1ccadb323ea ("ipv6: move DAD and addrconf_verify
> processing to workqueue") some counters are now updated in process context
> and thus need to disable bh before doing so, otherwise deadlocks can
> happen on 32-bit archs. Fabio Estevam noticed this while while mounting
> a NFS volume on an ARM board.
> 
> As a compensation for missing this I looked after the other *_STATS_BH
> and found three other calls which need updating:
> 
> 1) icmp6_send: ip6_fragment -> icmpv6_send -> icmp6_send (error handling)
> 2) ip6_push_pending_frames: rawv6_sendmsg -> rawv6_push_pending_frames -> ...
>    (only in case of icmp protocol with raw sockets in error handling)
> 3) ping6_v6_sendmsg (error handling)
> 
> Fixes: c15b1ccadb323ea ("ipv6: move DAD and addrconf_verify processing to workqueue")
> Reported-by: Fabio Estevam <festevam@gmail.com>
> Tested-by: Fabio Estevam <fabio.estevam@freescale.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> 
> I would propose this patch for -stable, too.

Applied and queued up for -stable, thanks.
