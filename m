From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next] tcp: implement RFC 5961 4.2
Date: Tue, 17 Jul 2012 15:10:06 -0700
Message-ID: <CAGK4HS8MvP6L5Rvy4wJx2KhdTSSHfP7YPT44e9mrV_vsBZJ9jQ@mail.gmail.com>
References: <1342525290.2626.459.camel@edumazet-glaptop>
	<CAGK4HS-AMWZ0Ef7G1pvWJ7XADsvxqsiX3tMCe2=oq+_46won6g@mail.gmail.com>
	<1342560769.2626.1165.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Kiran Kumar Kella <kkiran@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59572 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755558Ab2GQWKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 18:10:07 -0400
Received: by yenl2 with SMTP id l2so962482yen.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 15:10:06 -0700 (PDT)
In-Reply-To: <1342560769.2626.1165.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But you probably are right, we could test th->syn here as well.
>
> Something like that ?

> -               if (!th->rst)
> +               if (!th->rst) {
> +                       if (th->syn)
> +                               goto syn_challenge;
>                         tcp_send_dupack(sk, skb);
> +               }
>                 goto discard;
>         }
>
> @@ -5327,6 +5330,7 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
>          * RFC 5691 4.2 : Send a challenge ack
>          */
>         if (th->syn) {
> +syn_challenge:
>                 if (syn_inerr)
>                         TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
>                 NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNCHALLENGE);
>

Yes. This is what I had in mind (along with a change to make
tcp_sequence() return bool). I am not sure if this patch is official
(or will be picked up by patchwork) but
for what its worth

Acked-by: Vijay Subramanian <subramanian.vijay@gmail.com>

I will send a separate patch to make tcp_sequence() return bool.
Thanks!
Vijay
