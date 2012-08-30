From: Neal Cardwell <ncardwell@google.com>
Subject: Re: BUG: soft lockup - CPU#6 stuck for 22s! [httpd2-event:15597]
Date: Wed, 29 Aug 2012 21:37:46 -0400
Message-ID: <CADVnQy=bdHm2jcuReZaxr-qRMRWLDLnVP-jkzBTE-HPZ9FROmw@mail.gmail.com>
References: <5038215E.60403@opensuse.org>
	<1345885186.19483.109.camel@edumazet-glaptop>
	<1345886085.19483.141.camel@edumazet-glaptop>
	<1345895225.19483.447.camel@edumazet-glaptop>
	<CADVnQymYXHcqJEgcgH0OHHFfCe6LAMSBZ0E68NWzDZQNTqB+Sg@mail.gmail.com>
	<1346040367.2420.22.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Cristian_Rodr=EDguez?= <crrodriguez@opensuse.org>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44813 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024Ab2H3Bhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 21:37:46 -0400
Received: by ialo24 with SMTP id o24so2342667ial.19
        for <netdev@vger.kernel.org>; Wed, 29 Aug 2012 18:37:46 -0700 (PDT)
In-Reply-To: <1346040367.2420.22.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 27, 2012 at 12:06 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Indeed, so the first patch was better...
>
> Not sure I can investigate this problem this week, as I attend LKS/LPC
> in San Diego.
>
> Could be that snd_cwnd is zero as well so we have this infinite loop...
>
>         while (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
>                 tp->snd_cwnd_cnt -= tp->snd_cwnd;
>                 delta++;
>         }

Yes, it seems that one way or another cwnd is getting to zero and
turning this into an infinite loop.

Two questions for you, Cristian, if you have a second:

1) Are you still seeing this problem in your workload? If so, would
you have time to try another small patch to add instrumentation to
track down the cause?

2) Do you happen to run with the tcp_mtu_probing sysctl enabled? I
have been looking for code paths that could cause the cwnd to go to
zero, and that's the first possibility that I've been able to see (in
tcp_mtup_probe_success() it seems like there are corner cases where
snd_cwnd could become zero).

neal
