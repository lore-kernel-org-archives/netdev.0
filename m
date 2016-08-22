From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH v4 net-next] l2tp: Refactor the codes with existing macros
 instead of literal number
Date: Mon, 22 Aug 2016 22:51:01 +0800
Message-ID: <CA+6hz4q7yU3jYa96XxByuHFANX+ppa30z8EWxgfvX_9foC50pQ@mail.gmail.com>
References: <1471863591-6790-1-git-send-email-fgao@ikuai8.com> <20160822144358.m5jwuzvmgic4e7xw@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gao Feng <fgao@ikuai8.com>, jchapman@katalix.com,
        Philp Prindeville <philipp@redfish-solutions.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:33461 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754720AbcHVO52 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 10:57:28 -0400
Received: by mail-ua0-f173.google.com with SMTP id 74so193364520uau.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 07:57:28 -0700 (PDT)
In-Reply-To: <20160822144358.m5jwuzvmgic4e7xw@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I forget to run the check_patch.pl script this time.
Now I send the v5 update.

Regards
Feng

On Mon, Aug 22, 2016 at 10:43 PM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> On Mon, Aug 22, 2016 at 06:59:51PM +0800, fgao@ikuai8.com wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> Use PPP_ALLSTATIONS, PPP_UI, and SEND_SHUTDOWN instead of 0xff,
>> 0x03, and 2 separately.
>>
> Apart from the checkpatch errors,
>
> Acked-by: Guillaume Nault <g.nault@alphalink.fr>
>
>> @@ -325,8 +324,8 @@ static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
>>       skb_reserve(skb, uhlen);
>>
>>       /* Add PPP header */
>> -     skb->data[0] = ppph[0];
>> -     skb->data[1] = ppph[1];
>> +     skb->data[0] = PPP_ALLSTATIONS;
>>
> Trailing whitespace.
>
>> @@ -398,14 +396,14 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
>>                  sizeof(struct iphdr) + /* IP header */
>>                  uhlen +              /* UDP header (if L2TP_ENCAPTYPE_UDP) */
>>                  session->hdr_len +   /* L2TP header */
>> -                sizeof(ppph);        /* PPP header */
>> +                2;                   /* 2 bytes for PPP_ALLSTATIONS & PPP_UI */
>>       if (skb_cow_head(skb, headroom))
>>               goto abort_put_sess_tun;
>>
>>       /* Setup PPP header */
>> -     __skb_push(skb, sizeof(ppph));
>> -     skb->data[0] = ppph[0];
>> -     skb->data[1] = ppph[1];
>> +     __skb_push(skb, 2);
>>
> Here too.
