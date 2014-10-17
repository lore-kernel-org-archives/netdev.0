From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net] ipv4: clear all TCP_SKB_CB before passing to network layer
Date: Fri, 17 Oct 2014 11:26:15 -0700
Message-ID: <CAHA+R7O0tUinJV4mMOWKF0A6pR3HQL1HA2Zurs=EPDu6suUZGA@mail.gmail.com>
References: <1413568169-4123-1-git-send-email-xiyou.wangcong@gmail.com>
	<1413569928.25949.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Krzysztof Kolasa <kkolasa@winsoft.pl>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:58882 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364AbaJQS0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 14:26:16 -0400
Received: by mail-qa0-f44.google.com with SMTP id x12so886438qac.31
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 11:26:15 -0700 (PDT)
In-Reply-To: <1413569928.25949.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 17, 2014 at 11:18 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-10-17 at 10:49 -0700, Cong Wang wrote:
>> From: Cong Wang <cwang@twopensource.com>
>>
>> Probably not a big deal, but IP is not the only network protocol,
>> don't clear skb->cb just for IP.
>>
>> Also, IPv6 header is not always defined in struct tcp_skb_cb.
>>
>> Cc: Krzysztof Kolasa <kkolasa@winsoft.pl>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Cong Wang <cwang@twopensource.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  net/ipv4/tcp_output.c | 4 +---
>>  1 file changed, 1 insertion(+), 3 deletions(-)
>>
>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>> index e13d778..ee356e5 100644
>> --- a/net/ipv4/tcp_output.c
>> +++ b/net/ipv4/tcp_output.c
>> @@ -1005,9 +1005,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
>>       /* Our usage of tstamp should remain private */
>>       skb->tstamp.tv64 = 0;
>>
>> -     /* Cleanup our debris for IP stacks */
>> -     memset(skb->cb, 0, max(sizeof(struct inet_skb_parm),
>> -                            sizeof(struct inet6_skb_parm)));
>> +     memset(TCP_SKB_CB(skb), 0, sizeof(*TCP_SKB_CB(skb)));
>>
>>       err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
>>
>
>
> Usually, each layer is responsible for clearing skb->cb[] at its entry
> point. Or more exactly it does not care of previous garbage.
>
> There is no evidence your patch is needed.

This is why I said "probably not a big deal" in changelog, I never
say it fixes anything, just a cleanup.

>
> I was maybe too defensive when I added this, because I wanted to make
> only TCP changes.
>
> We should instead remove the memset() in TCP and fix IP/IPv6 if
> necessary.

That works too and sounds better.

>
> But this should wait net-next being open.
>
>

Yeah, agreed, I will update and resend when net-next is reopen.

Thanks.
