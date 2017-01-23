From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH v5 6/6] virtio_net: XDP support for adjust_head
Date: Mon, 23 Jan 2017 21:22:36 +0200
Message-ID: <20170123205957-mutt-send-email-mst@kernel.org>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
 <20170117222259.20280.24625.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46550 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751360AbdAWTWh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 14:22:37 -0500
Content-Disposition: inline
In-Reply-To: <20170117222259.20280.24625.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 02:22:59PM -0800, John Fastabend wrote:
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 62dbf4b..3b129b4 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -41,6 +41,9 @@
>  #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
>  #define GOOD_COPY_LEN	128
>  
> +/* Amount of XDP headroom to prepend to packets for use by xdp_adjust_head */
> +#define VIRTIO_XDP_HEADROOM 256
> +
>  /* RX packet size EWMA. The average packet size is used to determine the packet
>   * buffer size when refilling RX rings. As the entire RX ring may be refilled
>   * at once, the weight is chosen so that the EWMA will be insensitive to short-

I wonder where does this number come from?  This is quite a lot and
means that using XDP_PASS will slow down any sockets on top of it.
Which in turn means people will try to remove XDP when not in use,
causing resets.  E.g. build_skb (which I have a patch to switch to) uses
a much more reasonable NET_SKB_PAD.

-- 
MST
