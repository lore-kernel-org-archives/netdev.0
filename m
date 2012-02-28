From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: fix comment for tp->highest_sack
Date: Mon, 27 Feb 2012 16:38:24 -0800
Message-ID: <CAK6E8=e4pZVJExthazBxPRgByFk3w6=a6GVbpopEvjek=ouSWA@mail.gmail.com>
References: <1330383070-10367-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, Nandita Dukkipati <nanditad@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:46318 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753223Ab2B1Aio convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Feb 2012 19:38:44 -0500
Received: by obcva7 with SMTP id va7so6161824obc.19
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 16:38:44 -0800 (PST)
In-Reply-To: <1330383070-10367-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2012 at 2:51 PM, Neal Cardwell <ncardwell@google.com> w=
rote:
> There was an off-by-one error in the comments describing the
> highest_sack field in struct tcp_sock. The comments previously claime=
d
> that it was the "start sequence of the highest skb with SACKed
> bit". This commit fixes the comments to note that it is the "start
> sequence of the skb just *after* the highest skb with SACKed bit".
>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
> =A0include/linux/tcp.h | =A0 =A03 ++-
> =A0include/net/tcp.h =A0 | =A0 =A05 +++--
> =A02 files changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 46a85c9..3c7ffdb 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -412,7 +412,8 @@ struct tcp_sock {
>
> =A0 =A0 =A0 =A0struct tcp_sack_block recv_sack_cache[4];
>
> - =A0 =A0 =A0 struct sk_buff *highest_sack; =A0 /* highest skb with S=
ACK received
> + =A0 =A0 =A0 struct sk_buff *highest_sack; =A0 /* skb just after the=
 highest
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0* skb with SACKed bit set
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 * (validity guaranteed only if
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 * sacked_out > 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 */
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 42c29bf..2d80c29 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1364,8 +1364,9 @@ static inline void tcp_push_pending_frames(stru=
ct sock *sk)
> =A0 =A0 =A0 =A0}
> =A0}
>
> -/* Start sequence of the highest skb with SACKed bit, valid only if
> - * sacked > 0 or when the caller has ensured validity by itself.
> +/* Start sequence of the skb just after the highest skb with SACKed
> + * bit, valid only if sacked_out > 0 or when the caller has ensured
> + * validity by itself.
> =A0*/
> =A0static inline u32 tcp_highest_sack_seq(struct tcp_sock *tp)
> =A0{
> --
> 1.7.7.3
>
Acked-by: Yuchung Cheng <ycheng@google.com>

AFAICT, highest_sack_* in Linux are essentially SND.FACK? if so it
would be nice to add that in the comment too.
