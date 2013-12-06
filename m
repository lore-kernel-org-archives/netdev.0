From: Andrew Vagin <avagin@parallels.com>
Subject: Re: [PATCH v2] virtio-net: free bufs correctly on invalid packet
 length
Date: Fri, 6 Dec 2013 09:09:57 +0400
Message-ID: <20131206050956.GA17752@paralelels.com>
References: <1386278045-23542-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Eric Dumazet" <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Andrey Vagin <avagin@openvz.org>,
	<virtualization@lists.linux-foundation.org>
To: Michael Dalton <mwdalton@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:37641 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab3LFFNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 00:13:54 -0500
Content-Disposition: inline
In-Reply-To: <1386278045-23542-1-git-send-email-mwdalton@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 01:14:05PM -0800, Michael Dalton wrote:
> When a packet with invalid length arrives, ensure that the packet
> is freed correctly if mergeable packet buffers and big packets
> (GUEST_TSO4) are both enabled.
> 
> Signed-off-by: Michael Dalton <mwdalton@google.com>

Acked-by: Andrew Vagin <avagin@openvz.org>

> ---
>  drivers/net/virtio_net.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 916241d..6a4665c 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -426,10 +426,10 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
>  	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
>  		pr_debug("%s: short packet %i\n", dev->name, len);
>  		dev->stats.rx_length_errors++;
> -		if (vi->big_packets)
> -			give_pages(rq, buf);
> -		else if (vi->mergeable_rx_bufs)
> +		if (vi->mergeable_rx_bufs)
>  			put_page(virt_to_head_page(buf));
> +		else if (vi->big_packets)
> +			give_pages(rq, buf);
>  		else
>  			dev_kfree_skb(buf);
>  		return;
> -- 
> 1.8.5.1
> 
