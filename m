From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 4/4] UDP memory accounting and limitation(take 5): memory
 limitation
Date: Wed, 17 Oct 2007 00:06:40 -0400
Message-ID: <47158A50.90905@redhat.com>
References: <470F61D4.6040808@hitachi.com> <470F646F.2030003@hitachi.com> <20071015104306.GA30828@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hideo AOKI <hideo.aoki.tk@hitachi.com>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56079 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821AbXJQEKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 00:10:51 -0400
In-Reply-To: <20071015104306.GA30828@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Oct 12, 2007 at 09:11:27PM +0900, Satoshi OSHIMA wrote:
>> +static inline int __ip_check_max_skb_pages(struct sock *sk, int size)
>> +{
>> +	switch(sk->sk_protocol) {
>> +	case IPPROTO_UDP:
>> +		if (sk->sk_prot->sysctl_mem[0] > UDP_MIN_SKB_PAGES)
>> +			if (atomic_read(sk->sk_prot->memory_allocated)+size
>> +			    >= sk->sk_prot->sysctl_mem[0])
>> +				return -ENOBUFS;
>> +		/* Fall through */	
>> +	default:
>> +		break;
>> +	}
>> +	return 0;
>> +}
> 
> Since you're not doing a per-user limit, you must give each
> socket a minimum even when the total exceeds your threshold.
> 
> Otherwise any local user can trivially DoS the whole system.
> 
>> +UDP variables:
>> +
>> +udp_mem - INTERGER
>> +	Number of pages allowed for queueing by all UDP sockets.
>> +	Minimal value is 4096. If 4096 is set, UDP memory will not
>> +	be limited.
>> +	Default: 4096
> 
> This seems to be a rather confusing setup.  We don't set a
> minimum for TCP so is this really necessary?

Hello Herbert,

Thank you so much for your comments.

I'm going to fix them in next take patch set.

Regards,
Hideo

--
Hitachi Computer Products (America) Inc.
