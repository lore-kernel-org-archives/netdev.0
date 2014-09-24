From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net] tcp: Fix TLP implementation in case receive window
 limits send
Date: Wed, 24 Sep 2014 11:54:47 -0700
Message-ID: <CAK6E8=fQjqXbbbdCVR-yNBif7C7GRBnPNsq11V7QZbqgb7dtwQ@mail.gmail.com>
References: <6cbd68ba1ef44c5ca4b21bd3f65846af@AM3PR06MB388.eurprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Itzcak Pechtalt <itzcak@flashnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:57291 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbaIXSz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 14:55:28 -0400
Received: by mail-ig0-f172.google.com with SMTP id a13so7112810igq.5
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 11:55:27 -0700 (PDT)
In-Reply-To: <6cbd68ba1ef44c5ca4b21bd3f65846af@AM3PR06MB388.eurprd06.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2014 at 9:28 AM, Itzcak Pechtalt
<itzcak@flashnetworks.com> wrote:
> From: Itzcak Pechtalt <itzcak@flashnetworks.com>
>
> TCP Tail loss probe (TLP) algorithm implementation has some problem.
> According to paper (draft-dukkipati-tcpm-tcp-loss-probe-0 ):
> In case recive window of receiver limits send of new packet in probe time than
> a retransmit of last packet send should be done.
>
> Actually, return code from tcp_write_xmit is not checked and only RTO is
> scheduled,
> So, it will take more time for reovery in this case than without TLP.
>
> Signed-off-by: Itzcak Pechtalt <itzcak@flashnetworks.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
> ---
> net/ipv4/tcp_output.c  |    2 +-
> 1 file changed, 1 insertions(+),  1 deletions(-)
>
> diff -up a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> --- a/net/ipv4/tcp_output.c     2014-09-23 18:35:37.113771694 +0300
> +++ b/net/ipv4/tcp_output.c     2014-09-23 18:39:58.207726420 +0300
> @@ -2100,7 +2100,8 @@ void tcp_send_loss_probe(struct sock *sk
>
>         if (tcp_send_head(sk) != NULL) {
>                 err = tcp_write_xmit(sk, mss, TCP_NAGLE_OFF, 2, GFP_ATOMIC);
> -              goto rearm_timer;
> +             if (!err)
> +                       goto rearm_timer;
>         }
>
>         /* At most one outstanding TLP retransmission. */
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
