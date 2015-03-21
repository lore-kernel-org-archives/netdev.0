From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Revert "selinux: add a skb_owned_by() hook"
Date: Fri, 20 Mar 2015 21:39:09 -0400 (EDT)
Message-ID: <20150320.213909.2296919036071226673.davem@davemloft.net>
References: <1426896919-23036-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800AbbCUBjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 21:39:13 -0400
In-Reply-To: <1426896919-23036-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri, 20 Mar 2015 17:15:19 -0700

> This reverts commit ca10b9e9a8ca7342ee07065289cbe74ac128c169.
> 
> No longer needed after commit eb8895debe1baba41fcb62c78a16f0c63c21662a
> ("tcp: tcp_make_synack() should use sock_wmalloc")
> 
> When under SYNFLOOD, we build lot of SYNACK and hit false sharing
> because of multiple modifications done on sk_listener->sk_wmem_alloc
> 
> Since tcp_make_synack() uses sock_wmalloc(), there is no need
> to call skb_set_owner_w() again, as this adds two atomic operations.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
