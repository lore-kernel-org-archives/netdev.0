From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: refine pacing rate determination
Date: Fri, 21 Aug 2015 21:22:46 -0400
Message-ID: <CADVnQymkAxnhA19GGQ9LkhgoQu=2vzE069766x3-3zMvp5-Rwg@mail.gmail.com>
References: <1440203882.29244.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:34838 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbbHVBWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 21:22:47 -0400
Received: by oiew67 with SMTP id w67so51398470oie.2
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 18:22:46 -0700 (PDT)
In-Reply-To: <1440203882.29244.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 21, 2015 at 8:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> When TCP pacing was added back in linux-3.12, we chose
> to apply a fixed ratio of 200 % against current rate,
> to allow probing for optimal throughput even during
> slow start phase, where cwnd can be doubled every other gRTT.
>
> At Google, we found it was better applying a different ratio
> while in Congestion Avoidance phase.
> This ratio was set to 120 %.
>
> We've used the normal tcp_in_slow_start() helper for a while,
> then tuned the condition to select the conservative ratio
> as soon as cwnd >= ssthresh/2 :
>
> - After cwnd reduction, it is safer to ramp up more slowly,
>   as we approach optimal cwnd.
> - Initial ramp up (ssthresh == INFINITY) still allows doubling
>   cwnd every other RTT.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

Looks great to me. Thanks, Eric!

neal
