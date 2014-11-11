From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: introduce SO_INCOMING_CPU
Date: Mon, 10 Nov 2014 21:16:29 -0500 (EST)
Message-ID: <20141110.211629.1869603635869884106.davem@davemloft.net>
References: <1415393472.13896.119.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141110.150826.1917858055737674539.davem@davemloft.net>
	<1415663481.9613.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycai@google.com, willemb@google.com,
	ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbaKKCQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 21:16:31 -0500
In-Reply-To: <1415663481.9613.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Nov 2014 15:51:21 -0800

> On Mon, 2014-11-10 at 15:08 -0500, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 07 Nov 2014 12:51:12 -0800
>> 
>> > @@ -1455,6 +1455,7 @@ process:
>> >  		goto discard_and_relse;
>> >  
>> >  	sk_mark_napi_id(sk, skb);
>> > +	sk_incoming_cpu_update(sk);
>> 
>> Just make sk_mark_napi_id() call sk_incoming_cpu_update().
>> 
>> You've matched up the calls precisely in this patch, and I can't think
>> of any situation where we'd add a sk_mark_napi_call() not not want to
>> do an sk_incoming_cpu_update().
> 
> I believe this was a coincidence.
> 
> In fact some sk_mark_napi_id() calls are not at the right place.
> It makes little sense to change sk->sk_napi_id for a listener socket.
> 
> sk_mark_napi_id() should better be done [1] at the same time we call
> sock_rps_save_rxhash
> 
> But we need to store cpu before prequeue or backlog (as I did in my
> patch)

Ok, so why don't you submit two patches.  First, fix the locations
where we do sk_mark_napi_id(), then your SO_INCOMING_CPU patch
(unchanged)?

Thanks.
