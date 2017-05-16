From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: eliminate negative reordering in
 tcp_clean_rtx_queue
Date: Tue, 16 May 2017 12:46:19 -0400 (EDT)
Message-ID: <20170516.124619.1486699276109754253.davem@davemloft.net>
References: <20170515210547.125052-1-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
        soheil@google.com, ncardwell@google.com, ycheng@google.com,
        edumazet@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50876 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750765AbdEPQqV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 12:46:21 -0400
In-Reply-To: <20170515210547.125052-1-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Mon, 15 May 2017 17:05:47 -0400

> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> tcp_ack() can call tcp_fragment() which may dededuct the
> value tp->fackets_out when MSS changes. When prior_fackets
> is larger than tp->fackets_out, tcp_clean_rtx_queue() can
> invoke tcp_update_reordering() with negative values. This
> results in absurd tp->reodering values higher than
> sysctl_tcp_max_reordering.
> 
> Note that tcp_update_reordering indeeds sets tp->reordering
> to min(sysctl_tcp_max_reordering, metric), but because
> the comparison is signed, a negative metric always wins.
> 
> Fixes: c7caf8d3ed7a ("[TCP]: Fix reord detection due to snd_una covered holes")
> Reported-by: Rebecca Isaacs <risaacs@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
