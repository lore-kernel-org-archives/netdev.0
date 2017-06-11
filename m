From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net: reflect mark on tcp syn ack packets
Date: Sun, 11 Jun 2017 07:58:18 -0400
Message-ID: <056cbd5c-2a5f-8767-e584-591f39bc2029@mojatatu.com>
References: <1497101461-20921-1-git-send-email-jhs@emojatatu.com>
 <20170610.190213.1437094451353913622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, mrv@mojatatu.com,
        hadi@mojatatu.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35792 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751631AbdFKL6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 07:58:32 -0400
Received: by mail-io0-f193.google.com with SMTP id f79so8354019ioi.2
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 04:58:31 -0700 (PDT)
In-Reply-To: <20170610.190213.1437094451353913622.davem@davemloft.net>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-06-10 07:02 PM, David Miller wrote:

>> @@ -173,7 +173,8 @@ int ip_build_and_send_pkt(struct sk_buff *skb, const struct sock *sk,
>>   	}
>>   
>>   	skb->priority = sk->sk_priority;
>> -	skb->mark = sk->sk_mark;
>> +	if (!skb->mark)
>> +		skb->mark = sk->sk_mark;
> 
> Maybe this should both be "inet_request_mark()"?
> 

Challenge is making of a synack requires a new allocated skb;
and sk is a listening socket - which should/has a mark of
0 meaning at ip_build_and_send_pkt() it overrides
the value already set on the skb->mark.

cheers,
jamal

> Also, Lorenzo, please review.
> 
