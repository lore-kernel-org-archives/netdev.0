From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next v3] tcp: use RFC6298 compliant TCP RTO calculation
Date: Fri, 17 Jun 2016 11:56:13 -0700
Message-ID: <CAK6E8=eQNkSyAujuqF9hiE1iFk03O4T6op_-g=y87+UQUrS4=Q@mail.gmail.com>
References: <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
 <20160615180003.28970-1-dmetz@mytum.de> <20160617.113235.1099766688971255047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Metz <dmetz@mytum.de>, netdev <netdev@vger.kernel.org>,
	Daniel Metz <Daniel.Metz@rohde-schwarz.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:35306 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbcFQS4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 14:56:54 -0400
Received: by mail-io0-f178.google.com with SMTP id f30so76664823ioj.2
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 11:56:54 -0700 (PDT)
In-Reply-To: <20160617.113235.1099766688971255047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 11:32 AM, David Miller <davem@davemloft.net> wrote:
>
> From: Daniel Metz <dmetz@mytum.de>
> Date: Wed, 15 Jun 2016 20:00:03 +0200
>
> > This patch adjusts Linux RTO calculation to be RFC6298 Standard
> > compliant. MinRTO is no longer added to the computed RTO, RTO damping
> > and overestimation are decreased.
>  ...
>
> Yuchung, I assume I am waiting for you to do the testing you said
> you would do for this patch, right?
Yes I spent the last two days resolving some unrelated glitches to
start my testing on Web servers. I should be able to get some results
over the weekend.

I will test
0) current Linux
1) this patch
2) RFC6298 with min_RTO=1sec
3) RFC6298 with minimum RTTVAR of 200ms (so it is more like current
Linux style of min RTO which only applies to RTTVAR)

and collect the TCP latency (how long to send an HTTP response) and
(spurious) timeout & retransmission stats.

I didn't respond to Hagen's email yet b/c I thought data would help
the discussion better :-)
