From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH next resend] tcp: use zero-window when free_space is low
Date: Thu, 13 Feb 2014 16:34:41 +0100
Message-ID: <20140213153441.GJ25153@breakpoint.cc>
References: <1392292350-28800-1-git-send-email-fw@strlen.de>
 <1392303499.1752.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43905 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751824AbaBMPen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 10:34:43 -0500
Content-Disposition: inline
In-Reply-To: <1392303499.1752.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Do we have one SNMP counter tracking number of time we took the decision
> to send a 0 window ?

No.

> Would you mind waiting we run our packetdrill tests before acknowledging
> this patch, because I suspect this might have some impact ?

Of course not.  I am very happy that you folks have these kinds of tests
and are willing to double-check.  Take all time you need, there is no
need to haste.

Many Thanks Eric.

Do you think it makes sense to add counters for this?

The caveat is that decision to send 0 window doesn't mean we end
up sending one, since we cannot shrink already offered window.

static u16 tcp_select_window(struct sock *sk)
{
    struct tcp_sock *tp = tcp_sk(sk);
    u32 cur_win = tcp_receive_window(tp);
    u32 new_win = __tcp_select_window(sk);

    /* Never shrink the offered window */
    if (new_win < cur_win) {

Would you add SNMP counter for '__tcp_select_window() wants 0 window'
or for 'tcp_select_window() does pick 0 window' ?

[ or even different counters for both ? ]

Cheers,
Florian
