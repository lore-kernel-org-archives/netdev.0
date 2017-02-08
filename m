From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net 2/2] packet: round up linear to header len
Date: Wed, 8 Feb 2017 08:58:51 -0800
Message-ID: <20170208165851.GG30741@oracle.com>
References: <20170207205721.23207-1-willemdebruijn.kernel@gmail.com>
 <20170207205721.23207-3-willemdebruijn.kernel@gmail.com>
 <20170208153454.GD30741@oracle.com>
 <CAF=yD-KoijEsct9YWm5zK3F7Eas3GS+=5zks7-fZw-bgZhi-3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46012 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932436AbdBHQ7C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:59:02 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-KoijEsct9YWm5zK3F7Eas3GS+=5zks7-fZw-bgZhi-3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (02/08/17 08:37), Willem de Bruijn wrote:
> Date: Wed, 8 Feb 2017 08:37:19 -0800
> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Cc: Network Development <netdev@vger.kernel.org>, David Miller
>  <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, Dmitry
>  Vyukov <dvyukov@google.com>, Willem de Bruijn <willemb@google.com>
> Subject: Re: [PATCH net 2/2] packet: round up linear to header len
> 
> On Wed, Feb 8, 2017 at 7:34 AM, Sowmini Varadhan
> <sowmini.varadhan@oracle.com> wrote:
> > On (02/07/17 15:57), Willem de Bruijn wrote:
> >> @@ -2816,8 +2816,9 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
> >>       err = -ENOBUFS;
> >>       hlen = LL_RESERVED_SPACE(dev);
> >>       tlen = dev->needed_tailroom;
> >> -     skb = packet_alloc_skb(sk, hlen + tlen, hlen, len,
> >> -                            __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len),
> >> +     linear = __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len);
> >> +     linear = max(linear, min_t(int, len, dev->hard_header_len));
> >> +     skb = packet_alloc_skb(sk, hlen + tlen, hlen, len, linear,
> >>                              msg->msg_flags & MSG_DONTWAIT, &err);
> >
  :
> Do you mean the difference that it unconditionally pulls
> hard_header_len, optionally with zero padding, whereas this new
> path can check against new min_header_len and thus allows
> packets shorter than hard_header_len?

yes, maybe it doesnt matter, becaues hard_header_len >= min_header_len
at all times

--Sowmini
