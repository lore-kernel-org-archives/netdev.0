From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v3 net-next 4/7] net: add new control message for incoming
 HW-timestamped packets
Date: Tue, 16 May 2017 18:29:47 -0400
Message-ID: <CAF=yD-LMxMz0NgQQEyoWf_K5=HEqbWmuCjBMKF+NxNLwZw8FEg@mail.gmail.com>
References: <20170516124425.6294-1-mlichvar@redhat.com> <20170516124425.6294-5-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35232 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdEPWa2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 18:30:28 -0400
Received: by mail-oi0-f66.google.com with SMTP id m17so5632155oik.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 15:30:28 -0700 (PDT)
In-Reply-To: <20170516124425.6294-5-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 8:44 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> Add SOF_TIMESTAMPING_OPT_PKTINFO option to request a new control message
> for incoming packets with hardware timestamps. It contains the index of
> the real interface which received the packet and the length of the
> packet at layer 2.
>
> The index is useful with bonding, bridges and other interfaces, where
> IP_PKTINFO doesn't allow applications to determine which PHC made the
> timestamp. With the L2 length (and link speed) it is possible to
> transpose preamble timestamps to trailer timestamps, which are used in
> the NTP protocol.
>
> While this information could be provided by two new socket options
> independently from timestamping, it doesn't look like they would be very
> useful. With this option any performance impact is limited to hardware
> timestamping.
>
> Use dev_get_by_napi_id() to get the device and its index. On kernels
> with disabled CONFIG_NET_RX_BUSY_POLL or drivers not using NAPI, a zero
> index will be returned in the control message.
>
> CC: Richard Cochran <richardcochran@gmail.com>
> CC: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>

Acked-by: Willem de Bruijn <willemb@google.com>
