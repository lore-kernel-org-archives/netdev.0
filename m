From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH 1/7] net: refactor __netif_receive_skb_core
Date: Wed, 15 Apr 2015 06:28:22 -0700
Message-ID: <552E6776.9060409@redhat.com>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org> <1428668142-4006-2-git-send-email-pablo@netfilter.org> <55282AED.1050306@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1CB1EA6B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	"'Alexander Duyck'" <alexander.duyck@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59712 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752200AbbDON2l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 09:28:41 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB1EA6B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/15/2015 05:44 AM, David Laight wrote:
> From: Alexander Duyck
>> Sent: 10 April 2015 20:56
>> On 04/10/2015 05:15 AM, Pablo Neira Ayuso wrote:
>>> +another_round:
>>> +	ret = __netif_receive_skb_ingress(skb, pfmemalloc, orig_dev);
>>> +	switch (ret) {
>>> +	case NET_RX_SUCCESS:
>>> +	case NET_RX_DROP:
>>> +		break;
>>> +	case __NET_RX_ANOTHER_ROUND:
>>> +		goto another_round;
>>> +	}
>>>   	rcu_read_unlock();
>>> +
>>>   	return ret;
>>>   }
>>>
>>>
>>
>> Couldn't this just be done as a do while?  It would probably be easier
>> to read and there wouldn't be any need for the another_round label anymore.
>
> Or an infinite loop with a break at the bottom, as in:
> 	for (;;) {
> 		switch (...) {
> 		case again:
> 			continue;
> 		default:
> 			break;
> 		}
> 		break;
> 	}
>
> 	David
>

That is even more complicated.  What I was thinking was
	do {
		ret = __netif_receive_skb_ingress(skb, pfmemalloc,
						  orig_dev);
	} while (ret == __NET_RX_ANOTHER_ROUND);

Either that or the switch could just be replaced with a if statement 
since the only case that really goes anywhere is __NET_RX_ANOTHER_ROUND 
and everything else just exits anyway.  I had just suggested a do/while 
since that lets the goto be dropped, but an if would allow for avoiding 
any unnecessary indentation on the call to __netif_receive_skb_ingress.

- Alex
