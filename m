From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: tso: allow deferring under reordering state
Date: Sun, 26 Jul 2015 11:43:39 -0400
Message-ID: <CADVnQynorgXVLwfqHL+3vmLjVk_CriX8ob+GZHwS9BqpKsA8Uw@mail.gmail.com>
References: <1437896724.20182.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35882 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755158AbbGZPnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 11:43:40 -0400
Received: by obnw1 with SMTP id w1so43945677obn.3
        for <netdev@vger.kernel.org>; Sun, 26 Jul 2015 08:43:39 -0700 (PDT)
In-Reply-To: <1437896724.20182.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 26, 2015 at 3:45 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> While doing experiments with reordering resilience, we found
> linux senders were not able to send at full speed under reordering,
> because every incoming SACK was releasing one MSS.
>
> This patch removes the limitation, as we did for CWR state
> in commit a0ea700e409 ("tcp: tso: allow CA_CWR state in
> tcp_tso_should_defer()")
>
> Neal Cardwell had a concern about limited transmit so
> Yuchung conducted experiments on GFE and found nothing
> worth adding an extra check on fast path :
>
>   if (icsk->icsk_ca_state == TCP_CA_Disorder &&
>       tcp_sk(sk)->reordering == sysctl_tcp_reordering)
>           goto send_now;
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

Looks good to me. Thanks, Eric. And thanks, Yuchung, for running the experiment!

neal
