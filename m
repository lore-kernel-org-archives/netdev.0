From: Gopakumar Choorakkot Edakkunni <gopakumar.c.e@gmail.com>
Subject: Re: Bug in tcp timestamp option ? TSecr in SYN-ACK != TSval in SYN
Date: Wed, 27 May 2015 10:29:15 -0700
Message-ID: <CABK1yFDu+76vYJwwXf+0Kc3YBK6VHL224v_u=HTf-RZ7dGN6qQ@mail.gmail.com>
References: <CABK1yFBN7KgBxRRzx-Bmt86_L8PnbfgqNJr7Mc2o9usn=LKSTg@mail.gmail.com>
	<1432707139.4060.351.camel@edumazet-glaptop2.roam.corp.google.com>
	<1432707810.4060.352.camel@edumazet-glaptop2.roam.corp.google.com>
	<CABK1yFDJNonOr0O7N3gjJw-AripeaRqC1Xi+sDt7i_s0gC+ZLQ@mail.gmail.com>
	<1432733597.4060.375.camel@edumazet-glaptop2.roam.corp.google.com>
	<1432734319.4060.383.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Van Jacobson <vanj@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:33216 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbbE0R3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 13:29:16 -0400
Received: by iebgx4 with SMTP id gx4so19114197ieb.0
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 10:29:15 -0700 (PDT)
In-Reply-To: <1432734319.4060.383.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Eric. I will give this a spin. The issue doesnt happen all the
time, I can keep the server running with this patch for a while and
observe if the issue resurfaces or not

Rgds,
Gopa.

On Wed, May 27, 2015 at 6:45 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-05-27 at 06:33 -0700, Eric Dumazet wrote:
>
>> The problem is in linux code itself. Please try the patch I sent ?
>> (On the client)
>
> On the server, sorry for the typo.
>
>>
>> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
>> index df7fe3c31162e77b96f81399ef7d893485ab3d91..70db6572d241e132c28c381dfc1155b150c9557b 100644
>> --- a/net/ipv4/tcp_minisocks.c
>> +++ b/net/ipv4/tcp_minisocks.c
>> @@ -588,6 +588,9 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
>>       if (TCP_SKB_CB(skb)->seq == tcp_rsk(req)->rcv_isn &&
>>           flg == TCP_FLAG_SYN &&
>>           !paws_reject) {
>> +             if (tmp_opt.saw_tstamp &&
>> +                 after(tmp_opt.rcv_tsval, req->ts_recent))
>> +                     req->ts_recent = tmp_opt.rcv_tsval;
>>               /*
>>                * RFC793 draws (Incorrectly! It was fixed in RFC1122)
>>                * this case on figure 6 and figure 8, but formal
>
>
