From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next resend] tcp: use zero-window when free_space is low
Date: Thu, 13 Feb 2014 08:19:46 -0800
Message-ID: <1392308386.1752.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392292350-28800-1-git-send-email-fw@strlen.de>
	 <1392303499.1752.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140213153441.GJ25153@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:48647 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbaBMQUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 11:20:00 -0500
Received: by mail-pb0-f54.google.com with SMTP id uo5so10962308pbc.41
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 08:20:00 -0800 (PST)
In-Reply-To: <20140213153441.GJ25153@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-13 at 16:34 +0100, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > Would you mind waiting we run our packetdrill tests before acknowledging
> > this patch, because I suspect this might have some impact ?
> 
> Of course not.  I am very happy that you folks have these kinds of tests
> and are willing to double-check.  Take all time you need, there is no
> need to haste.
> 


We have today 348 different packetdrill tests, and this number keeps
increasing ;)

> Many Thanks Eric.
> 
> Do you think it makes sense to add counters for this?
> 
> The caveat is that decision to send 0 window doesn't mean we end
> up sending one, since we cannot shrink already offered window.
> 
> static u16 tcp_select_window(struct sock *sk)
> {
>     struct tcp_sock *tp = tcp_sk(sk);
>     u32 cur_win = tcp_receive_window(tp);
>     u32 new_win = __tcp_select_window(sk);
> 
>     /* Never shrink the offered window */
>     if (new_win < cur_win) {
> 
> Would you add SNMP counter for '__tcp_select_window() wants 0 window'
> or for 'tcp_select_window() does pick 0 window' ?
> 
> [ or even different counters for both ? ]

Ideally, having counters of transitions would be nice.

This would help us to spot regressions in TCP stacks or network drivers,
or wrong application tunings.

One counter tracking number of times a socket went from a non zero
window to a zero window (as you said, I am referring to effective window
being sent)

One counter tracking the reverse.

If it proves being too complex or expensive, a single counter tracking
"win 0" sent to the peers.
