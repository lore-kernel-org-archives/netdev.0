From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next 1/2] tcp: adjust window probe timers to safer values
Date: Wed, 6 May 2015 18:15:26 -0400
Message-ID: <CADVnQykLPj-gQ0=pNTJdx3JrjiAfnF4x77Yf-0cGM24veW9BRQ@mail.gmail.com>
References: <1430947585-2375-1-git-send-email-edumazet@google.com>
	<1430947585-2375-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:32930 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbbEFWP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 18:15:27 -0400
Received: by oica37 with SMTP id a37so19447569oic.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 15:15:26 -0700 (PDT)
In-Reply-To: <1430947585-2375-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 6, 2015 at 5:26 PM, Eric Dumazet <edumazet@google.com> wrote:
> With the advent of small rto timers in datacenter TCP,
> (ip route ... rto_min x), the following can happen :
>
> 1) Qdisc is full, transmit fails.
>
>    TCP sets a timer based on icsk_rto to retry the transmit, without
>    exponential backoff.
>    With low icsk_rto, and lot of sockets, all cpus are servicing timer
>    interrupts like crazy.
>    Intent of the code was to retry with a timer between 200 (TCP_RTO_MIN)
>    and 500ms (TCP_RESOURCE_PROBE_INTERVAL)
>
> 2) Receivers can send zero windows if they don't drain their receive queue.
>
>    TCP sends zero window probes, based on icsk_rto current value, with
>    exponential backoff.
>    With /proc/sys/net/ipv4/tcp_retries2 being 15 (or even smaller in
>    some cases), sender can abort in less than one or two minutes !
>    If receiver stops the sender, it obviously doesn't care of very tight
>    rto. Probability of dropping the ACK reopening the window is not
>    worth the risk.
>
> Lets change the base timer to be at least 200ms (TCP_RTO_MIN) for these
> events (but not normal RTO based retransmits)
>
> A followup patch adds a new SNMP counter, as it would have helped a lot
> diagnosing this issue.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
