From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ping: Fix race in free in receive path
Date: Tue, 27 Jan 2015 00:05:21 -0800 (PST)
Message-ID: <20150127.000521.291244489423335210.davem@davemloft.net>
References: <45fab13fce077924f957cba84ba20ba4.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932209AbbA0IFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:05:22 -0500
In-Reply-To: <45fab13fce077924f957cba84ba20ba4.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: subashab@codeaurora.org
Date: Fri, 23 Jan 2015 22:26:02 -0000

> An exception is seen in ICMP ping receive path where the skb
> destructor sock_rfree() tries to access a freed socket. This happens
> because ping_rcv() releases socket reference with sock_put() and this
> internally frees up the socket. Later icmp_rcv() will try to free the
> skb and as part of this, skb destructor is called and which leads
> to a kernel panic as the socket is freed already in ping_rcv().
> 
> -->|exception
> -007|sk_mem_uncharge
> -007|sock_rfree
> -008|skb_release_head_state
> -009|skb_release_all
> -009|__kfree_skb
> -010|kfree_skb
> -011|icmp_rcv
> -012|ip_local_deliver_finish
> 
> Fix this incorrect free by cloning this skb and processing this cloned
> skb instead.
> 
> This patch was suggested by Eric Dumazet
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>

Applied and queued up for -stable, thanks.
