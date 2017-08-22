From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v2 net-next 1/2] tcp: Extend SOF_TIMESTAMPING_RX_SOFTWARE
 to TCP recvmsg
Date: Tue, 22 Aug 2017 17:32:03 -0400
Message-ID: <CAF=yD-L_2bBmf-crV_-1XW-jzwF-_F5hLJ0fRpM+p7bHNQJ_sQ@mail.gmail.com>
References: <20170822210849.23162-1-maloneykernel@gmail.com> <20170822210849.23162-2-maloneykernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Mike Maloney <maloney@google.com>
To: Mike Maloney <maloneykernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:33679 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751651AbdHVVco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:32:44 -0400
Received: by mail-oi0-f49.google.com with SMTP id f11so198890849oic.0
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 14:32:44 -0700 (PDT)
In-Reply-To: <20170822210849.23162-2-maloneykernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 5:08 PM, Mike Maloney <maloneykernel@gmail.com> wrote:
> From: Mike Maloney <maloney@google.com>
>
> When SOF_TIMESTAMPING_RX_SOFTWARE is enabled for tcp sockets, return the
> timestamp corresponding to the highest sequence number data returned.
>
> Previously the skb->tstamp is overwritten when a TCP packet is placed
> in the out of order queue.  While the packet is in the ooo queue, save the
> timestamp in the TCB_SKB_CB.  This space is shared with the gso_*
> options which are only used on the tx path, and a previously unused 4
> byte hole.
>
> When skbs are coalesced either in the sk_receive_queue or the
> out_of_order_queue always choose the timestamp of the appended skb to
> maintain the invariant of returning the timestamp of the last byte in
> the recvmsg buffer.
>
> Signed-off-by: Mike Maloney <maloney@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>
