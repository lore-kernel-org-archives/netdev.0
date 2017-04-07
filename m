From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 3/3] virtio-net: clean tx descriptors from rx
 napi
Date: Fri, 7 Apr 2017 22:28:47 +0300
Message-ID: <20170407222616-mutt-send-email-mst@kernel.org>
References: <20170402201012.76473-1-willemdebruijn.kernel@gmail.com>
 <20170402201012.76473-4-willemdebruijn.kernel@gmail.com>
 <20170403024751.GA21883@redhat.com>
 <CAF=yD-+tJxqvwvLU81=H7nwqDtiSWfAv8UdfncjPQiuNteJ6jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60622 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933777AbdDGT2t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 15:28:49 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-+tJxqvwvLU81=H7nwqDtiSWfAv8UdfncjPQiuNteJ6jQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 03, 2017 at 01:02:13AM -0400, Willem de Bruijn wrote:
> On Sun, Apr 2, 2017 at 10:47 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Sun, Apr 02, 2017 at 04:10:12PM -0400, Willem de Bruijn wrote:
> >> From: Willem de Bruijn <willemb@google.com>
> >>
> >> Amortize the cost of virtual interrupts by doing both rx and tx work
> >> on reception of a receive interrupt if tx napi is enabled. With
> >> VIRTIO_F_EVENT_IDX, this suppresses most explicit tx completion
> >> interrupts for bidirectional workloads.
> >>
> >> Signed-off-by: Willem de Bruijn <willemb@google.com>

This is a popular approach, but I think this will only work well if tx
and rx interrupts are processed on the same CPU and if tx queue is per
cpu.  If they target different CPUs or if tx queue is used from multiple
CPUs they will conflict on the shared locks.

This can even change dynamically as CPUs/queues are reconfigured.
How about adding a flag and skipping the tx poll if there's no match?

-- 
MST
