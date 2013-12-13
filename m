From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: remove a bogus TSO split
Date: Fri, 13 Dec 2013 09:54:11 -0800
Message-ID: <1386957251.19078.151.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386876523.19078.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CADVnQymwaUNVgzqM97vfb=nfMFzVWmK8wR7fQ8Wm3i_c8+Z0jA@mail.gmail.com>
	 <1386946449.19078.147.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CADVnQynu9kbaqMW+eTMsp8jgydiLf9-nxnp-z_s789Q1eSPPmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:43378 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab3LMRyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 12:54:14 -0500
Received: by mail-yh0-f49.google.com with SMTP id z20so1753435yhz.36
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 09:54:14 -0800 (PST)
In-Reply-To: <CADVnQynu9kbaqMW+eTMsp8jgydiLf9-nxnp-z_s789Q1eSPPmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-13 at 11:22 -0500, Neal Cardwell wrote:

> Yes, I like your ideas to use mss_now instead, move
> tcp_minshall_update() to tcp_output.c (next to tcp_minshall_check()?),
> and update the comment in front of tcp_mss_split_point().
> 
> And given that mss_now is more sane than tcp_skb_mss(skb) (which is
> zero for one-MSS skbs) I think maybe we can make it something like:
> 
>  static inline void tcp_minshall_update(struct tcp_sock *tp, unsigned
> int mss_now,
>                                        const struct sk_buff *skb)
>  {
>          if (skb->len < tcp_skb_pcount(skb) * mss_now)
>                 tp->snd_sml = TCP_SKB_CB(skb)->end_seq;
>  }

This was indeed what I got ;)
