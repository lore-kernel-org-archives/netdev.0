From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC 2/4] virtio-net: transmit napi
Date: Mon, 6 Mar 2017 21:33:56 +0200
Message-ID: <20170306213257-mutt-send-email-mst@kernel.org>
References: <20170303143909.80001-3-willemdebruijn.kernel@gmail.com>
 <d60512a1-4210-b0c8-c672-bb6e3779936d@redhat.com>
 <CAF=yD-K8vEKdRK5YC-aRLgHf_5hXZObBQCP9N0FMertYMU-T3A@mail.gmail.com>
 <20170306.105522.1168429366842291288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: willemdebruijn.kernel@gmail.com, jasowang@redhat.com,
        netdev@vger.kernel.org, willemb@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33666 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754354AbdCFUK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 15:10:56 -0500
Content-Disposition: inline
In-Reply-To: <20170306.105522.1168429366842291288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 06, 2017 at 10:55:22AM -0800, David Miller wrote:
> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Date: Mon, 6 Mar 2017 12:50:19 -0500
> 
> >>>   drivers/net/virtio_net.c | 73
> >>> ++++++++++++++++++++++++++++++++++++++++--------
> >>>   1 file changed, 61 insertions(+), 12 deletions(-)
> >>>
> >>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> >>> index 8c21e9a4adc7..9a9031640179 100644
> >>> --- a/drivers/net/virtio_net.c
> >>> +++ b/drivers/net/virtio_net.c
> >>> @@ -33,6 +33,8 @@
> >>>   static int napi_weight = NAPI_POLL_WEIGHT;
> >>>   module_param(napi_weight, int, 0444);
> >>>   +static int napi_tx_weight = NAPI_POLL_WEIGHT;
> >>> +
> >>
> >>
> >> Maybe we should use module_param for this? Or in the future, use
> >> tx-frames-irq for a per-device configuration.
> > 
> > This option should eventually just go away, and napi tx become the
> > standard mode.
> > 
> > In the short term, while we evaluate it on varied workloads, a
> > module_param sounds good to me. In general that is frowned
> > upon, as it leads to different configuration interfaces for each
> > device driver. But that should not be a concern in this limited
> > case.
> 
> In any event, do we really need a TX weight at all?
> 
> I guess you tried this, but why doesn't it not work to just do
> all TX work unconditionally in a NAPI poll pass?  This is how
> we encourage all NIC drivers to handle this.

This seems to be more or less what this driver does already.
So I suspect it can just ignore the weight.

-- 
MST
