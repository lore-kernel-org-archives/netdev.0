From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] tcp: refine TSO autosizing
Date: Sun, 07 Dec 2014 22:32:05 -0800
Message-ID: <1418020325.15618.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417788937.4322.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1417832560.15618.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1417983738.15618.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAK6E8=dBZw5_jeOhDLCX7sVPgu5WSiGPRPcL9GJ1G+nweJ90ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:65351 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051AbaLHGcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 01:32:08 -0500
Received: by mail-ig0-f173.google.com with SMTP id r2so2268540igi.6
        for <netdev@vger.kernel.org>; Sun, 07 Dec 2014 22:32:08 -0800 (PST)
In-Reply-To: <CAK6E8=dBZw5_jeOhDLCX7sVPgu5WSiGPRPcL9GJ1G+nweJ90ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-12-07 at 13:24 -0800, Yuchung Cheng wrote:
> >                  */
> > -               limit = max_t(unsigned int, sysctl_tcp_limit_output_bytes,
> > -                             sk->sk_pacing_rate >> 10);
> > +               limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
> is this capping necessary if skb->truesize already takes the pacing
> rate into account from the new logic above?


This is needed for flows not using GSO/TSO : For such flows,
skb->truesize is a constant (2048 + sizeof(struct sk_buff))
