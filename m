From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next v2 1/6] tcp: instrument tcp sender limits chronographs
Date: Mon, 28 Nov 2016 12:23:14 -0500
Message-ID: <CADVnQy=xJCneqv7YL+1C8kOUuZB9pEGYrAOSyih1xTN_NbqwtA@mail.gmail.com>
References: <1480316838-154141-1-git-send-email-ycheng@google.com> <1480316838-154141-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        francisyyan@gmail.com, Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:32889 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754372AbcK1RXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:23:46 -0500
Received: by mail-oi0-f43.google.com with SMTP id w63so158912794oiw.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:23:45 -0800 (PST)
In-Reply-To: <1480316838-154141-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 2:07 AM, Yuchung Cheng <ycheng@google.com> wrote:
> From: Francis Yan <francisyyan@gmail.com>
>
> This patch implements the skeleton of the TCP chronograph
> instrumentation on sender side limits:
>
>         1) idle (unspec)
>         2) busy sending data other than 3-4 below
>         3) rwnd-limited
>         4) sndbuf-limited
>
> The limits are enumerated 'tcp_chrono'. Since a connection in
> theory can idle forever, we do not track the actual length of this
> uninteresting idle period. For the rest we track how long the sender
> spends in each limit. At any point during the life time of a
> connection, the sender must be in one of the four states.
>
> If there are multiple conditions worthy of tracking in a chronograph
> then the highest priority enum takes precedence over
> the other conditions. So that if something "more interesting"
> starts happening, stop the previous chrono and start a new one.
>
> The time unit is jiffy(u32) in order to save space in tcp_sock.
> This implies application must sample the stats no longer than every
> 49 days of 1ms jiffy.
>
> Signed-off-by: Francis Yan <francisyyan@gmail.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
