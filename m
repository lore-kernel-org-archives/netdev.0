From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v6 net-next 6/7] net: allow simultaneous SW and HW
 transmit timestamping
Date: Fri, 19 May 2017 12:00:41 -0400
Message-ID: <CAF=yD-K9C9hbxpCkbkLk3TrteZZt6f2Qq7_eHdTeO4vj22EUmA@mail.gmail.com>
References: <20170519155241.15817-1-mlichvar@redhat.com> <20170519155241.15817-7-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33047 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751916AbdESQBY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:01:24 -0400
Received: by mail-oi0-f48.google.com with SMTP id w10so97680027oif.0
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:01:24 -0700 (PDT)
In-Reply-To: <20170519155241.15817-7-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 11:52 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
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
