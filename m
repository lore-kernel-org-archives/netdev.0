From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,v2] net: sock: adapt SOCK_MIN_RCVBUF and
 SOCK_MIN_SNDBUF
Date: Wed, 19 Jun 2013 21:17:21 -0700 (PDT)
Message-ID: <20130619.211721.1594350084165223337.davem@davemloft.net>
References: <1371639080-10699-1-git-send-email-dborkman@redhat.com>
	<1371644355.3252.307.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092Ab3FTERW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 00:17:22 -0400
In-Reply-To: <1371644355.3252.307.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Jun 2013 05:19:15 -0700

> On Wed, 2013-06-19 at 12:51 +0200, Daniel Borkmann wrote:
>> The current situation is that SOCK_MIN_RCVBUF is 2048 + sizeof(struct sk_buff))
>> while SOCK_MIN_SNDBUF is 2048. Since in both cases, skb->truesize is used for
>> sk_{r,w}mem_alloc accounting, we should have both sizes adjusted via defining a
>> TCP_SKB_MIN_TRUESIZE.
>> 
>> Further, as Eric Dumazet points out, the minimal skb truesize in transmit path is
>> SKB_TRUESIZE(2048) after commit f07d960df33c5 ("tcp: avoid frag allocation for
>> small frames"), and tcp_sendmsg() tries to limit skb size to half the congestion
>> window, meaning we try to build two skbs at minimum. Thus, having SOCK_MIN_SNDBUF
>> as 2048 can hit a small regression for some applications setting to low
>> SO_SNDBUF / SO_RCVBUF. Note that we define a TCP_SKB_MIN_TRUESIZE, because
>> SKB_TRUESIZE(2048) adds SKB_DATA_ALIGN(sizeof(struct skb_shared_info)), but in
>> case of TCP skbs, the skb_shared_info is part of the 2048 bytes allocation for
>> skb->head.
>> 
>> The minor adaption in sk_stream_moderate_sndbuf() is to silence a warning by
>> using a typed max macro, as similarly done in SOCK_MIN_RCVBUF occurences, that
>> would appear otherwise.
>> 
>> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>  v1 -> v2:
>>   - Applied Eric's feedback, fixed up commit message
>>   - Set subject to 'net' instead of 'net-next' due to the reported regression
> 
> I am fine with this patch (I already run it as a matter of fact), but
> I think its net-next material :
> Regression is not new, and concerns very pathological cases, where
> applications relied on some non documented behavior of network stack.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks guys.
