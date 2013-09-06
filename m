From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: add documentation for BQL helpers
Date: Fri, 6 Sep 2013 14:56:08 +0100
Message-ID: <CAGVrzcby=-hshgq_8z2Y5+U29uwXH+7QZfJBJeyw8t69ZaPVAw@mail.gmail.com>
References: <1378465119-1894-1-git-send-email-f.fainelli@gmail.com> <1378472605.31445.18.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:57565 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356Ab3IFN4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 09:56:49 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so3264422pdj.29
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 06:56:48 -0700 (PDT)
In-Reply-To: <1378472605.31445.18.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/9/6 Eric Dumazet <eric.dumazet@gmail.com>:
> On Fri, 2013-09-06 at 11:58 +0100, Florian Fainelli wrote:
>> Provide a kernel-doc comment documentation for the BQL helpers:
>> - netdev_sent_queue
>> - netdev_completed_queue
>> - netdev_reset_queue
>>
>> Similarly to how it is done for the other functions, the documentation
>> only covers the function operating on struct net_device and not struct
>> netdev_queue.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  include/linux/netdevice.h | 27 +++++++++++++++++++++++++++
>>  1 file changed, 27 insertions(+)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 8ed4ae9..ac36629 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -2101,6 +2101,16 @@ static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
>>  #endif
>>  }
>>
>> +/**
>> + *   netdev_sent_queue - report the number of bytes queued to hardware
>> + *   @dev: network device
>> + *   @bytes: number of bytes queued to the hardware device queue
>> + *
>> + *   Report the number of bytes queued for sending/completion to the network
>> + *   device hardware queue. @bytes should specify the number of bytes which
>> + *   will be sent over the physical medium (without prepended/appended
>> + *   control blocks, FCS...)
>
> There is no such requirement.
>
> @bytes should be a good approximation, and should match
> netdev_completed_queue() @bytes
>
>
> If you think of TSO, we know that skb->len does not exactly matches
> number of bytes on physical medium ( check qdisc_pkt_len_init() to see
> how Qdisc layer tries to get better estimation )

Thanks Eric, do you also want me to update the comment above
netdev_completed_queue() or are you happy with it?
-- 
Florian
