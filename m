From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 0/5] refine virtio-net XDP
Date: Tue, 18 Jul 2017 23:13:15 +0300
Message-ID: <20170718230748-mutt-send-email-mst@kernel.org>
References: <1500295441-19339-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1500295441-19339-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 17, 2017 at 08:43:56PM +0800, Jason Wang wrote:
> Hi:
> 
> This series brings two optimizations for virtio-net XDP:
> 
> - avoid reset during XDP set
> - turn off offloads on demand

I'm glad to see this take shape - this can be
extended to optimize virtnet_get_headroom so we don't
waste room if adjust_head is enabled.

I see a couple of issues, responded to individual patches.


> Please review.
> 
> Thanks
> 
> Jason Wang (5):
>   virtio_ring: allow to store zero as the ctx
>   virtio-net: pack headroom into ctx for mergeable buffer
>   virtio-net: switch to use new ctx API for small buffer
>   virtio-net: do not reset during XDP set
>   virtio-net: switch off offloads on demand if possible on XDP set
> 
>  drivers/net/virtio_net.c     | 325 +++++++++++++++++++++++++------------------
>  drivers/virtio/virtio_ring.c |   2 +-
>  2 files changed, 194 insertions(+), 133 deletions(-)
> 
> -- 
> 2.7.4
