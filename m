From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] af_unix: don't append consumed skbs to
 sk_receive_queue
Date: Mon, 16 Nov 2015 15:40:09 -0500 (EST)
Message-ID: <20151116.154009.530996237690972616.davem@davemloft.net>
References: <1447687556-22712-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbKPUkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 15:40:10 -0500
In-Reply-To: <1447687556-22712-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 16 Nov 2015 16:25:56 +0100

> In case multiple writes to a unix stream socket race we could end up in a
> situation where we pre-allocate a new skb for use in unix_stream_sendpage
> but have to free it again in the locked section because another skb
> has been appended meanwhile, which we must use. Accidentally we didn't
> clear the pointer after consuming it and so we touched freed memory
> while appending it to the sk_receive_queue. So, clear the pointer after
> consuming the skb.
> 
> This bug has been found with syzkaller
> (http://github.com/google/syzkaller) by Dmitry Vyukov.
> 
> Fixes: 869e7c62486e ("net: af_unix: implement stream sendpage support")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
