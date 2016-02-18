From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp/dccp: fix another race at listener dismantle
Date: Thu, 18 Feb 2016 11:36:51 -0500 (EST)
Message-ID: <20160218.113651.1088682629104635773.davem@davemloft.net>
References: <1455802758-13550-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idryomov@gmail.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43700 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425486AbcBRQgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 11:36:53 -0500
In-Reply-To: <1455802758-13550-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu, 18 Feb 2016 05:39:18 -0800

> Ilya reported following lockdep splat:
 ...
> To properly fix this issue, inet_csk_reqsk_queue_add() needs
> to return to its callers if the child as been queued
> into accept queue.
> 
> We also need to make sure listener is still there before
> calling sk->sk_data_ready(), by holding a reference on it,
> since the reference carried by the child can disappear as
> soon as the child is put on accept queue.
> 
> Reported-by: Ilya Dryomov <idryomov@gmail.com>
> Fixes: ebb516af60e1 ("tcp/dccp: fix race at listener dismantle phase")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.

Although if I were writing this myself I would probably make
inet_csk_reqsk_queue_add() return bool since the pointer isn't
used in any way other than as a NULL vs. non-NULL test.
