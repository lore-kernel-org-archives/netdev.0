From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net] tcp: Update MIB counters for drops
Date: Wed, 30 Jan 2013 18:16:21 -0800
Message-ID: <CAGK4HS-nzGLfgXJeiMgc=KbZ1G1EW3_A=4G0FjkCPuXZAqPVjw@mail.gmail.com>
References: <1359586670-16072-1-git-send-email-subramanian.vijay@gmail.com>
	<1359588675.30177.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	niveditasinghvi@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:47252 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760Ab3AaCQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 21:16:22 -0500
Received: by mail-ob0-f170.google.com with SMTP id wc20so2400294obb.1
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 18:16:22 -0800 (PST)
In-Reply-To: <1359588675.30177.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>
>>       case TCP_SYN_SENT:
>> @@ -1491,8 +1492,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
>>        */
>>       if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
>>               want_cookie = tcp_syn_flood_action(sk, skb, "TCP");
>> -             if (!want_cookie)
>> +             if (!want_cookie) {
>> +                     NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
>>                       goto drop;
>> +             }
>
> This should be done in tcp_syn_flood_action() for IPv4/IPv6
> factorization.
>

Thanks Eric. In fact, tcp_syn_flood_action() already has
                NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPREQQFULLDROP);

which is the right thing to do instead of incrementing LISTENOVERFLOWS
since it is syn table that is overflowing and
not accept_queue.

I will send V2 with this fixed.

Vijay
