From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: read num_members once in
 packet_rcv_fanout()
Date: Sun, 21 Jun 2015 09:23:51 -0700 (PDT)
Message-ID: <20150621.092351.2098594550856406748.davem@davemloft.net>
References: <1434466751.27504.176.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755792AbbFUQMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 12:12:05 -0400
In-Reply-To: <1434466751.27504.176.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 16 Jun 2015 07:59:11 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We need to tell compiler it must not read f->num_members multiple
> times. Otherwise testing if num is not zero is flaky, and we could
> attempt an invalid divide by 0 in fanout_demux_cpu()
> 
> Note bug was present in packet_rcv_fanout_hash() and
> packet_rcv_fanout_lb() but final 3.1 had a simple location
> after commit 95ec3eb417115fb ("packet: Add 'cpu' fanout policy.")
> 
> Fixes: dc99f600698dc ("packet: Add fanout support.")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> ---
> Note : I chose to use READ_ONCE() but stable backports should use
> ACCESS_ONCE()

Applied and queued up for -stable, and thanks for the backport notes.
