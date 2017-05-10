From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next V4 00/10] vhost_net batch dequeuing
Date: Wed, 10 May 2017 15:37:46 +0300
Message-ID: <20170510153734-mutt-send-email-mst@kernel.org>
References: <1494387382-19916-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1494387382-19916-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 10, 2017 at 11:36:12AM +0800, Jason Wang wrote:
> This series tries to implement rx batching for vhost-net. This is done
> by batching the dequeuing from skb_array which was exported by
> underlayer socket and pass the sbk back through msg_control to finish
> userspace copying. This is also the requirement for more batching
> implemention on rx path.
> 
> Tests shows at most 8.8% improvment bon rx pps on top of batch zeroing.
> 
> Please review.
> 
> Thanks
> 
> Changes from V3:
> - add batch zeroing patch to fix the build warnings

FYI that one's going upstream now.

> Changes from V2:
> - rebase to net-next HEAD
> - use unconsume helpers to put skb back on releasing
> - introduce and use vhost_net internal buffer helpers
> - renew performance numbers on top of batch zeroing
> 
> Changes from V1:
> - switch to use for() in __ptr_ring_consume_batched()
> - rename peek_head_len_batched() to fetch_skbs()
> - use skb_array_consume_batched() instead of
>   skb_array_consume_batched_bh() since no consumer run in bh
> - drop the lockless peeking patch since skb_array could be resized, so
>   it's not safe to call lockless one
> 
> Jason Wang (8):
>   skb_array: introduce skb_array_unconsume
>   ptr_ring: introduce batch dequeuing
>   skb_array: introduce batch dequeuing
>   tun: export skb_array
>   tap: export skb_array
>   tun: support receiving skb through msg_control
>   tap: support receiving skb from msg_control
>   vhost_net: try batch dequing from skb array
> 
> Michael S. Tsirkin (2):
>   ptr_ring: batch ring zeroing
>   ptr_ring: add ptr_ring_unconsume
> 
>  drivers/net/tap.c         |  25 ++++++-
>  drivers/net/tun.c         |  31 ++++++--
>  drivers/vhost/net.c       | 117 +++++++++++++++++++++++++++--
>  include/linux/if_tap.h    |   5 ++
>  include/linux/if_tun.h    |   5 ++
>  include/linux/ptr_ring.h  | 183 +++++++++++++++++++++++++++++++++++++++++++---
>  include/linux/skb_array.h |  31 ++++++++
>  7 files changed, 370 insertions(+), 27 deletions(-)
> 
> -- 
> 2.7.4
