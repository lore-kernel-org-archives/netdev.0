From: Wang Weidong <weidong1991.wang@gmail.com>
Subject: Re: [PATCH net-next 2/3] sctp: remove the never used 'return' and,
 redundant 'break'
Date: Wed, 18 Dec 2013 22:33:09 +0800
Message-ID: <52B1B225.2040600@gmail.com>
References: <52B168E0.1060108@huawei.com> <20131218140654.GB10471@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>,
	Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35183 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041Ab3LROcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:32:45 -0500
In-Reply-To: <20131218140654.GB10471@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>

On 2013/12/18 22:06, Neil Horman wrote:
> On Wed, Dec 18, 2013 at 05:20:32PM +0800, Wang Weidong wrote:
>> In switch() had do return, and never use the 'return NULL'. The
>> 'break' after return or goto has no effect. Remove it.
>>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>   net/sctp/input.c | 5 -----
>>   1 file changed, 5 deletions(-)
>>
>> diff --git a/net/sctp/input.c b/net/sctp/input.c
>> index 2a192a7..c956dc9 100644
>> --- a/net/sctp/input.c
>> +++ b/net/sctp/input.c
>> @@ -1120,15 +1120,10 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
>>   	case SCTP_CID_INIT:
>>   	case SCTP_CID_INIT_ACK:
>>   		return __sctp_rcv_init_lookup(net, skb, laddr, transportp);
>> -		break;
>>
>>   	default:
>>   		return __sctp_rcv_walk_lookup(net, skb, laddr, transportp);
>> -		break;
>>   	}
>> -
>> -
>> -	return NULL;
>>   }
>>
>>   /* Lookup an association for an inbound skb. */
>> --
>> 1.7.12
>>
>>
>>
>
> If you're going to do this, it seems like you may just as well convert the
> switch to be if (ch->type && ch->type <= SCTP_CID_INIT_ACK) {...} else {...}
>
>
> That seems like it would be more readable to me.
>
> Neil
>
Hm, I will fix it.

Thanks.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
