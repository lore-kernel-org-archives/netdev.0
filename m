From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net PATCH v5 1/6] virtio_net: use dev_kfree_skb for small buffer
 XDP receive
Date: Tue, 24 Jan 2017 23:33:56 -0800
Message-ID: <CAADnVQ+O1tNuktnPgkL7JHZFBaQbWfxq0rjxPn86rsbRcteRyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34287 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751296AbdAYHfq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 02:35:46 -0500
Received: by mail-lf0-f68.google.com with SMTP id q89so19570322lfi.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 23:34:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 8:02 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
>
> Finally just to point out here are the drivers with XDP support on latest
> net tree,
>
>         mlx/mlx5
>         mlx/mlx4
>         qlogic/qede
>         netronome/nfp
>         virtio_net
>
> And here is the list of adjust header support,
>
>         mlx/mlx4
>

in net-next it's actually:
yes: mlx4, mlx5
no: qede, nfp, virtio
while nfp and virtio are working on it.

xdp_adjust_head() is must have for load balancer,
so the sooner it lands for virtio the easier it will be
to develop xdp programs. Initially I expected
e1k+xdp to be the base line for debugging and
development of xdp programs, but since not everyone
agreed on e1k the virtio+xdp filled in the gap.
So without adjust_head in virtio I see very little use for it
in our environment.
It is a must have feature regardless of timing.
I will backport whatever is necessary, but distros
will stick with official releases and imo it's not great
from xdp adoption point of view to have
virtio driver lacking key features.
