From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix tcp fin memory accounting
Date: Fri, 20 Mar 2015 13:20:29 -0400 (EDT)
Message-ID: <20150320.132029.103306583158863864.davem@davemloft.net>
References: <1426807170-19258-1-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: johunt@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35930 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbbCTRUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 13:20:30 -0400
In-Reply-To: <1426807170-19258-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hunt <johunt@akamai.com>
Date: Thu, 19 Mar 2015 19:19:30 -0400

> tcp_send_fin() does not account for the memory it allocates properly, so
> sk_forward_alloc can be negative in cases where we've sent a FIN:
> 
> ss example output (ss -amn | grep -B1 f4294):
> tcp    FIN-WAIT-1 0      1            192.168.0.1:45520         192.0.2.1:8080
> 	skmem:(r0,rb87380,t0,tb87380,f4294966016,w1280,o0,bl0)
> --
> tcp    FIN-WAIT-1 0      1            192.168.0.1:8080          192.0.2.1:59710
> 	skmem:(r0,rb87380,t0,tb87380,f4294966016,w1280,o0,bl0)
> 
> This can be resolved by using sk_stream_alloc_skb() instead of calling alloc_skb_fclone()
> directly. The same fix was made in tcp_connect() in commit 355a901e6cf1 (tcp: make connect() mem charging friendly).
> 
> With this fix applied I no longer see the negative sk_forward_alloc values (or
> very large values repoted by ss) in my tests.
> 
> Signed-off-by: Josh Hunt <johunt@akamai.com>

Applied and queued up for -stable, thanks.
