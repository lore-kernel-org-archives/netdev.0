From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 3/4 net-next] tcp: measure RTT from new SACK
Date: Sun, 21 Jul 2013 23:32:33 -0400
Message-ID: <CADVnQy=D61fQHtYuQW07Nx8QpPR8jESH7gvrdbUNu-vwMuEy3Q@mail.gmail.com>
References: <1374385170-358-1-git-send-email-ycheng@google.com>
	<1374385170-358-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:50519 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755454Ab3GVDce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 23:32:34 -0400
Received: by mail-ea0-f182.google.com with SMTP id d10so3555518eaj.13
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 20:32:33 -0700 (PDT)
In-Reply-To: <1374385170-358-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 21, 2013 at 1:39 AM, Yuchung Cheng <ycheng@google.com> wrote:
> @@ -1148,6 +1149,7 @@ static u8 tcp_sacktag_one(struct sock *sk,
>                                                            state->reord);
>                                 if (!after(end_seq, tp->high_seq))
>                                         state->flag |= FLAG_ORIG_SACK_ACKED;
> +                               state->rtt = tcp_time_stamp - lsndtime;

To be safer we should probably take the RTT sample for the left-most
SACKed segment, just like tcp_clean_rtx_queue() takes a seq_rtt RTT
sample for the left-most cumulatively ACKed segment. Since
tcp_sacktag_write_queue() already sorts the SACK blocks, I think that
means tcp_sacktag_one() just needs to only set state->rtt if it is
still less than 0 (analagous to the update logic in
tcp_clean_rtx_queue()).

Also, FWIW I think the "lsndtime" variable name here is a little confusing,
since it is being used for the send time of the particular skb, which is
quite different from the similarly-named existing variable, tp->lsndttime.
Maybe "xmit_stamp"?

Otherwise, looks good. This is going to be nice to have.

neal
