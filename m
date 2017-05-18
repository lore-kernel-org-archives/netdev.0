From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v5 net-next 4/7] net: add new control message for incoming
 HW-timestamped packets
Date: Thu, 18 May 2017 16:20:53 -0400
Message-ID: <CAF=yD-+FCccqtF0oeqeph=dvrUJ8Byd8q_uWqZk+zvxYYtC_Fw@mail.gmail.com>
References: <20170518140738.19617-1-mlichvar@redhat.com> <20170518140738.19617-5-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36161 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753069AbdERUVe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 16:21:34 -0400
Received: by mail-oi0-f65.google.com with SMTP id w138so9225622oiw.3
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 13:21:34 -0700 (PDT)
In-Reply-To: <20170518140738.19617-5-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 10:07 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
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

> +SOF_TIMESTAMPING_OPT_PKTINFO:
> +
> +  Enable the SCM_TIMESTAMPING_PKTINFO control message for incoming
> +  packets with hardware timestamps. The message contains struct
> +  scm_ts_pktinfo, which supplies the index of the real interface which
> +  received the packet and its length at layer 2. A valid (non-zero)
> +  interface index will be returned only if CONFIG_NET_RX_BUSY_POLL is
> +  enabled and the driver is using NAPI.

It is probably good to explicitly call out that the remaining two fields
are reserved and undefined. To stress that applications cannot be
overly pedantic and start failing if these become non-zero.
