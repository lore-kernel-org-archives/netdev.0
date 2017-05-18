From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v5 net-next 5/7] net: fix documentation of struct scm_timestamping
Date: Thu, 18 May 2017 15:38:30 -0400
Message-ID: <CAF=yD-JGUw6pryNV3YevFMxC5=1A62qujAfFO7LjQi2LtsSg4g@mail.gmail.com>
References: <20170518140738.19617-1-mlichvar@redhat.com> <20170518140738.19617-6-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33560 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932516AbdERTjQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 15:39:16 -0400
Received: by mail-oi0-f66.google.com with SMTP id h4so9069962oib.0
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 12:39:16 -0700 (PDT)
In-Reply-To: <20170518140738.19617-6-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 10:07 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> The scm_timestamping struct may return multiple non-zero fields, e.g.
> when both software and hardware RX timestamping is enabled, or when the
> SO_TIMESTAMP(NS) option is combined with SCM_TIMESTAMPING and a false
> software timestamp is generated in the recvmsg() call in order to always
> return a SCM_TIMESTAMP(NS) message.
>
> CC: Richard Cochran <richardcochran@gmail.com>
> CC: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>

Thanks for adding this!

> +Note that if the SO_TIMESTAMP or SO_TIMESTAMPNS option is enabled
> +together with SO_TIMESTAMPING using SOF_TIMESTAMPING_SOFTWARE, a false
> +software timestamp will be generated in the recvmsg() call and passed
> +in ts[0] when a real software timestamp is missing.

With receive software timestamping this is expected behavior? I would make
explicit that this happens even on tx timestamps.

> For this reason it
> +is not recommended to combine SO_TIMESTAMP(NS) with SO_TIMESTAMPING.

And I'd remove this. The extra timestamp is harmless, and we may be missing
other reasons why someone would want to enable both on the same socket.
