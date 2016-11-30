From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v3 0/6] XDP for virtio_net
Date: Wed, 30 Nov 2016 20:35:52 +0200
Message-ID: <20161130203450-mutt-send-email-mst@kernel.org>
References: <20161129200450.26752.86882.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, shm@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, bblanco@plumgrid.com, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37800 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756593AbcK3Sf6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 13:35:58 -0500
Content-Disposition: inline
In-Reply-To: <20161129200450.26752.86882.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 12:05:20PM -0800, John Fastabend wrote:
> This implements virtio_net for the mergeable buffers and big_packet
> modes. I tested this with vhost_net running on qemu and did not see
> any issues. For testing num_buf > 1 I added a hack to vhost driver
> to only but 100 bytes per buffer.
> 
> There are some restrictions for XDP to be enabled and work well
> (see patch 3) for more details.
> 
>   1. LRO must be off
>   2. MTU must be less than PAGE_SIZE
>   3. queues must be available to dedicate to XDP
>   4. num_bufs received in mergeable buffers must be 1
>   5. big_packet mode must have all data on single page
> 
> Please review any comments/feedback welcome as always.
> 
> v2, fixes rcu usage throughout thanks to Eric and the use of
> num_online_cpus() usage thanks to Jakub.
> 
> v3, add slowpath patch to handle num_bufs > 1
> 
> Thanks,
> John

BTW this is threaded incorrectly: patch 1/6 isn't a reply to 0/6,
patches 2 and on are replies to patch 1.

I'm busy until end of week, I'll review Monday. Sorry about the delay.

> ---
> 
> John Fastabend (6):
>       net: virtio dynamically disable/enable LRO
>       net: xdp: add invalid buffer warning
>       virtio_net: Add XDP support
>       virtio_net: add dedicated XDP transmit queues
>       virtio_net: add XDP_TX support
>       virtio_net: xdp, add slowpath case for non contiguous buffers
> 
> 
>  drivers/net/virtio_net.c |  344 +++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/filter.h   |    1 
>  net/core/filter.c        |    6 +
>  3 files changed, 346 insertions(+), 5 deletions(-)
> 
> --
> Signature
