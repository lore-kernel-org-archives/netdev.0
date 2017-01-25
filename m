From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH v5 1/6] virtio_net: use dev_kfree_skb for small
 buffer XDP receive
Date: Wed, 25 Jan 2017 16:52:52 +0200
Message-ID: <20170125164844-mutt-send-email-mst@kernel.org>
References: <CAADnVQ+O1tNuktnPgkL7JHZFBaQbWfxq0rjxPn86rsbRcteRyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39856 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750771AbdAYOww (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 09:52:52 -0500
Content-Disposition: inline
In-Reply-To: <CAADnVQ+O1tNuktnPgkL7JHZFBaQbWfxq0rjxPn86rsbRcteRyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 11:33:56PM -0800, Alexei Starovoitov wrote:
> On Tue, Jan 24, 2017 at 8:02 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
> >
> > Finally just to point out here are the drivers with XDP support on latest
> > net tree,
> >
> >         mlx/mlx5
> >         mlx/mlx4
> >         qlogic/qede
> >         netronome/nfp
> >         virtio_net
> >
> > And here is the list of adjust header support,
> >
> >         mlx/mlx4
> >
> 
> in net-next it's actually:
> yes: mlx4, mlx5
> no: qede, nfp, virtio
> while nfp and virtio are working on it.
> 
> xdp_adjust_head() is must have for load balancer,

What amount of head space does it need? 70 bytes
to do vxlan kind of thing?

> so the sooner it lands for virtio the easier it will be
> to develop xdp programs. Initially I expected
> e1k+xdp to be the base line for debugging and
> development of xdp programs, but since not everyone
> agreed on e1k the virtio+xdp filled in the gap.
> So without adjust_head in virtio I see very little use for it
> in our environment.
> It is a must have feature regardless of timing.
> I will backport whatever is necessary, but distros
> will stick with official releases and imo it's not great
> from xdp adoption point of view to have
> virtio driver lacking key features.

If everyone can agree it's net-next material then I'm happy.

-- 
MST
