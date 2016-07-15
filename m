From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: enable per-socket rate limiting of all
 'challenge acks'
Date: Fri, 15 Jul 2016 09:39:43 -0400
Message-ID: <CADVnQymN+jE2875ZFGOpe1W7wham6a-UuX2ZVytRhxKL8r3fMg@mail.gmail.com>
References: <1468510720-322-1-git-send-email-jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>, Yue Cao <ycao009@ucr.edu>
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36234 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbcGONkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 09:40:14 -0400
Received: by mail-oi0-f52.google.com with SMTP id w18so163592503oiw.3
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 06:40:13 -0700 (PDT)
In-Reply-To: <1468510720-322-1-git-send-email-jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 14, 2016 at 11:38 AM, Jason Baron <jbaron@akamai.com> wrote:
>
> From: Jason Baron <jbaron@akamai.com>
>
> The per-socket rate limit for 'challenge acks' was introduced in the
> context of limiting ack loops:
>
> commit f2b2c582e824 ("tcp: mitigate ACK loops for connections as tcp_sock")
>
> And I think it can be extended to rate limit all 'challenge acks' on a
> per-socket basis.
>
> Since we have the global tcp_challenge_ack_limit, this patch allows for
> tcp_challenge_ack_limit to be set to a large value and effectively rely on
> the per-socket limit, or set tcp_challenge_ack_limit to a lower value and
> still prevents a single connections from consuming the entire challenge ack
> quota.
>
> It further moves in the direction of eliminating the global limit at some
> point, as Eric Dumazet has suggested. This a follow-up to:
> Subject: tcp: make challenge acks less predictable
>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Yue Cao <ycao009@ucr.edu>
> Signed-off-by: Jason Baron <jbaron@akamai.com>
> ---
>  net/ipv4/tcp_input.c | 39 ++++++++++++++++++++++-----------------
>  1 file changed, 22 insertions(+), 17 deletions(-)

Sounds good to me.

 Acked-by: Neal Cardwell <ncardwell@google.com>

thanks,
neal
