From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 2/4] datagram: mem_scheudle functions
Date: Mon, 03 Dec 2007 19:10:45 -0500
Message-ID: <47549B05.5090507@redhat.com>
References: <474DB80E.5070403@redhat.com> <474DB90B.9090107@redhat.com> <20071201120946.GA14368@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36109 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996AbXLDAMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 19:12:09 -0500
In-Reply-To: <20071201120946.GA14368@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Nov 28, 2007 at 01:52:59PM -0500, Hideo AOKI wrote:
>> +static inline int sk_wmem_schedule(struct sock *sk, int size)
>> +{
>> +	if (sk->sk_type == SOCK_STREAM)
>> +		return sk_stream_wmem_schedule(sk, size);
>> +	else if (sk->sk_type == SOCK_DGRAM)
>> +		return sk_datagram_wmem_schedule(sk, size);
>> +	else
>> +		return 1;
>> +}
> 
> Why do we need this function? As far as I can see we always know
> whether it's a stream or datagram socket at compile time so doing
> a run-time test is pointless.

Because we have to call wmem_schedule function in ip_append_data()
which is used by several protocols both stream and datagram.
I just thought adding the sk_wmem_schedule() was only way to call
proper function from ip_append_data().

Please let me know if I misunderstand or there is better way to
call wmem_schedule functions.

Best regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.
