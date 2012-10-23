From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 3/3] sock-diag: Report shutdown for inet and unix sockets
Date: Tue, 23 Oct 2012 21:26:20 +0400
Message-ID: <5086D33C.7030208@parallels.com>
References: <5086C36B.6060508@parallels.com>  <5086C5A6.7050101@parallels.com> <1351011194.8609.2301.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:23814 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933303Ab2JWR03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 13:26:29 -0400
In-Reply-To: <1351011194.8609.2301.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2012 08:53 PM, Eric Dumazet wrote:
> On Tue, 2012-10-23 at 20:28 +0400, Pavel Emelyanov wrote:
>> Add ext bits for inet-diag and unix-diag and report sk_shutdown state.
> 
>>  
>> +	if (ext & (1 << (INET_DIAG_SHUTDOWN - 1)))
>> +		if (sock_diag_put_shutdown(sk, skb, INET_DIAG_SHUTDOWN))
>> +			goto errout;
>> +
> 
> I dont feel the need to make this conditional and consume one bit.

OK, but I have one concern about it.

I'll have to add the attrtype for it anyway. And when later we'll add
yet another one, say INET_DIAG_FOO, we will not be able to request
this in such

   req->ext |= (1 << (INET_DIAG_FOO - 1));

manner as it's currently done. If that's OK, I will rework the patch.

Thanks,
Pavel
