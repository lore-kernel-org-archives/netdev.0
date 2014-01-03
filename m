From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: llc: fix use after free in llc_ui_recvmsg
Date: Thu, 02 Jan 2014 19:31:55 -0500 (EST)
Message-ID: <20140102.193155.570848830875823542.davem@davemloft.net>
References: <1388443250-30224-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	acme@ghostprotocols.net
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbaACAb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 19:31:56 -0500
In-Reply-To: <1388443250-30224-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 30 Dec 2013 23:40:50 +0100

> While commit 30a584d944fb fixes datagram interface in LLC, a use
> after free bug has been introduced for SOCK_STREAM sockets that do
> not make use of MSG_PEEK.
> 
> The flow is as follow ...
> 
>   if (!(flags & MSG_PEEK)) {
>     ...
>     sk_eat_skb(sk, skb, false);
>     ...
>   }
>   ...
>   if (used + offset < skb->len)
>     continue;
> 
> ... where sk_eat_skb() calls __kfree_skb(). Therefore, cache
> original length and work on skb_len to check partial reads.
> 
> Fixes: 30a584d944fb ("[LLX]: SOCK_DGRAM interface fixes")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, thanks!
