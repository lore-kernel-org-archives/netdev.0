From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: when rearming RTO, if RTO time is in past then
 fire RTO ASAP
Date: Thu, 17 Aug 2017 10:56:17 -0400
Message-ID: <CADVnQymXKqcjEyNjTpK_c+eWbryZ0RL+4Y46_6DrOCVO_j+g7A@mail.gmail.com>
References: <20170816215336.30419-1-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:33342 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750957AbdHQO4s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 10:56:48 -0400
Received: by mail-qt0-f179.google.com with SMTP id a18so39031880qta.0
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 07:56:48 -0700 (PDT)
In-Reply-To: <20170816215336.30419-1-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 16, 2017 at 5:53 PM, Neal Cardwell <ncardwell@google.com> wrote:
> In some situations tcp_send_loss_probe() can realize that it's unable
> to send a loss probe (TLP), and falls back to calling tcp_rearm_rto()
> to schedule an RTO timer. In such cases, sometimes tcp_rearm_rto()
> realizes that the RTO was eligible to fire immediately or at some
> point in the past (delta_us <= 0). Previously in such cases
> tcp_rearm_rto() was scheduling such "overdue" RTOs to happen at now +
> icsk_rto, which caused needless delays of hundreds of milliseconds
> (and non-linear behavior that made reproducible testing
> difficult). This commit changes the logic to schedule "overdue" RTOs
> ASAP, rather than at now + icsk_rto.
>
> Suggested-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Forgot to mention:

Fixes: 6ba8a3b19e76 ("tcp: Tail loss probe (TLP)")

This is a -stable candidate.

thanks,
neal
