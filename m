From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet, inet6: make tcp_sendmsg() and tcp_sendpage()
 through inet_sendmsg() and inet_sendpage()
Date: Sat, 10 Jul 2010 23:07:47 -0700 (PDT)
Message-ID: <20100710.230747.258112764.davem@davemloft.net>
References: <1278819894-2861-1-git-send-email-xiaosuo@gmail.com>
	<4C394C5E.2000805@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	therbert@google.com, netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51892
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750966Ab0GKGHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 02:07:33 -0400
In-Reply-To: <4C394C5E.2000805@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Sat, 10 Jul 2010 21:45:18 -0700

> Changli Gao wrote:
> 
>> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
>> index 3ceb025..1e5bad1 100644
>> --- a/net/ipv4/af_inet.c
>> +++ b/net/ipv4/af_inet.c
>> @@ -727,28 +727,31 @@ int inet_sendmsg(struct kiocb *iocb, struct
>> socket *sock, struct msghdr *msg,
>>  	sock_rps_record_flow(sk);
>>   	/* We may need to bind the socket. */
>> -	if (!inet_sk(sk)->inet_num && inet_autobind(sk))
>> +	if (!sk->sk_prot->no_autobind &&
>> +	    !inet_sk(sk)->inet_num && inet_autobind(sk))
>>  		return -EAGAIN;
> 
> I think it's better to test inet_num first since usually it's not 0.
> With the above ordering protocols with no_autobind==false end up
> making two comparisons.

Agreed, Changli please make this change.

Thanky ou.
