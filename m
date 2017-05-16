From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v3 net-next 6/7] net: allow simultaneous SW and HW
 transmit timestamping
Date: Tue, 16 May 2017 18:31:36 -0400
Message-ID: <CAF=yD-K=XDboSqVwqxLh1rjbgW5oCCa-yYs3zoTx-9O_7jmQoA@mail.gmail.com>
References: <20170516124425.6294-1-mlichvar@redhat.com> <20170516124425.6294-7-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:34418 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750785AbdEPWcS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 18:32:18 -0400
Received: by mail-oi0-f54.google.com with SMTP id b204so43763827oii.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 15:32:17 -0700 (PDT)
In-Reply-To: <20170516124425.6294-7-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 8:44 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> Add SOF_TIMESTAMPING_OPT_TX_SWHW option to allow an outgoing packet to
> be looped to the socket's error queue with a software timestamp even
> when a hardware transmit timestamp is expected to be provided by the
> driver.
>
> Applications using this option will receive two separate messages from
> the error queue, one with a software timestamp and the other with a
> hardware timestamp. As the hardware timestamp is saved to the shared skb
> info, which may happen before the first message with software timestamp
> is received by the application, the hardware timestamp is copied to the
> SCM_TIMESTAMPING control message only when the skb has no software
> timestamp or it is an incoming packet.
>
> While changing sw_tx_timestamp(), inline it in skb_tx_timestamp() as
> there are no other users.
>
> CC: Richard Cochran <richardcochran@gmail.com>
> CC: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>

Acked-by: Willem de Bruijn <willemb@google.com>
