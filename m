From: Valentina Giusti <valentina.giusti@bmw-carit.de>
Subject: Re: [PATCH v3 1/2] netfilter_queue: enable UID/GID socket info retrieval
Date: Fri, 20 Dec 2013 15:32:36 +0100
Message-ID: <52B45504.20608@bmw-carit.de>
References: <1387542820-16319-1-git-send-email-valentina.giusti@bmw-carit.de> <1387542820-16319-2-git-send-email-valentina.giusti@bmw-carit.de> <20131220140959.GA29632@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<jpa@google.com>, <pablo@netfilter.org>,
	<daniel.wagner@bmw-carit.de>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bmw-carit.de ([62.245.222.98]:57842 "EHLO
	mail.bmw-carit.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161003Ab3LTOcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:32:41 -0500
In-Reply-To: <20131220140959.GA29632@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2013 03:09 PM, Florian Westphal wrote:
> valentina.giusti@bmw-carit.de <valentina.giusti@bmw-carit.de> wrote:
>> --- a/net/netfilter/nfnetlink_queue_core.c
>> +++ b/net/netfilter/nfnetlink_queue_core.c
>> @@ -297,6 +297,32 @@ nfqnl_put_packet_info(struct sk_buff *nlskb, struct sk_buff *packet,
>>   	return flags ? nla_put_be32(nlskb, NFQA_SKB_INFO, htonl(flags)) : 0;
>>   }
>>   
>> +static int nfqnl_put_sk_uidgid(struct sk_buff *skb, struct sock *sk)
>> +{
>> +	const struct cred *cred;
>> +
>> +	if (sk->sk_state == TCP_TIME_WAIT)
>> +		return -1;
> I think this should be 'return 0'?
I put return -1 because I think that if userspace has requested to 
receive UID and GID, then it should be dumped only packets that have 
that information available.
Are you suggesting that it should be otherwise?

Thanks,
- Val
