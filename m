From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v3 net-next 5/7] net: don't make false software transmit timestamps
Date: Tue, 16 May 2017 18:34:38 -0400
Message-ID: <CAF=yD-+rFQBER8A=P216Bgbtxq+zHgAERoZaGdp=dvo=_otMXA@mail.gmail.com>
References: <20170516124425.6294-1-mlichvar@redhat.com> <20170516124425.6294-6-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33618 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752157AbdEPWfT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 18:35:19 -0400
Received: by mail-oi0-f47.google.com with SMTP id w10so43931233oif.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 15:35:19 -0700 (PDT)
In-Reply-To: <20170516124425.6294-6-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 8:44 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> If software timestamping is enabled by the SO_TIMESTAMP(NS) option
> when a message without timestamp is already waiting in the queue, the
> __sock_recv_timestamp() function will read the current time to make a
> timestamp in order to always have something for the application.
>
> However, this applies also to outgoing packets looped back to the error
> queue when hardware timestamping is enabled by the SO_TIMESTAMPING
> option.

This is already the case for sockets that have both software receive
timestamps and hardware tx timestamps enabled, independent from
the new option SOF_TIMESTAMPING_OPT_TX_SWHW, right? If so,
then this behavior must remain.
